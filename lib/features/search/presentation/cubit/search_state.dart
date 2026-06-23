import '../../data/models/category_model.dart';
import '../../data/models/search_provider_model.dart';

class SearchState {
  final List<SearchProviderModel> items;
  final List<CategoryModel> categories;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int? selectedCategoryId;
  final String keyword;
  final double? userLatitude;
  final double? userLongitude;

  const SearchState({
    this.items = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.selectedCategoryId,
    this.keyword = '',
    this.userLatitude,
    this.userLongitude,
  });

  SearchState copyWith({
    List<SearchProviderModel>? items,
    List<CategoryModel>? categories,
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
  }) {
    return SearchState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
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
    );
  }
}
