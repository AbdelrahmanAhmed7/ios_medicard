part of 'cart_cubit.dart';

/// Provider and pharmacy selection behavior for [CartCubit].
///
/// Keeping this as a same-library extension lets the cubit retain ownership
/// of its state and request-generation guards while keeping provider-specific
/// behavior out of the main orchestration file.
extension CartCubitProviderAssignment on CartCubit {
  CartOrderKind? _nextUnassignedOrderKind(Cart? cart) {
    final unassigned = cart?.items.where((item) => item.providerId == null);
    if (unassigned == null) return null;
    if (unassigned.any((item) => item.orderKind == CartOrderKind.services)) {
      return CartOrderKind.services;
    }
    if (unassigned.any((item) => item.orderKind == CartOrderKind.medicines)) {
      return CartOrderKind.medicines;
    }
    return null;
  }

  List<CartItem> _unassignedItemsFor(CartOrderKind orderKind) =>
      state.cart?.items
          .where(
            (item) =>
                item.orderKind == orderKind && item.providerId == null,
          )
          .toList(growable: false) ??
      const <CartItem>[];

  Future<void> loadProviders({CartOrderKind? orderKind}) async {
    final selectionKind =
        orderKind ??
        state.providerSelectionKind ??
        _nextUnassignedOrderKind(state.cart) ??
        CartOrderKind.services;
    _emitCartState(
      state.copyWith(
        isProvidersLoading: true,
        resetProvidersError: true,
        resetSelectedProvider: true,
        providerSelectionKind: selectionKind,
      ),
    );
    final result = await _getAvailableProviders(selectionKind);
    if (isClosed) return;
    result.when(
      success: (providers) {
        _emitCartState(
          state.copyWith(
            providers: providers,
            isProvidersLoading: false,
            resetSelectedProvider: true,
          ),
        );
      },
      failure: (error) {
        _emitCartState(
          state.copyWith(providersError: error, isProvidersLoading: false),
        );
      },
    );
  }

  void selectProvider(ProviderOption provider) {
    _emitCartState(state.copyWith(selectedProvider: provider));
  }

  Future<ApiResult<List<ProviderOption>>> _getAvailableProviders(
    CartOrderKind orderKind,
  ) {
    return orderKind == CartOrderKind.medicines
        ? _repository.getMedicinePharmacies()
        : _repository.getChooseProviders();
  }

