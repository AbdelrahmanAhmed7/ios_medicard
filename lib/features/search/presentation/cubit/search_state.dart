import '../../data/models/category_model.dart';
import '../../data/models/category_services_response_model.dart';
import '../../data/models/search_provider_model.dart';

class SearchState {
  final List<SearchProviderModel> items;

  /// Categories for the Provider tab — from GET /Lookups/categories.
  final List<CategoryModel> categories;

  /// Categories for the Services tab — from GET /CategoryService/categories.
  final List<CategoryModel> serviceCategories;
  final bool isLoadingServiceCategories;

  /// Maps categoryId → totalSelectedCount.
  /// Populated from the cart summary and updated after every add/remove action.
  /// Updated after every add/remove action.
  final Map<int, int> categorySelectedCounts;

  /// Maps categoryId → total number of services available in that category.
  final Map<int, int> categoryServiceCounts;

  /// Maps provider-category id → total providers in that category.
  final Map<int, int> providerCategoryCounts;

  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int? selectedCategoryId;
  final String keyword;
  final double? userLatitude;
  final double? userLongitude;

  // Services tab data
  final bool isLoadingServices;
  final String? servicesError;
  final CategoryServicesDataModel? servicesData;
  final List<ServiceItemModel> services;
  final Map<int, CategoryServicesDataModel> servicesByCategoryId;
  final Set<int> loadingServiceCategoryIds;
  final Set<int> loadingMoreServiceCategoryIds;

  /// ServiceIds that currently have a pending add/remove API call.
  /// Used to show per-item loading spinners.
  final Set<int> pendingServiceIds;
  final String? cartActionError;

  /// Message shown when the Provider-tab categories could not be loaded.
  final String? categoriesError;

  /// Message shown when the Services-tab categories could not be loaded.
  final String? serviceCategoriesError;

  /// Message shown when a filter could not be applied, e.g. the "Nearest to
  /// me" sort was requested but the user's location could not be resolved.
  final String? filterError;

  const SearchState({
    this.items = const [],
    this.categories = const [],
    this.serviceCategories = const [],
    this.isLoadingServiceCategories = false,
    this.categorySelectedCounts = const {},
    this.categoryServiceCounts = const {},
    this.providerCategoryCounts = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedCategoryId,
    this.keyword = '',
    this.userLatitude,
    this.userLongitude,
    this.isLoadingServices = false,
    this.servicesError,
    this.servicesData,
    this.services = const [],
    this.servicesByCategoryId = const {},
    this.loadingServiceCategoryIds = const {},
    this.loadingMoreServiceCategoryIds = const {},
    this.pendingServiceIds = const {},
    this.cartActionError,
    this.categoriesError,
    this.serviceCategoriesError,
    this.filterError,
  });

  SearchState copyWith({
    List<SearchProviderModel>? items,
    List<CategoryModel>? categories,
    List<CategoryModel>? serviceCategories,
    bool? isLoadingServiceCategories,
    Map<int, int>? categorySelectedCounts,
    Map<int, int>? categoryServiceCounts,
    Map<int, int>? providerCategoryCounts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    bool? hasMore,
    int? currentPage,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? keyword,
    double? userLatitude,
    double? userLongitude,
    bool? isLoadingServices,
    String? servicesError,
    bool clearServicesError = false,
    CategoryServicesDataModel? servicesData,
    List<ServiceItemModel>? services,
    Map<int, CategoryServicesDataModel>? servicesByCategoryId,
    Set<int>? loadingServiceCategoryIds,
    Set<int>? loadingMoreServiceCategoryIds,
    Set<int>? pendingServiceIds,
    String? cartActionError,
    bool clearCartActionError = false,
    String? categoriesError,
    bool clearCategoriesError = false,
    String? serviceCategoriesError,
    bool clearServiceCategoriesError = false,
    String? filterError,
    bool clearFilterError = false,
  }) {
    return SearchState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      isLoadingServiceCategories:
          isLoadingServiceCategories ?? this.isLoadingServiceCategories,
      categorySelectedCounts:
          categorySelectedCounts ?? this.categorySelectedCounts,
      categoryServiceCounts:
          categoryServiceCounts ?? this.categoryServiceCounts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      keyword: keyword ?? this.keyword,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      servicesError: clearServicesError
          ? null
          : (servicesError ?? this.servicesError),
      servicesData: servicesData ?? this.servicesData,
      services: services ?? this.services,
      servicesByCategoryId: servicesByCategoryId ?? this.servicesByCategoryId,
      loadingServiceCategoryIds:
          loadingServiceCategoryIds ?? this.loadingServiceCategoryIds,
      loadingMoreServiceCategoryIds:
          loadingMoreServiceCategoryIds ?? this.loadingMoreServiceCategoryIds,
      pendingServiceIds: pendingServiceIds ?? this.pendingServiceIds,
      cartActionError: clearCartActionError
          ? null
          : (cartActionError ?? this.cartActionError),
      categoriesError: clearCategoriesError
          ? null
          : (categoriesError ?? this.categoriesError),
      serviceCategoriesError: clearServiceCategoriesError
          ? null
          : (serviceCategoriesError ?? this.serviceCategoriesError),
      filterError: clearFilterError ? null : (filterError ?? this.filterError),
    );
  }
}
