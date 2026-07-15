import '../../features/cart/domain/models/cart_item.dart';
import '../../features/cart/domain/models/category_services.dart';
import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';

export '../../features/cart/domain/models/cart_item.dart';

enum ProviderViewType { services, packages }

/// A loaded category tab entry — holds the category identity, its services,
/// and how many of those services are currently selected (in cart).
class CategoryTab {
  final int categoryId;
  final String categoryName;
  final CategoryServices? services;
  final bool isLoading;
  final String? error;

  const CategoryTab({
    required this.categoryId,
    required this.categoryName,
    this.services,
    this.isLoading = false,
    this.error,
  });

  /// Number of services selected (in cart) for this category.
  int get selectedCount => services?.totalSelectedCount ?? 0;

  CategoryTab copyWith({
    CategoryServices? services,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CategoryTab(
      categoryId: categoryId,
      categoryName: categoryName,
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProviderPageState {
  // ── Provider data ──────────────────────────────────────────────────────────
  final ProviderPageData? providerData;
  final bool isProviderLoading;
  final String? providerError;

  // ── Category tabs (used when currentView == services) ─────────────────────
  /// Ordered list of category tabs for this provider.
  /// Populated once the provider page loads and we know the categoryId(s).
  final List<CategoryTab> categoryTabs;

  /// Index of the currently selected category tab.
  final int selectedCategoryIndex;

  // ── Services (legacy flat list — kept for backwards compat) ───────────────
  final List<ProviderService> services;
  final List<ProviderService> fullServices;
  final bool isServicesLoading;
  final bool isServicesLoadingMore;
  final bool servicesHasMore;
  final String? servicesError;

  // ── Packages ───────────────────────────────────────────────────────────────
  final List<ProviderPackage> packages;
  final List<ProviderPackage> fullPackages;
  final bool isPackagesLoading;
  final bool isPackagesLoadingMore;
  final bool packagesHasMore;
  final String? packagesError;
  final Map<int, PackageDetailsData> packageDetailsById;
  final Set<int> loadingPackageDetailsIds;
  final Set<int> expandedPackageIds;
  final Map<int, String> packageDetailsErrors;

  // ── View / Search ──────────────────────────────────────────────────────────
  final ProviderViewType currentView;
  final String? searchQuery;

  // ── Cart ───────────────────────────────────────────────────────────────────
  final List<CartItem> cartItems;
  final bool isCartLoading;
  final Set<int> pendingCartActionIds;

  const ProviderPageState({
    this.providerData,
    this.isProviderLoading = false,
    this.providerError,
    this.categoryTabs = const [],
    this.selectedCategoryIndex = 0,
    this.services = const [],
    this.fullServices = const [],
    this.isServicesLoading = false,
    this.isServicesLoadingMore = false,
    this.servicesHasMore = true,
    this.servicesError,
    this.packages = const [],
    this.fullPackages = const [],
    this.isPackagesLoading = false,
    this.isPackagesLoadingMore = false,
    this.packagesHasMore = true,
    this.packagesError,
    this.packageDetailsById = const {},
    this.loadingPackageDetailsIds = const {},
    this.expandedPackageIds = const {},
    this.packageDetailsErrors = const {},
    this.currentView = ProviderViewType.services,
    this.searchQuery,
    this.cartItems = const [],
    this.isCartLoading = false,
    this.pendingCartActionIds = const {},
  });

  // ── Convenience getters ────────────────────────────────────────────────────

  /// The currently visible category tab, or null if tabs aren't loaded yet.
  CategoryTab? get selectedTab =>
      categoryTabs.isNotEmpty && selectedCategoryIndex < categoryTabs.length
      ? categoryTabs[selectedCategoryIndex]
      : null;

  bool isServiceInCart(int serviceId) =>
      cartItems.any((item) => item.serviceId == serviceId);

  int getCartItemCount() => cartItems.length;

  double calculateTotalPrice() =>
      cartItems.fold(0.0, (sum, item) => sum + (item.priceAfter ?? 0.0));

  // ── copyWith ───────────────────────────────────────────────────────────────

  ProviderPageState copyWith({
    ProviderPageData? providerData,
    bool resetProviderData = false,
    bool? isProviderLoading,
    String? providerError,
    bool resetProviderError = false,
    List<CategoryTab>? categoryTabs,
    int? selectedCategoryIndex,
    List<ProviderService>? services,
    List<ProviderService>? fullServices,
    bool? isServicesLoading,
    bool? isServicesLoadingMore,
    bool? servicesHasMore,
    String? servicesError,
    bool resetServicesError = false,
    List<ProviderPackage>? packages,
    List<ProviderPackage>? fullPackages,
    bool? isPackagesLoading,
    bool? isPackagesLoadingMore,
    bool? packagesHasMore,
    String? packagesError,
    bool resetPackagesError = false,
    Map<int, PackageDetailsData>? packageDetailsById,
    Set<int>? loadingPackageDetailsIds,
    Set<int>? expandedPackageIds,
    Map<int, String>? packageDetailsErrors,
    ProviderViewType? currentView,
    String? searchQuery,
    bool resetSearchQuery = false,
    List<CartItem>? cartItems,
    bool? isCartLoading,
    Set<int>? pendingCartActionIds,
  }) {
    return ProviderPageState(
      providerData: resetProviderData
          ? null
          : (providerData ?? this.providerData),
      isProviderLoading: isProviderLoading ?? this.isProviderLoading,
      providerError: resetProviderError
          ? null
          : (providerError ?? this.providerError),
      categoryTabs: categoryTabs ?? this.categoryTabs,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      services: services ?? this.services,
      fullServices: fullServices ?? this.fullServices,
      isServicesLoading: isServicesLoading ?? this.isServicesLoading,
      isServicesLoadingMore:
          isServicesLoadingMore ?? this.isServicesLoadingMore,
      servicesHasMore: servicesHasMore ?? this.servicesHasMore,
      servicesError: resetServicesError
          ? null
          : (servicesError ?? this.servicesError),
      packages: packages ?? this.packages,
      fullPackages: fullPackages ?? this.fullPackages,
      isPackagesLoading: isPackagesLoading ?? this.isPackagesLoading,
      isPackagesLoadingMore:
          isPackagesLoadingMore ?? this.isPackagesLoadingMore,
      packagesHasMore: packagesHasMore ?? this.packagesHasMore,
      packagesError: resetPackagesError
          ? null
          : (packagesError ?? this.packagesError),
      packageDetailsById: packageDetailsById ?? this.packageDetailsById,
      loadingPackageDetailsIds:
          loadingPackageDetailsIds ?? this.loadingPackageDetailsIds,
      expandedPackageIds: expandedPackageIds ?? this.expandedPackageIds,
      packageDetailsErrors: packageDetailsErrors ?? this.packageDetailsErrors,
      currentView: currentView ?? this.currentView,
      searchQuery: resetSearchQuery ? null : (searchQuery ?? this.searchQuery),
      cartItems: cartItems ?? this.cartItems,
      isCartLoading: isCartLoading ?? this.isCartLoading,
      pendingCartActionIds: pendingCartActionIds ?? this.pendingCartActionIds,
    );
  }
}
