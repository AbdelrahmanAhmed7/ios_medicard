import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../domain/models/provider_option.dart';
import '../../domain/repository/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  final int? providerId;

  CartCubit(this._repository, {this.providerId}) : super(const CartState());

  Future<void> loadCategoryServices(int categoryId) async {
    emit(
      state.copyWith(
        isCategoryServicesLoading: true,
        resetCategoryServicesError: true,
      ),
    );
    final result = await _repository.getCategoryServices(categoryId);
    result.when(
      success: (categoryServices) {
        emit(
          state.copyWith(
            categoryServices: categoryServices,
            isCategoryServicesLoading: false,
          ),
        );
      },
      failure: (error) {
        emit(
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
    // Add to pending
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.addToCart(
      serviceId: serviceId,
      categoryId: categoryId,
      providerId: providerId,
    );
    // Remove from pending regardless of result
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        // Reload category services to get updated isSelected
        loadCategoryServices(categoryId);
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
      failure: (error) {
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> removeFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    // Add to pending
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
      ),
    );

    final result = await _repository.removeFromCart(serviceId);
    // Remove from pending regardless of result
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        // Reload category services to get updated isSelected
        loadCategoryServices(categoryId);
      },
      failure: (error) {
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> loadCart() async {
    emit(state.copyWith(isCartLoading: true, resetCartError: true));
    final result = await _repository.getCart();
    result.when(
      success: (cart) {
        emit(state.copyWith(cart: cart, isCartLoading: false));
      },
      failure: (error) {
        emit(state.copyWith(cartError: error, isCartLoading: false));
      },
    );
  }

  Future<void> clearCart() async {
    await _repository.clearCart();
    // Reload the cart so the UI reflects the cleared state.
    await loadCart();
  }

  // ── Choose Providers ────────────────────────────────────────────────────────

  Future<void> loadProviders() async {
    emit(state.copyWith(isProvidersLoading: true, resetProvidersError: true));
    final result = await _repository.getChooseProviders();
    result.when(
      success: (providers) {
        emit(state.copyWith(providers: providers, isProvidersLoading: false));
      },
      failure: (error) {
        emit(state.copyWith(providersError: error, isProvidersLoading: false));
      },
    );
  }

  void selectProvider(ProviderOption provider) {
    emit(state.copyWith(selectedProvider: provider));
  }

  /// Assigns [provider] to all uncovered services in the cart by calling
  /// addToCart for each service that still has no provider.
  Future<void> assignProvider(ProviderOption provider) async {
    // Mark this provider as selected immediately so the UI updates.
    emit(state.copyWith(selectedProvider: provider));

    // Add each covered service to the cart with this providerId.
    for (final service in provider.coveredServices) {
      final cartItem = state.cart?.items.firstWhere(
        (i) => i.serviceId == service.serviceId,
        orElse: () => state.cart!.items.first,
      );
      if (cartItem == null) continue;

      await _repository.addToCart(
        serviceId: service.serviceId,
        categoryId: cartItem.categoryId,
        providerId: provider.providerId,
      );
    }

    // Refresh the cart to show updated provider info.
    await loadCart();
  }
}
