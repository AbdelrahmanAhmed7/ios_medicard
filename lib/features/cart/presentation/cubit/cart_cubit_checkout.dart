part of 'cart_cubit.dart';

/// Checkout preparation behavior for [CartCubit].
extension CartCubitCheckout on CartCubit {
  void selectCheckoutBranch(ProviderBranch branch) {
    _emitCartState(state.copyWith(selectedBranch: branch));
  }

  void selectFamilyMember(FamilyMemberModel? member) {
    _emitCartState(
      state.copyWith(
        selectedFamilyMember: member,
        resetSelectedFamilyMember: member == null,
      ),
    );
  }

  void selectPaymentMethod(CartPaymentMethod method) {
    _emitCartState(state.copyWith(paymentMethod: method));
  }

  Future<void> loadCheckout({
    int? initialProviderId,
    CartOrderKind? orderKind,
    String? initialProviderName,
    ProviderBranch? initialBranch,
    int? packageId,
    String? packageName,
    List<String> packageServiceNames = const [],
    double? packagePriceBefore,
    double? packagePriceAfter,
  }) async {
    _emitCartState(
      state.copyWith(
        isCheckoutLoading: true,
        isFamilyMembersLoading: true,
        resetCheckoutProvider: true,
        resetCheckoutOrderKind: packageId != null,
        resetSelectedBranch: true,
        checkoutBranches: const [],
        resetCheckoutError: true,
        resetFamilyMembersError: true,
        resetCreateInvoiceError: true,
        resetCreatedInvoiceId: true,
        resetCreatedInvoicePaymentLink: true,
        checkoutPackageId: packageId,
        checkoutPackageName: packageName,
        checkoutPackageServiceNames: packageServiceNames,
        checkoutPackagePriceBefore: packagePriceBefore,
        checkoutPackagePriceAfter: packagePriceAfter,
      ),
    );

    Cart? cart = state.cart;
    if (cart == null && packageId == null) {
      final requestGeneration = ++_cartRequestGeneration;
      final mutationGeneration = _cartMutationGeneration;
      final cartResult = await _repository.getCart();
      if (isClosed ||
          requestGeneration != _cartRequestGeneration ||
          mutationGeneration != _cartMutationGeneration) {
        return;
      }
      final failed = cartResult.when(
        success: (serverCart) {
          final loadedCart = _preserveConfirmedProviders(serverCart);
          cart = loadedCart;
          _emitCartState(
            state.copyWith(cart: loadedCart, isCartLoading: false),
          );
          _broadcastCartSnapshot(loadedCart);
          return null;
        },
        failure: (error) => error,
      );
      if (failed != null) {
        _emitCartState(
          state.copyWith(
            isCheckoutLoading: false,
            isFamilyMembersLoading: false,
            checkoutError: failed,
          ),
        );
        return;
      }
    }

    final targetProviderId = initialProviderId ?? providerId;
    final resolvedOrderKind = packageId == null
        ? orderKind ?? _orderKindForProvider(cart, targetProviderId)
        : null;
    final checkoutProvider = packageId != null && targetProviderId != null
        ? _packageCheckoutProvider(
            providerId: targetProviderId,
            providerName: initialProviderName,
          )
        : await _resolveCheckoutProvider(
            cart: cart,
            initialProviderId: targetProviderId,
            orderKind: resolvedOrderKind,
          );
    if (isClosed) return;

    if (checkoutProvider == null) {
      _emitCartState(
        state.copyWith(
          isCheckoutLoading: false,
          checkoutError: 'Please choose a provider first.',
        ),
      );
      await loadFamilyMembers();
      return;
    }

    if (packageId == null &&
        (checkoutProvider.coveredCount == 0 ||
            !checkoutProvider.coversAll ||
            checkoutProvider.hasMissingPrices)) {
      _emitCartState(
        state.copyWith(
          isCheckoutLoading: false,
          resetCheckoutProvider: true,
          checkoutError:
              (checkoutProvider.hasMissingPrices
                      ? 'cart.some_prices_missing'
                      : 'cart.service_not_available')
                  .tr(),
        ),
      );
      await loadFamilyMembers();
      return;
    }

    _emitCartState(
      state.copyWith(
        checkoutProvider: checkoutProvider,
        checkoutOrderKind: resolvedOrderKind,
      ),
    );
    await Future.wait([
      loadProviderBranches(
        checkoutProvider.providerId,
        initialBranch: initialBranch,
      ),
      loadFamilyMembers(),
    ]);
  }

