part of 'cart_cubit.dart';

/// Service selection and cart mutation behavior for [CartCubit].
extension CartCubitOperations on CartCubit {
  Future<void> loadCategoryServices(int categoryId) async {
    _emitCartState(
      state.copyWith(
        isCategoryServicesLoading: true,
        resetCategoryServicesError: true,
      ),
    );
    final result = await _repository.getCategoryServices(categoryId);
    if (isClosed) return;
    result.when(
      success: (categoryServices) {
        _emitCartState(
          state.copyWith(
            categoryServices: categoryServices,
            isCategoryServicesLoading: false,
          ),
        );
      },
      failure: (error) {
        _emitCartState(
          state.copyWith(
            categoryServicesError: error,
            isCategoryServicesLoading: false,
          ),
        );
      },
    );
  }

  Future<void> addToCart({
    required int serviceId,
    required int categoryId,
  }) async {
    _emitCartState(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.addToCart(
      serviceId: serviceId,
      categoryId: categoryId,
      providerId: providerId,
    );
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);
    if (isClosed) return;

    result.when(
      success: (_) {
        loadCategoryServices(categoryId);
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
        );
        _emitCartState(state.copyWith(pendingServiceIds: newPendingIds));
        unawaited(refreshCart());
      },
      failure: (_) {
        _emitCartState(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> removeFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    _emitCartState(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.removeFromCart(serviceId);
    if (isClosed) return;
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        final nextCart = state.cart?.removeService(serviceId);
        _confirmedProviderAssignments.removeWhere(
          (_, item) => item.serviceId == serviceId,
        );
        _emitCartState(
          state.copyWith(
            cart: nextCart,
            pendingServiceIds: newPendingIds,
            resetCartError: true,
          ),
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
        );
        unawaited(refreshCart());
        loadCategoryServices(categoryId);
      },
      failure: (_) {
        _emitCartState(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> updateMedicineQuantity({
    required int serviceId,
    required int quantity,
  }) {
    if (isClosed || quantity < 1) return Future<void>.value();
    final previous =
        _medicineQuantityUpdates[serviceId] ?? Future<void>.value();
    final operation = previous.then(
      (_) => _performMedicineQuantityUpdate(
        serviceId: serviceId,
        quantity: quantity,
      ),
    );
    late final Future<void> queued;
    queued = operation.whenComplete(() {
      if (identical(_medicineQuantityUpdates[serviceId], queued)) {
        _medicineQuantityUpdates.remove(serviceId);
      }
    });
    _medicineQuantityUpdates[serviceId] = queued;
    return queued;
  }

  Future<void> _performMedicineQuantityUpdate({
    required int serviceId,
    required int quantity,
  }) async {
    final result = await _repository.updateMedicineQuantity(
      serviceId: serviceId,
      quantity: quantity,
    );
    if (isClosed) return;
    result.when(
      success: (_) => loadCart(),
      failure: (error) => _emitCartState(state.copyWith(cartError: error)),
    );
  }

  Future<void> clearCart() async {
    if (isClosed) return;
    _emitCartState(state.copyWith(isCartLoading: true, resetCartError: true));
    final result = await _repository.clearCart();
    if (isClosed) return;
    if (kDebugMode) {
      result.when(
        success: (_) => debugPrint('[CartCubit] clearCart succeeded'),
        failure: (err) => debugPrint('[CartCubit] clearCart failed: $err'),
      );
    }
    result.when(
      success: (_) {
        _confirmedProviderAssignments.clear();
        _cartMutationGeneration++;
        _emitCartState(
          state.copyWith(
            cart: const Cart.empty(),
            isCartLoading: false,
            resetCartError: true,
          ),
        );
        _cartSyncService.cartCleared();
      },
      failure: (error) {
        _emitCartState(state.copyWith(cartError: error, isCartLoading: false));
      },
    );
  }
}
