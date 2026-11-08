part of 'cart_cubit.dart';

/// Cart read/synchronization behavior for [CartCubit].
///
/// The cubit still owns the request generations and confirmed provider cache;
/// this extension only keeps the asynchronous cart-read orchestration in its
/// own file.
extension CartCubitSync on CartCubit {
  Future<void> refreshCart() {
    if (isClosed) return Future.value();
    final ongoing = _cartRefresh;
    if (ongoing != null) return ongoing;
    final load = _performCartRefresh();
    _cartRefresh = load;
    return load.whenComplete(() {
      if (identical(_cartRefresh, load)) _cartRefresh = null;
    });
  }

  Future<void> _refreshAfterCurrent() async {
    final ongoing = _cartRefresh;
    if (ongoing != null) await ongoing;
    if (!isClosed) await refreshCart();
  }

  Future<void> _performCartRefresh() async {
    final requestGeneration = ++_cartRequestGeneration;
    final mutationGeneration = _cartMutationGeneration;
    final result = await _repository.getCart();
    if (isClosed ||
        requestGeneration != _cartRequestGeneration ||
        mutationGeneration != _cartMutationGeneration) {
      return;
    }
    result.when(
      success: (serverCart) {
        final cart = _preserveConfirmedProviders(serverCart);
        if (isClosed) return;
        _emitCartState(
          state.copyWith(
            cart: cart,
            isCartLoading: false,
            resetCartError: true,
          ),
        );
        _broadcastCartSnapshot(cart);
      },
      failure: (error) {
        _emitCartState(state.copyWith(cartError: error, isCartLoading: false));
      },
    );
  }

  Future<ApiResult<Cart>> _getCartWithRetry() async {
    final first = await _repository.getCart();
    final shouldRetry = first.when(success: (_) => false, failure: (_) => true);
    if (!shouldRetry || isClosed) return first;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (isClosed) return first;
    return _repository.getCart();
  }
}