  ProviderOption _packageCheckoutProvider({
    required int providerId,
    String? providerName,
  }) {
    return ProviderOption(
      providerId: providerId,
      providerName: providerName?.trim() ?? '',
      coveredCount: 0,
      uncoveredCount: 0,
      totalCount: 0,
      totalPriceBefore: 0,
      totalPriceAfter: 0,
      coveredServices: const [],
      uncoveredServices: const [],
    );
  }

  Future<ProviderOption?> _resolveCheckoutProvider({
    required Cart? cart,
    required int? initialProviderId,
    required CartOrderKind? orderKind,
  }) async {
    final targetId =
        initialProviderId ??
        state.selectedProvider?.providerId ??
        _singleCartProviderId(cart);
    if (targetId == null) return null;
    final targetKind = orderKind ?? _orderKindForProvider(cart, targetId);
    if (targetKind == null) return null;
    return _freshProviderOption(targetId, targetKind);
  }

  CartOrderKind? _orderKindForProvider(Cart? cart, int? providerId) {
    if (providerId == null) return null;
    final kinds = {
      for (final item in cart?.items ?? const <CartItem>[])
        if (item.providerId == providerId) item.orderKind,
    };
    return kinds.length == 1 ? kinds.first : null;
  }

  int? _singleCartProviderId(Cart? cart) {
    final ids = {
      for (final item in cart?.items ?? const <CartItem>[])
        if (item.providerId != null) item.providerId!,
    };
    return ids.length == 1 ? ids.first : null;
  }

  Future<ProviderOption?> _freshProviderOption(
    int providerId,
    CartOrderKind orderKind,
  ) async {
    final result = await _getAvailableProviders(orderKind);
    if (isClosed) return null;
    return result.when<ProviderOption?>(
      success: (providers) {
        if (isClosed) return null;
        ProviderOption? match;
        for (final p in providers) {
          if (p.providerId == providerId) {
            final orderItems =
                state.cart?.items
                    .where(
                      (item) =>
                          item.providerId == providerId &&
                          item.orderKind == orderKind,
                    )
                    .toList() ??
                <CartItem>[];
            if (orderItems.isNotEmpty) match = p.forItems(orderItems);
          }
        }
        _emitCartState(
          state.copyWith(
            providers: providers,
            isProvidersLoading: false,
            selectedProvider: match ?? state.selectedProvider,
          ),
        );
        return match;
      },
      failure: (_) => null,
    );
  }

  Future<void> loadProviderBranches(
    int providerId, {
    ProviderBranch? initialBranch,
  }) async {
    if (isClosed) return;
    final requestGeneration = ++_branchRequestGeneration;
    _emitCartState(
      state.copyWith(
        isCheckoutLoading: true,
        resetCheckoutError: true,
        checkoutBranches: const [],
        resetSelectedBranch: true,
      ),
    );
    final result = await _networkRepository.getProviderBranchLocations(
      providerId: providerId,
    );
    if (isClosed || requestGeneration != _branchRequestGeneration) return;
    result.when(
      success: (branches) {
        ProviderBranch? selected;
        if (branches.isNotEmpty) {
          if (branches.length == 1) selected = branches.first;
          if (initialBranch != null) {
            for (final branch in branches) {
              if (branch.branchId == initialBranch.branchId) {
                selected = branch;
                break;
              }
            }
          }
        }

        _emitCartState(
          state.copyWith(
            checkoutBranches: branches,
            selectedBranch: selected,
            isCheckoutLoading: false,
          ),
        );
      },
      failure: (_) {
        _emitCartState(
          state.copyWith(
            checkoutBranches: const [],
            resetSelectedBranch: true,
            checkoutError: 'cart.branch_load_error'.tr(),
            isCheckoutLoading: false,
          ),
        );
      },
    );
  }

  Future<void> loadFamilyMembers() async {
    if (isClosed) return;
    _emitCartState(
      state.copyWith(
        isFamilyMembersLoading: true,
        resetFamilyMembersError: true,
      ),
    );
    try {
      final members = await _familyMembersRepository.getFamilyMembers();
      if (isClosed) return;
      _emitCartState(
        state.copyWith(familyMembers: members, isFamilyMembersLoading: false),
      );
    } catch (error) {
      if (isClosed) return;
      _emitCartState(
        state.copyWith(
          familyMembersError: parseApiError(error),
          isFamilyMembersLoading: false,
        ),
      );
    }
  }
}
