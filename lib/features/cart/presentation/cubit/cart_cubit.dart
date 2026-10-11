import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../../../features/activity/domain/repositories/invoice_repository.dart';
import '../../../../features/family_members/data/models/family_member_model.dart';
import '../../../../features/family_members/domain/repository/family_members_repository.dart';
import '../../../../medicard_network/repository/medicard_network_repository.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/provider_option.dart';
import '../../domain/repository/cart_repository.dart';
import '../../domain/services/cart_sync_service.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  final InvoiceRepository _invoiceRepository;
  final FamilyMembersRepository _familyMembersRepository;
  final MedicardNetworkRepository _networkRepository;
  final CartSyncService _cartSyncService;
  final int? providerId;
  StreamSubscription<CartSyncEvent>? _cartSyncSubscription;
  Future<void>? _cartRefresh;

  CartCubit(
    this._repository,
    this._invoiceRepository,
    this._familyMembersRepository,
    this._networkRepository, {
    required CartSyncService cartSyncService,
    this.providerId,
  }) : _cartSyncService = cartSyncService,
       super(const CartState()) {
    // Every CartCubit instance (cart screen, provider page, search, …)
    // re-syncs whenever any of them mutates the cart, so no screen keeps
    // stale items.
    _cartSyncSubscription = _cartSyncService.stream.listen(
      (_) => refreshCart(),
    );
  }

  @override
  Future<void> close() {
    _cartSyncSubscription?.cancel();
    return super.close();
  }

  /// Silent cart re-fetch (no loading shimmer): converges every instance to
  /// the server truth after any mutation, local or remote. Concurrent calls
  /// join the in-flight request instead of stacking up.
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

  Future<void> _performCartRefresh() async {
    final result = await _repository.getCart();
    if (isClosed) return;
    result.when(
      success: (cart) {
        if (isClosed) return;
        emit(
          state.copyWith(
            cart: cart,
            isCartLoading: false,
            resetCartError: true,
          ),
        );
      },
      failure: (_) {},
    );
  }

  Future<void> loadCategoryServices(int categoryId) async {
    emit(
      state.copyWith(
        isCategoryServicesLoading: true,
        resetCategoryServicesError: true,
      ),
    );
    final result = await _repository.getCategoryServices(categoryId);
    if (isClosed) return;
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
    if (isClosed) return;

    result.when(
      success: (_) {
        // Reload category services to get updated isSelected
        loadCategoryServices(categoryId);
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
        );
        emit(state.copyWith(pendingServiceIds: newPendingIds));
        // Pull the server truth so this instance's cart list updates too.
        unawaited(refreshCart());
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
    if (isClosed) return;
    // Remove from pending regardless of result
    final newPendingIds = Set<int>.from(state.pendingServiceIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        final nextCart = state.cart?.removeService(serviceId);
        emit(
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
        // Confirm against the server truth on top of the optimistic update.
        unawaited(refreshCart());
        loadCategoryServices(categoryId);
      },
      failure: (error) {
        emit(state.copyWith(pendingServiceIds: newPendingIds));
      },
    );
  }

  Future<void> loadCart() async {
    if (isClosed) return;
    emit(state.copyWith(isCartLoading: true, resetCartError: true));
    final result = await _getCartWithRetry();
    if (isClosed) return;
    result.when(
      success: (cart) {
        emit(
          state.copyWith(
            cart: cart,
            isCartLoading: false,
            resetCartError: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(cartError: error, isCartLoading: false));
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

  Future<void> loadCartAndProviders() async {
    emit(
      state.copyWith(
        isCartLoading: true,
        isProvidersLoading: true,
        providers: const [],
        resetCartError: true,
        resetProvidersError: true,
        resetSelectedProvider: true,
      ),
    );

    final cartResult = await _repository.getCart();
    if (isClosed) return;
    cartResult.when(
      success: (cart) {
        emit(state.copyWith(cart: cart, isCartLoading: false));
      },
      failure: (error) {
        emit(state.copyWith(cartError: error, isCartLoading: false));
      },
    );

    final providersResult = await _repository.getChooseProviders();
    if (isClosed) return;
    providersResult.when(
      success: (providers) {
        emit(
          state.copyWith(
            providers: providers,
            isProvidersLoading: false,
            resetProvidersError: true,
            resetSelectedProvider: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(providersError: error, isProvidersLoading: false));
      },
    );
  }

  Future<void> clearCart() async {
    if (isClosed) return;
    emit(state.copyWith(isCartLoading: true, resetCartError: true));
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
        emit(
          state.copyWith(
            cart: const Cart.empty(),
            isCartLoading: false,
            resetCartError: true,
          ),
        );
        _cartSyncService.cartCleared();
        loadCart();
      },
      failure: (error) {
        emit(state.copyWith(cartError: error, isCartLoading: false));
      },
    );
  }

  // ── Choose Providers ────────────────────────────────────────────────────────

  Future<void> loadProviders() async {
    emit(
      state.copyWith(
        isProvidersLoading: true,
        resetProvidersError: true,
        resetSelectedProvider: true,
      ),
    );
    final result = await _repository.getChooseProviders();
    if (isClosed) return;
    result.when(
      success: (providers) {
        emit(
          state.copyWith(
            providers: providers,
            isProvidersLoading: false,
            resetSelectedProvider: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(providersError: error, isProvidersLoading: false));
      },
    );
  }

  void selectProvider(ProviderOption provider) {
    emit(state.copyWith(selectedProvider: provider));
  }

  void selectCheckoutBranch(ProviderBranch branch) {
    emit(state.copyWith(selectedBranch: branch));
  }

  void selectFamilyMember(FamilyMemberModel? member) {
    emit(
      state.copyWith(
        selectedFamilyMember: member,
        resetSelectedFamilyMember: member == null,
      ),
    );
  }

  void selectPaymentMethod(CartPaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<void> loadCheckout({
    int? initialProviderId,
    ProviderBranch? initialBranch,
    int? packageId,
    String? packageName,
    double? packagePriceBefore,
    double? packagePriceAfter,
  }) async {
    emit(
      state.copyWith(
        isCheckoutLoading: true,
        isFamilyMembersLoading: true,
        resetCheckoutError: true,
        resetFamilyMembersError: true,
        resetCreateInvoiceError: true,
        resetCreatedInvoiceId: true,
        resetCreatedInvoicePaymentLink: true,
        checkoutPackageId: packageId,
        checkoutPackageName: packageName,
        checkoutPackagePriceBefore: packagePriceBefore,
        checkoutPackagePriceAfter: packagePriceAfter,
      ),
    );

    Cart? cart = state.cart;
    if (cart == null && packageId == null) {
      final cartResult = await _repository.getCart();
      if (isClosed) return;
      final failed = cartResult.when(
        success: (loadedCart) {
          cart = loadedCart;
          emit(state.copyWith(cart: loadedCart, isCartLoading: false));
          return null;
        },
        failure: (error) => error,
      );
      if (failed != null) {
        emit(
          state.copyWith(
            isCheckoutLoading: false,
            isFamilyMembersLoading: false,
            checkoutError: failed,
          ),
        );
        return;
      }
    }

    final selectedProvider = _resolveCheckoutProvider(
      cart: cart,
      initialProviderId: initialProviderId ?? providerId,
    );
    final checkoutProvider =
        selectedProvider ??
        await _loadProviderOption(initialProviderId ?? providerId);
    if (isClosed) return;

    if (checkoutProvider == null) {
      emit(
        state.copyWith(
          isCheckoutLoading: false,
          checkoutError: 'Please choose a provider first.',
        ),
      );
      await loadFamilyMembers();
      return;
    }

    emit(state.copyWith(checkoutProvider: checkoutProvider));
    await Future.wait([
      loadProviderBranches(
        checkoutProvider.providerId,
        initialBranch: initialBranch,
      ),
      loadFamilyMembers(),
    ]);
  }

  Future<ProviderOption?> _loadProviderOption(int? providerId) async {
    if (providerId == null) return null;
    final result = await _networkRepository.getProviderPage(
      providerId: providerId,
    );
    return result.maybeWhen(
      success: (response) {
        final data = response.data;
        if (data == null) return null;
        return ProviderOption(
          providerId: data.id,
          providerName: data.name,
          coveredCount: 1,
          uncoveredCount: 0,
          totalCount: 1,
          totalPriceBefore: state.checkoutPackagePriceBefore ?? 0,
          totalPriceAfter:
              state.checkoutPackagePriceAfter ??
              state.checkoutPackagePriceBefore ??
              0,
          coveredServices: const [],
          uncoveredServices: const [],
        );
      },
      orElse: () => null,
    );
  }

  ProviderOption? _resolveCheckoutProvider({
    required Cart? cart,
    required int? initialProviderId,
  }) {
    final explicitProviderId =
        initialProviderId ?? state.checkoutProvider?.providerId;
    if (explicitProviderId != null) {
      final fromSelected = state.selectedProvider;
      if (fromSelected?.providerId == explicitProviderId) return fromSelected;

      final fromCheckout = state.checkoutProvider;
      if (fromCheckout?.providerId == explicitProviderId) return fromCheckout;

      for (final provider in state.providers) {
        if (provider.providerId == explicitProviderId) return provider;
      }
    }

    if (state.selectedProvider != null) return state.selectedProvider;
    if (state.checkoutProvider != null) return state.checkoutProvider;

    final items = cart?.items ?? const <CartItem>[];
    final providerIds = items
        .where((item) => item.providerId != null)
        .map((item) => item.providerId!)
        .toSet();

    if (providerIds.isEmpty) return null;

    final targetProviderId =
        explicitProviderId != null && providerIds.contains(explicitProviderId)
        ? explicitProviderId
        : providerIds.first;
    final providerItems = items
        .where((item) => item.providerId == targetProviderId)
        .toList();
    if (providerItems.isEmpty) return null;

    return _providerFromCartItems(targetProviderId, providerItems);
  }

  ProviderOption _providerFromCartItems(int providerId, List<CartItem> items) {
    String providerName = 'Selected provider';
    for (final item in items) {
      if (item.providerName?.isNotEmpty == true) {
        providerName = item.providerName!;
        break;
      }
    }
    final totalPriceBefore = items.fold<double>(
      0,
      (sum, item) => sum + (item.priceBefore ?? item.priceAfter ?? 0),
    );
    final totalPriceAfter = items.fold<double>(
      0,
      (sum, item) => sum + (item.priceAfter ?? item.priceBefore ?? 0),
    );
    return ProviderOption(
      providerId: providerId,
      providerName: providerName,
      coveredCount: items.length,
      uncoveredCount: 0,
      totalCount: items.length,
      totalPriceBefore: totalPriceBefore,
      totalPriceAfter: totalPriceAfter,
      coveredServices: const [],
      uncoveredServices: const [],
    );
  }

  Future<void> loadProviderBranches(
    int providerId, {
    ProviderBranch? initialBranch,
  }) async {
    if (isClosed) return;
    emit(
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
    if (isClosed) return;
    result.when(
      success: (branches) {
        ProviderBranch? selected;
        if (branches.isNotEmpty) {
          selected = branches.first;
          if (initialBranch != null) {
            for (final branch in branches) {
              if (branch.branchId == initialBranch.branchId) {
                selected = branch;
                break;
              }
            }
          }
        } else {
          selected = initialBranch;
        }

        emit(
          state.copyWith(
            checkoutBranches: branches,
            selectedBranch: selected,
            isCheckoutLoading: false,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(checkoutError: error, isCheckoutLoading: false));
      },
    );
  }

  Future<void> loadFamilyMembers() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        isFamilyMembersLoading: true,
        resetFamilyMembersError: true,
      ),
    );
    try {
      final members = await _familyMembersRepository.getFamilyMembers();
      if (isClosed) return;
      emit(
        state.copyWith(familyMembers: members, isFamilyMembersLoading: false),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          familyMembersError: parseApiError(error),
          isFamilyMembersLoading: false,
        ),
      );
    }
  }

  Future<bool> createCartInvoice() async {
    if (isClosed) return false;
    final provider = state.checkoutProvider;
    final branch = state.selectedBranch;
    if (provider == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a provider.'));
      return false;
    }
    if (branch == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a branch.'));
      return false;
    }
    emit(
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
    final success = result.when(
      success: (invoice) {
        emit(
          state.copyWith(
            cart: const Cart.empty(),
            isCreatingInvoice: false,
            createdInvoiceId: invoice.invoiceId,
            createdInvoicePaymentLink: invoice.paymentLink,
          ),
        );
        _cartSyncService.cartCleared();
        _syncCartAfterInvoiceCreation();
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(isCreatingInvoice: false, createInvoiceError: error),
        );
        return false;
      },
    );
    return success;
  }

  Future<bool> createPackageInvoice() async {
    if (isClosed) return false;
    final packageId = state.checkoutPackageId;
    final branch = state.selectedBranch;
    if (packageId == null) {
      emit(state.copyWith(createInvoiceError: 'Package data is missing.'));
      return false;
    }
    if (branch == null) {
      emit(state.copyWith(createInvoiceError: 'Please choose a branch.'));
      return false;
    }
    emit(
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
    return result.when(
      success: (invoice) {
        emit(
          state.copyWith(
            isCreatingInvoice: false,
            createdInvoiceId: invoice.invoiceId,
            createdInvoicePaymentLink: invoice.paymentLink,
          ),
        );
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(isCreatingInvoice: false, createInvoiceError: error),
        );
        return false;
      },
    );
  }

  Future<void> _syncCartAfterInvoiceCreation() async {
    final result = await _repository.getCart();
    if (isClosed) return;
    result.when(
      success: (cart) => emit(state.copyWith(cart: cart)),
      // Post-invoice background refresh: logged, never toasted — the invoice
      // already succeeded and nagging here would be noise.
      failure: (message) {
        if (kDebugMode) {
          debugPrint('[CartCubit] post-invoice cart sync: $message');
        }
      },
    );
  }

  /// Assigns [provider] to all uncovered services in the cart by calling
  /// addToCart for each service that still has no provider.
  Future<bool> assignProvider(ProviderOption provider) async {
    emit(
      state.copyWith(
        selectedProvider: provider,
        isAssigningProvider: true,
        resetAssignProviderError: true,
      ),
    );

    final unassignedCartItemIds = state.cart?.items
        .where((item) => item.providerId == null)
        .map((item) => item.cartItemId)
        .toSet();
    final servicesToUpdate = provider.coveredServices.where(
      (service) =>
          service.cartItemId != 0 &&
          (unassignedCartItemIds == null ||
              unassignedCartItemIds.contains(service.cartItemId)),
    );

    for (final service in servicesToUpdate) {
      if (service.cartItemId == 0) continue;

      final result = await _repository.updateCartProvider(
        cartId: service.cartItemId,
        providerId: provider.providerId,
      );
      if (isClosed) return false;

      final failed = result.when(
        success: (_) => null,
        failure: (error) => error,
      );
      if (failed != null) {
        emit(
          state.copyWith(
            isAssigningProvider: false,
            assignProviderError: failed,
          ),
        );
        return false;
      }
    }

    final refreshedCart = await _repository.getCart();
    if (isClosed) return false;
    final nextCart = refreshedCart.when(
      success: (cart) => cart,
      failure: (_) => state.cart?.assignProvider(provider),
    );

    emit(
      state.copyWith(
        cart: nextCart,
        isAssigningProvider: false,
        checkoutProvider: provider,
        resetAssignProviderError: true,
      ),
    );
    return true;
  }
}
