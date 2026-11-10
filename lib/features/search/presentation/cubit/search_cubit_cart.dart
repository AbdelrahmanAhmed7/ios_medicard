// These extensions are part of SearchCubit's library and intentionally call
// Cubit.emit to keep each responsibility in a focused file.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'search_cubit.dart';

extension SearchCubitCart on SearchCubit {
  Future<void> addServiceToCart({
    required int serviceId,
    required int categoryId,
    int quantity = 1,
  }) async {
    if (isClosed) return;
    if (!_enableCartFeatures) {
      emit(state.copyWith(cartActionError: 'auth.please_login_first'.tr()));
      return;
    }
    if (serviceId <= 0 || categoryId <= 0) {
      emit(
        state.copyWith(
          cartActionError:
              'Service data is incomplete. Please refresh and try again.',
        ),
      );
      return;
    }
    if (state.pendingServiceIds.contains(serviceId)) {
      if (kDebugMode) {
        debugPrint('[SearchCubit] duplicate add ignored service=$serviceId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[SearchCubit] add service started service=$serviceId');
    }
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
        clearCartActionError: true,
      ),
    );

    final result = categoryId == 1
        ? await _cartRepository.addMedicineToCart(
            serviceId: serviceId,
            categoryId: categoryId,
            quantity: quantity,
          )
        : await _cartRepository.addToCart(
            serviceId: serviceId,
            categoryId: categoryId,
            providerId: null,
            cardNumber: null,
            price: null,
          );

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingServiceIds)..remove(serviceId);

    result.when(
      success: (_) {
        _emitLocalServiceSelection(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
          pendingServiceIds: pending,
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
        );
        _loadCartCounters();
      },
      failure: (message) {
        final alreadyInCart =
            message.contains('ServiceAlreadyInCart') ||
            message.toLowerCase().contains('already');
        if (alreadyInCart) {
          _emitLocalServiceSelection(
            serviceId: serviceId,
            categoryId: categoryId,
            isSelected: true,
            pendingServiceIds: pending,
          );
          _cartSyncService.serviceSelectionChanged(
            serviceId: serviceId,
            categoryId: categoryId,
            isSelected: true,
          );
          return;
        }
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] add service failed service=$serviceId message=$message',
          );
        }
        emit(
          state.copyWith(pendingServiceIds: pending, cartActionError: message),
        );
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
    final result = await _cartRepository.updateMedicineQuantity(
      serviceId: serviceId,
      quantity: quantity,
    );
    if (isClosed) return;
    result.when(
      success: (_) => _loadCartCounters(),
      failure: (message) => emit(state.copyWith(cartActionError: message)),
    );
  }

  /// UI errors are one-shot events. Clearing after presentation prevents an
  /// unrelated state update from presenting the same message again.
  void consumeCartActionError() {
    if (isClosed || state.cartActionError == null) return;
    emit(state.copyWith(clearCartActionError: true));
  }

  Future<void> removeServiceFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    if (isClosed) return;
    if (!_enableCartFeatures) {
      emit(state.copyWith(cartActionError: 'auth.please_login_first'.tr()));
      return;
    }
    if (serviceId <= 0 || categoryId <= 0) {
      emit(
        state.copyWith(
          cartActionError:
              'Service data is incomplete. Please refresh and try again.',
        ),
      );
      return;
    }
    if (state.pendingServiceIds.contains(serviceId)) {
      if (kDebugMode) {
        debugPrint('[SearchCubit] duplicate remove ignored service=$serviceId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[SearchCubit] remove service started service=$serviceId');
    }
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
        clearCartActionError: true,
      ),
    );

    final result = await _cartRepository.removeFromCart(serviceId);

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingServiceIds)..remove(serviceId);

    result.when(
      success: (_) {
        _emitLocalServiceSelection(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
          pendingServiceIds: pending,
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
        );
        _loadCartCounters();
      },
      failure: (message) {
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] remove service failed service=$serviceId message=$message',
          );
        }
        emit(
          state.copyWith(pendingServiceIds: pending, cartActionError: message),
        );
      },
    );
  }
}
