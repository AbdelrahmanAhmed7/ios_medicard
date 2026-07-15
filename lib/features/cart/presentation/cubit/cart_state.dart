import '../../domain/models/cart.dart';
import '../../domain/models/category_services.dart';
import '../../domain/models/provider_option.dart';

class CartState {
  final Cart? cart;
  final bool isCartLoading;
  final String? cartError;
  final CategoryServices? categoryServices;
  final bool isCategoryServicesLoading;
  final String? categoryServicesError;
  final Set<int> pendingServiceIds;

  // choose-providers state
  final List<ProviderOption> providers;
  final bool isProvidersLoading;
  final String? providersError;

  /// The provider the user has selected in the choose-provider screen.
  final ProviderOption? selectedProvider;

  const CartState({
    this.cart,
    this.isCartLoading = false,
    this.cartError,
    this.categoryServices,
    this.isCategoryServicesLoading = false,
    this.categoryServicesError,
    this.pendingServiceIds = const {},
    this.providers = const [],
    this.isProvidersLoading = false,
    this.providersError,
    this.selectedProvider,
  });

  CartState copyWith({
    Cart? cart,
    bool? isCartLoading,
    String? cartError,
    bool resetCartError = false,
    CategoryServices? categoryServices,
    bool? isCategoryServicesLoading,
    String? categoryServicesError,
    bool resetCategoryServicesError = false,
    Set<int>? pendingServiceIds,
    List<ProviderOption>? providers,
    bool? isProvidersLoading,
    String? providersError,
    bool resetProvidersError = false,
    ProviderOption? selectedProvider,
    bool resetSelectedProvider = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isCartLoading: isCartLoading ?? this.isCartLoading,
      cartError: resetCartError ? null : (cartError ?? this.cartError),
      categoryServices: categoryServices ?? this.categoryServices,
      isCategoryServicesLoading:
          isCategoryServicesLoading ?? this.isCategoryServicesLoading,
      categoryServicesError: resetCategoryServicesError
          ? null
          : (categoryServicesError ?? this.categoryServicesError),
      pendingServiceIds: pendingServiceIds ?? this.pendingServiceIds,
      providers: providers ?? this.providers,
      isProvidersLoading: isProvidersLoading ?? this.isProvidersLoading,
      providersError: resetProvidersError
          ? null
          : (providersError ?? this.providersError),
      selectedProvider: resetSelectedProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
    );
  }
}