  /// Assigns [provider] to every covered cart item of the selected order kind.
  ///
  /// A provider option may also describe items that are already assigned to
  /// that same provider (the cart and choose-providers endpoints both return
  /// those items). In that case there is nothing to update, but the selection
  /// is still valid and checkout should continue for the existing group.
  Future<bool> assignProvider(ProviderOption provider) async {
    if (isClosed || _providerAssignmentInFlight) return false;
    _providerAssignmentInFlight = true;
    _cartMutationGeneration++;
    try {
      _emitCartState(
        state.copyWith(
          selectedProvider: provider,
          isAssigningProvider: true,
          isCartLoading: false,
          resetAssignProviderError: true,
        ),
      );

      final orderKind =
          state.providerSelectionKind ??
          _nextUnassignedOrderKind(state.cart) ??
          CartOrderKind.services;
      final eligibleItems = _unassignedItemsFor(orderKind);
      final eligibleIds = eligibleItems.map((item) => item.cartItemId).toSet();
      final cartItemsById = state.cart == null
          ? null
          : {for (final item in state.cart!.items) item.cartItemId: item};
      final alreadyAssignedToProvider = provider.coveredServices.where(
        (service) =>
            service.cartItemId != 0 &&
            cartItemsById?[service.cartItemId]?.providerId ==
                provider.providerId,
      );
      if (orderKind == CartOrderKind.medicines) {
        final result = await _repository.updateMedicineProvider(
          providerId: provider.providerId,
        );
        if (isClosed) return false;
        final failed = result.when(success: (_) => null, failure: (e) => e);
        if (failed != null) {
          _emitCartState(
            state.copyWith(
              isAssigningProvider: false,
              assignProviderError: failed,
            ),
          );
          return false;
        }
        final refreshed = await _repository.getCart();
        if (isClosed) return false;
        refreshed.when(
          success: (cart) {
            _emitCartState(
              state.copyWith(
                cart: cart,
                selectedProvider: provider,
                checkoutProvider: provider,
                isAssigningProvider: false,
                resetAssignProviderError: true,
              ),
            );
            _broadcastCartSnapshot(cart);
          },
          failure: (error) => _emitCartState(
            state.copyWith(
              isAssigningProvider: false,
              assignProviderError: error,
            ),
          ),
        );
        return true;
      }
      final servicesToUpdate = provider.coveredServices
          .where(
            (service) =>
                service.cartItemId != 0 &&
                eligibleIds.contains(service.cartItemId) &&
                (cartItemsById == null ||
                    cartItemsById[service.cartItemId]?.orderKind == orderKind),
          )
          .toList(growable: false);
      if (servicesToUpdate.isEmpty) {
        if (alreadyAssignedToProvider.isNotEmpty) {
          _emitCartState(
            state.copyWith(
              selectedProvider: provider,
              checkoutProvider: provider,
              isAssigningProvider: false,
              resetAssignProviderError: true,
            ),
          );
          return true;
        }
        _emitCartState(
          state.copyWith(
            isAssigningProvider: false,
            assignProviderError: 'cart.no_eligible_unassigned_items'.tr(),
          ),
        );
        return false;
      }

      final confirmedServices = <ProviderCoveredService>[];
      for (final service in servicesToUpdate) {
        final result = await _repository.updateCartProvider(
          cartId: service.cartItemId,
          providerId: provider.providerId,
        );
        if (isClosed) return false;

        final failed = result.when(
          success: (_) {
            confirmedServices.add(service);
            _cartMutationGeneration++;
            final item = state.cart?.items
                .where((item) => item.cartItemId == service.cartItemId)
                .firstOrNull;
            if (item != null) {
              _confirmedProviderAssignments[item.cartItemId] = item.copyWith(
                providerId: provider.providerId,
                providerName: provider.providerName,
                priceBefore: service.priceBefore,
                priceAfter: service.priceAfter,
                discountPercentage: service.discountPercentage,
              );
            }
            return null;
          },
          failure: (error) => error,
        );
        if (failed != null) {
          final reconciled = await _reconcileAssignedServices(
            provider,
            confirmedServices,
          );
          if (isClosed) return false;
          _emitCartState(
            state.copyWith(
              cart: reconciled,
              isAssigningProvider: false,
              assignProviderError: failed,
            ),
          );
          if (reconciled != null) _broadcastCartSnapshot(reconciled);
          return false;
        }
      }

      final nextCart = await _reconcileAssignedServices(
        provider,
        confirmedServices,
      );
      if (isClosed) return false;
      _emitCartState(
        state.copyWith(
          cart: nextCart,
          isAssigningProvider: false,
          checkoutProvider: provider,
          resetAssignProviderError: true,
        ),
      );
      if (nextCart != null) _broadcastCartSnapshot(nextCart);
      return true;
    } catch (error) {
      if (!isClosed) {
        _emitCartState(
          state.copyWith(
            isAssigningProvider: false,
            assignProviderError: parseApiError(error),
          ),
        );
      }
      return false;
    } finally {
      _providerAssignmentInFlight = false;
    }
  }

  Future<Cart?> _reconcileAssignedServices(
    ProviderOption provider,
    List<ProviderCoveredService> confirmedServices,
  ) async {
    final requestGeneration = ++_cartRequestGeneration;
    final mutationGeneration = _cartMutationGeneration;
    final refreshedCart = await _repository.getCart();
    if (isClosed ||
        requestGeneration != _cartRequestGeneration ||
        mutationGeneration != _cartMutationGeneration) {
      return state.cart;
    }
    return refreshedCart.when(
      success: _preserveConfirmedProviders,
      failure: (_) {
        if (confirmedServices.isEmpty) return state.cart;
        return state.cart?.assignProvider(
          ProviderOption(
            providerId: provider.providerId,
            providerName: provider.providerName,
            providerImageUrl: provider.providerImageUrl,
            coveredCount: confirmedServices.length,
            uncoveredCount: provider.uncoveredCount,
            totalCount: provider.totalCount,
            totalPriceBefore: provider.totalPriceBefore,
            totalPriceAfter: provider.totalPriceAfter,
            coveredServices: confirmedServices,
            uncoveredServices: provider.uncoveredServices,
          ),
        );
      },
    );
  }
}
