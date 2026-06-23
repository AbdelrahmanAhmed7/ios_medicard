import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_result.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/search_providers_use_case.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProvidersUseCase _searchProvidersUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  static const int _pageSize = 15;

  // Active filter params
  int? _governorateId;
  int? _cityId;
  int? _sortBy;

  SearchCubit(this._searchProvidersUseCase, this._getCategoriesUseCase)
    : super(const SearchState());

  /// Called when the screen is first opened.
  /// Sets location and optional pre-selected category, then fires initial search.
  Future<void> init({double? lat, double? lng, int? categoryId}) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        userLatitude: lat,
        userLongitude: lng,
        selectedCategoryId: categoryId,
        clearSelectedCategory: categoryId == null,
      ),
    );
    await Future.wait([_loadCategories(), search()]);
  }

  Future<void> _loadCategories() async {
    final result = await _getCategoriesUseCase.call();
    if (isClosed) return;
    result.when(
      success: (categories) {
        if (isClosed) return;
        emit(state.copyWith(categories: categories));
      },
      failure: (_) {
        // Non-fatal — categories section simply stays empty
      },
    );
  }

  /// Resets to page 1 and fires a fresh search.
  Future<void> search({String keyword = ''}) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        isLoading: true,
        items: [],
        hasMore: true,
        currentPage: 1,
        keyword: keyword,
        clearError: true,
      ),
    );
    await _fetch(page: 1);
  }

  /// Appends the next page of results.
  Future<void> loadMore() async {
    if (isClosed) return;
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: state.currentPage + 1);
  }

  /// Updates the active category and re-runs the search.
  Future<void> selectCategory(int? id) async {
    if (isClosed) return;
    if (id == null) {
      emit(state.copyWith(clearSelectedCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: id));
    }
    await search(keyword: state.keyword);
  }

  /// Stores filter values from the bottom sheet and re-runs the search.
  Future<void> applyFilters({
    int? governorateId,
    int? cityId,
    int? sortBy,
  }) async {
    _governorateId = governorateId;
    _cityId = cityId;
    _sortBy = sortBy;
    await search(keyword: state.keyword);
  }

  Future<void> _fetch({required int page}) async {
    final result = await _searchProvidersUseCase.call(
      keyword: state.keyword.isEmpty ? null : state.keyword,
      categoryId: state.selectedCategoryId,
      governorateId: _governorateId,
      cityId: _cityId,
      sortBy: _sortBy,
      userLatitude: state.userLatitude,
      userLongitude: state.userLongitude,
      pageNumber: page,
      pageSize: _pageSize,
    );

    if (isClosed) return;

    result.when(
      success: (newItems) {
        if (isClosed) return;
        final merged = page == 1 ? newItems : [...state.items, ...newItems];
        emit(
          state.copyWith(
            items: merged,
            isLoading: false,
            isLoadingMore: false,
            hasMore: newItems.length >= _pageSize,
            currentPage: page,
            clearError: true,
          ),
        );
      },
      failure: (message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            error: message,
          ),
        );
      },
    );
  }
}
