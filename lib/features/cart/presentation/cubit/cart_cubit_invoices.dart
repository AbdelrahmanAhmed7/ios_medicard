part of 'cart_cubit.dart';

/// Cart and package invoice submission behavior for [CartCubit].
extension CartCubitInvoices on CartCubit {
  Future<bool> createCartInvoice() async {
    if (isClosed || _invoiceSubmissionInFlight) return false;
    // An invoice already exists for this checkout session (fresh success
    // or reconciled timeout): never POST twice for it. A new checkout
    // session (loadCheckout) resets this.
    if (state.createdInvoiceId != null) return false;
    if (state.isInvoiceOutcomeUnknown) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'cart.invoice_outcome_unknown'.tr()),
      );
      return false;
    }
    final provider = state.checkoutProvider;
    final branch = state.selectedBranch;
    if (provider == null) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'Please choose a provider.'),
      );
      return false;
    }
    if (branch == null) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'Please choose a branch.'),
      );
      return false;
    }
    final branchIsCurrent = state.checkoutBranches.any(
      (candidate) => candidate.branchId == branch.branchId,
    );
    if (!branchIsCurrent) {
      _emitCartState(
        state.copyWith(
          createInvoiceError: 'cart.selected_branch_unavailable'.tr(),
          resetSelectedBranch: true,
        ),
      );
      return false;
    }

    _invoiceSubmissionInFlight = true;
    try {
      _emitCartState(
        state.copyWith(
          isCreatingInvoice: true,
          resetCreateInvoiceError: true,
          resetCreatedInvoiceId: true,
          resetCreatedInvoicePaymentLink: true,
        ),
      );
      final result = await _invoiceRepository.createFromCart(
        providerId: provider.providerId,
        providerBranchId: branch.branchId,
        isCash: state.paymentMethod == CartPaymentMethod.cash,
        familyId: state.selectedFamilyMember?.id,
      );
      if (isClosed) return false;
      return result.when<bool>(
        success: (invoice) {
          _cartMutationGeneration++;
          final orderKind = state.checkoutOrderKind;
          final remainingCart =
              (orderKind == null
                  ? state.cart?.removeProvider(provider.providerId)
                  : state.cart?.removeOrder(
                      providerId: provider.providerId,
                      orderKind: orderKind,
                    )) ??
              const Cart.empty();
          _confirmedProviderAssignments.removeWhere(
            (_, item) =>
                item.providerId == provider.providerId &&
                (orderKind == null || item.orderKind == orderKind),
          );
          _emitCartState(
            state.copyWith(
              cart: remainingCart,
              isCreatingInvoice: false,
              createdInvoiceId: invoice.invoiceId,
              createdInvoicePaymentLink: invoice.paymentLink,
            ),
          );
          _broadcastCartSnapshot(remainingCart, refreshCart: true);
          return true;
        },
        failure: (error) {
          final outcomeUnknown = error == invoiceOutcomeUnknownFailure;
          if (outcomeUnknown) {
            _unknownOutcomeItemIds = {
              for (final item in state.cart?.items ?? const <CartItem>[])
                if (item.providerId == provider.providerId &&
                    (state.checkoutOrderKind == null ||
                        item.orderKind == state.checkoutOrderKind))
                  item.cartItemId,
            };
            _unknownOutcomeProviderName = provider.providerName;
            _unknownOutcomeOrderKind = state.checkoutOrderKind;
            _unknownOutcomeSubmittedAt = DateTime.now().toUtc();
          }
          _emitCartState(
            state.copyWith(
              isCreatingInvoice: false,
              isInvoiceOutcomeUnknown: outcomeUnknown,
              createInvoiceError: outcomeUnknown
                  ? 'cart.invoice_outcome_unknown'.tr()
                  : error,
            ),
          );
          return false;
        },
      );
    } catch (error) {
      if (!isClosed) {
        _emitCartState(
          state.copyWith(
            isCreatingInvoice: false,
            createInvoiceError: parseApiError(error),
          ),
        );
      }
      return false;
    } finally {
      _invoiceSubmissionInFlight = false;
    }
  }

  /// Reconciles an ambiguous invoice outcome. Never posts anything, so it
  /// cannot duplicate an invoice by itself.
  ///
  /// Cart membership alone is NOT conclusive (consumption could lag the
  /// timed-out POST), so a matching invoice in `my-invoices` corroborates:
  /// - [UnknownInvoiceResolution.created]: an invoice for this provider
  ///   dated at/after submission exists. Latch cleared; go to activity.
  /// - [UnknownInvoiceResolution.notCreated]: snapshot items are all still
  ///   present AND no matching invoice exists. Latch cleared; retry is safe
  ///   (modulo the residual race documented on [InvoiceRepository]).
  /// - [UnknownInvoiceResolution.stillUnknown]: anything else (failed
  ///   reads, partial consumption without corroboration, items gone with
  ///   no matching invoice, package flow). Latch stays; do not retry.
  Future<UnknownInvoiceResolution> reconcileUnknownInvoiceOutcome() async {
    if (isClosed || !state.isInvoiceOutcomeUnknown) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    if (_unknownOutcomeItemIds.isEmpty || _unknownOutcomeSubmittedAt == null) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final requestGeneration = ++_cartRequestGeneration;
    final invoicesResult = await _invoiceRepository.getMyInvoices(
      pageNumber: 1,
      pageSize: 10,
    );
    if (isClosed || requestGeneration != _cartRequestGeneration) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final cartResult = await _repository.getCart();
    if (isClosed || requestGeneration != _cartRequestGeneration) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    final invoices = invoicesResult.when(
      success: (page) => page.items,
      failure: (_) => null,
    );
    final cart = cartResult.when(success: (c) => c, failure: (_) => null);
    if (invoices == null || cart == null) {
      return UnknownInvoiceResolution.stillUnknown;
    }
    if (isClosed) return UnknownInvoiceResolution.stillUnknown;

    final earliest = _unknownOutcomeSubmittedAt!.subtract(
      const Duration(minutes: 5),
    );
    final wantedProvider = _unknownOutcomeProviderName.trim();
    InvoiceItem? matchingInvoice;
    for (final invoice in invoices) {
      if (invoice.providerName.trim() == wantedProvider &&
          (_unknownOutcomeOrderKind == null ||
              invoice.isMedicineInvoice ==
                  (_unknownOutcomeOrderKind == CartOrderKind.medicines)) &&
          !invoice.date.isBefore(earliest)) {
        matchingInvoice = invoice;
        break;
      }
    }
    final remainingIds = {for (final item in cart.items) item.cartItemId};
    final anyConsumed = _unknownOutcomeItemIds.any(
      (id) => !remainingIds.contains(id),
    );

    // Always converge the display to the fresh cart; the latch below
    // decides whether retry is allowed.
    _emitCartState(
      state.copyWith(cart: cart, isCartLoading: false, resetCartError: true),
    );
    _broadcastCartSnapshot(cart);

    if (matchingInvoice != null) {
      _clearUnknownOutcome();
      _emitCartState(
        state.copyWith(
          isInvoiceOutcomeUnknown: false,
          createdInvoiceId: '${matchingInvoice.invoiceId}',
        ),
      );
      return UnknownInvoiceResolution.created;
    }
    if (!anyConsumed) {
      _clearUnknownOutcome();
      _emitCartState(
        state.copyWith(
          isInvoiceOutcomeUnknown: false,
          resetCreateInvoiceError: true,
        ),
      );
      return UnknownInvoiceResolution.notCreated;
    }
    return UnknownInvoiceResolution.stillUnknown;
  }

  void _clearUnknownOutcome() {
    _unknownOutcomeItemIds = {};
    _unknownOutcomeProviderName = '';
    _unknownOutcomeOrderKind = null;
    _unknownOutcomeSubmittedAt = null;
  }

  Future<bool> createPackageInvoice() async {
    if (isClosed || _invoiceSubmissionInFlight) return false;
    if (state.createdInvoiceId != null) return false;
    if (state.isInvoiceOutcomeUnknown) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'cart.invoice_outcome_unknown'.tr()),
      );
      return false;
    }
    final packageId = state.checkoutPackageId;
    final branch = state.selectedBranch;
    if (packageId == null) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'Package data is missing.'),
      );
      return false;
    }
    if (branch == null) {
      _emitCartState(
        state.copyWith(createInvoiceError: 'Please choose a branch.'),
      );
      return false;
    }
    final branchIsCurrent = state.checkoutBranches.any(
      (candidate) => candidate.branchId == branch.branchId,
    );
    if (!branchIsCurrent) {
      _emitCartState(
        state.copyWith(
          createInvoiceError: 'cart.selected_branch_unavailable'.tr(),
          resetSelectedBranch: true,
        ),
      );
      return false;
    }

    _invoiceSubmissionInFlight = true;
    try {
      _emitCartState(
        state.copyWith(
          isCreatingInvoice: true,
          resetCreateInvoiceError: true,
          resetCreatedInvoiceId: true,
          resetCreatedInvoicePaymentLink: true,
        ),
      );
      final result = await _invoiceRepository.createFromPackage(
        packageId: packageId,
        providerBranchId: branch.branchId,
        isCash: state.paymentMethod == CartPaymentMethod.cash,
      );
      if (isClosed) return false;
      return result.when<bool>(
        success: (invoice) {
          _emitCartState(
            state.copyWith(
              isCreatingInvoice: false,
              createdInvoiceId: invoice.invoiceId,
              createdInvoicePaymentLink: invoice.paymentLink,
            ),
          );
          return true;
        },
        failure: (error) {
          final outcomeUnknown = error == invoiceOutcomeUnknownFailure;
          _emitCartState(
            state.copyWith(
              isCreatingInvoice: false,
              isInvoiceOutcomeUnknown: outcomeUnknown,
              createInvoiceError: outcomeUnknown
                  ? 'cart.invoice_outcome_unknown'.tr()
                  : error,
            ),
          );
          return false;
        },
      );
    } catch (error) {
      if (!isClosed) {
        _emitCartState(
          state.copyWith(
            isCreatingInvoice: false,
            createInvoiceError: parseApiError(error),
          ),
        );
      }
      return false;
    } finally {
      _invoiceSubmissionInFlight = false;
    }
  }
}
