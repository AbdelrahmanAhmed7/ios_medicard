import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';

enum ProviderViewType { services, packages, reviews }

/// Catalog-only views shown in the packages/services dropdown.
const Set<ProviderViewType> kProviderCatalogViews = {
  ProviderViewType.services,
  ProviderViewType.packages,
};

class CategoryTab {
  final int categoryId;
  final String categoryName;
  final dynamic services;
  final bool isLoading;
  final String? error;

  const CategoryTab({
    required this.categoryId,
    required this.categoryName,
    this.services,
    this.isLoading = false,
    this.error,
  });

  int get selectedCount => 0;
}

class ProviderPageState {
  final ProviderPageData? providerData;
  final bool isProviderLoading;
  final String? providerError;

  final List<ProviderService> services;
  final List<ProviderService> fullServices;
  final bool isServicesLoading;
  final bool isServicesLoadingMore;
  final bool servicesHasMore;
  final String? servicesError;
  final List<CategoryTab> categoryTabs;
  final int selectedCategoryIndex;

  final List<ProviderPackage> packages;
  final List<ProviderPackage> fullPackages;
  final bool isPackagesLoading;
  final bool isPackagesLoadingMore;
  final bool packagesHasMore;
  final String? packagesError;
  final Map<int, PackageDetailsData> packageDetailsById;
  final Set<int> loadingPackageDetailsIds;
  final Map<int, String> packageDetailsErrors;

  final List<ProviderReview> reviews;
  final List<ProviderReview> fullReviews;
  final bool isReviewsLoading;
  final bool isReviewsLoadingMore;
  final bool reviewsHasMore;
  final String? reviewsError;

  final ProviderViewType currentView;
  /// Last services/packages selection for the catalog dropdown.
  /// Never set to [ProviderViewType.reviews].
  final ProviderViewType catalogView;
  final String? searchQuery;
  final Set<int> pendingCartActionIds;
  final Set<int> pendingPackageInvoiceIds;

  const ProviderPageState({
    this.providerData,
    this.isProviderLoading = false,
    this.providerError,
    this.services = const [],
    this.fullServices = const [],
    this.isServicesLoading = false,
    this.isServicesLoadingMore = false,
    this.servicesHasMore = false,
    this.servicesError,
    this.categoryTabs = const [],
    this.selectedCategoryIndex = 0,
    this.packages = const [],
    this.fullPackages = const [],
    this.isPackagesLoading = false,
    this.isPackagesLoadingMore = false,
    this.packagesHasMore = true,
    this.packagesError,
    this.packageDetailsById = const {},
    this.loadingPackageDetailsIds = const {},
    this.packageDetailsErrors = const {},
    this.reviews = const [],
    this.fullReviews = const [],
    this.isReviewsLoading = false,
    this.isReviewsLoadingMore = false,
    this.reviewsHasMore = true,
    this.reviewsError,
    this.currentView = ProviderViewType.services,
    this.catalogView = ProviderViewType.services,
    this.searchQuery,
    this.pendingCartActionIds = const {},
    this.pendingPackageInvoiceIds = const {},
  });

  dynamic get selectedTab => null;

  int get displayServicesCount {
    if (fullServices.isNotEmpty) return fullServices.length;
    final embeddedServices = providerData?.services;
    if (embeddedServices != null && embeddedServices.isNotEmpty) {
      return embeddedServices.length;
    }
    return providerData?.servicesCount ?? 0;
  }

  bool isServiceInCart(int serviceId) {
    return fullServices.any(
      (service) => service.id == serviceId && service.isSelected == true,
    );
  }

  int getCartItemCount() {
    return fullServices
        .where((service) => service.id != null && service.isSelected == true)
        .map((service) => service.id!)
        .toSet()
        .length;
  }

  ProviderPageState copyWith({
    ProviderPageData? providerData,
    bool resetProviderData = false,
    bool? isProviderLoading,
    String? providerError,
    bool resetProviderError = false,
    List<ProviderService>? services,
    List<ProviderService>? fullServices,
    bool? isServicesLoading,
    bool? isServicesLoadingMore,
    bool? servicesHasMore,
    String? servicesError,
    bool resetServicesError = false,
    List<CategoryTab>? categoryTabs,
    int? selectedCategoryIndex,
    List<ProviderPackage>? packages,
    List<ProviderPackage>? fullPackages,
    bool? isPackagesLoading,
    bool? isPackagesLoadingMore,
    bool? packagesHasMore,
    String? packagesError,
    bool resetPackagesError = false,
    Map<int, PackageDetailsData>? packageDetailsById,
    Set<int>? loadingPackageDetailsIds,
    Map<int, String>? packageDetailsErrors,
    List<ProviderReview>? reviews,
    List<ProviderReview>? fullReviews,
    bool? isReviewsLoading,
    bool? isReviewsLoadingMore,
    bool? reviewsHasMore,
    String? reviewsError,
    bool resetReviewsError = false,
    ProviderViewType? currentView,
    ProviderViewType? catalogView,
    String? searchQuery,
    bool resetSearchQuery = false,
    Set<int>? pendingCartActionIds,
    Set<int>? pendingPackageInvoiceIds,
  }) {
    return ProviderPageState(
      providerData: resetProviderData
          ? null
          : (providerData ?? this.providerData),
      isProviderLoading: isProviderLoading ?? this.isProviderLoading,
      providerError: resetProviderError
          ? null
          : (providerError ?? this.providerError),
      services: services ?? this.services,
      fullServices: fullServices ?? this.fullServices,
      isServicesLoading: isServicesLoading ?? this.isServicesLoading,
      isServicesLoadingMore:
          isServicesLoadingMore ?? this.isServicesLoadingMore,
      servicesHasMore: servicesHasMore ?? this.servicesHasMore,
      servicesError: resetServicesError
          ? null
          : (servicesError ?? this.servicesError),
      categoryTabs: categoryTabs ?? this.categoryTabs,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
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
      packageDetailsErrors: packageDetailsErrors ?? this.packageDetailsErrors,
      reviews: reviews ?? this.reviews,
      fullReviews: fullReviews ?? this.fullReviews,
      isReviewsLoading: isReviewsLoading ?? this.isReviewsLoading,
      isReviewsLoadingMore: isReviewsLoadingMore ?? this.isReviewsLoadingMore,
      reviewsHasMore: reviewsHasMore ?? this.reviewsHasMore,
      reviewsError: resetReviewsError
          ? null
          : (reviewsError ?? this.reviewsError),
      currentView: currentView ?? this.currentView,
      catalogView: catalogView ?? this.catalogView,
      searchQuery: resetSearchQuery ? null : (searchQuery ?? this.searchQuery),
      pendingCartActionIds: pendingCartActionIds ?? this.pendingCartActionIds,
      pendingPackageInvoiceIds:
          pendingPackageInvoiceIds ?? this.pendingPackageInvoiceIds,
    );
  }
}
