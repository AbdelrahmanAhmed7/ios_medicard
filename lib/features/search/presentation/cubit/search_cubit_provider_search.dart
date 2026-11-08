// These extensions are part of SearchCubit's library and intentionally call
// Cubit.emit to keep each responsibility in a focused file.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'search_cubit.dart';

extension SearchCubitProviderSearch on SearchCubit {
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
    await Future.wait([_fetch(page: 1), searchMedicines(search: keyword)]);

    if (!_enableCartFeatures) {
      final currentCategoryId = state.servicesData?.categoryId;
      if (currentCategoryId != null) {
        final normalizedKeyword = keyword.trim().isEmpty
            ? null
            : keyword.trim();
        await loadCategoryServices(
          currentCategoryId,
          search: normalizedKeyword,
        );
      }
    }
  }

  Future<void> searchMedicines({String? search}) async {
    if (isClosed) return;
    final requestGeneration = ++_medicineRequestGeneration;
    final normalizedSearch = search?.trim();
    _medicineKeyword = normalizedSearch?.isEmpty == true
        ? null
        : normalizedSearch;
    emit(
      state.copyWith(
        isLoadingMedicines: true,
        isLoadingMoreMedicines: false,
        medicines: const [],
        medicinesCurrentPage: 1,
        medicinesTotalPages: 1,
        clearMedicinesError: true,
      ),
    );

    final result = await _searchMedicinesUseCase.call(
      search: _medicineKeyword,
      pageNumber: 1,
      pageSize: SearchCubit._medicinesPageSize,
    );
    if (isClosed || requestGeneration != _medicineRequestGeneration) return;

    result.when(
      success: (page) => emit(
        state.copyWith(
          medicines: page.items.where((item) => item.id > 0).toList(),
          isLoadingMedicines: false,
          medicinesCurrentPage: page.pageNumber,
          medicinesTotalPages: page.totalPages,
          clearMedicinesError: true,
        ),
      ),
      failure: (message) => emit(
        state.copyWith(isLoadingMedicines: false, medicinesError: message),
      ),
    );
  }

  Future<void> loadMoreMedicines() async {
    if (isClosed ||
        state.isLoadingMedicines ||
        state.isLoadingMoreMedicines ||
        state.medicinesCurrentPage >= state.medicinesTotalPages) {
      return;
    }

    final requestGeneration = _medicineRequestGeneration;
    final nextPage = state.medicinesCurrentPage + 1;
    emit(state.copyWith(isLoadingMoreMedicines: true));
    final result = await _searchMedicinesUseCase.call(
      search: _medicineKeyword,
      pageNumber: nextPage,
      pageSize: SearchCubit._medicinesPageSize,
    );
    if (isClosed || requestGeneration != _medicineRequestGeneration) return;

    result.when(
      success: (page) {
        final existingIds = {
          for (final medicine in state.medicines) medicine.id,
        };
        emit(
          state.copyWith(
            medicines: [
              ...state.medicines,
              ...page.items.where(
                (medicine) =>
                    medicine.id > 0 && !existingIds.contains(medicine.id),
              ),
            ],
            isLoadingMoreMedicines: false,
            medicinesCurrentPage: page.pageNumber,
            medicinesTotalPages: page.totalPages,
            clearMedicinesError: true,
          ),
        );
      },
      failure: (message) => emit(
        state.copyWith(isLoadingMoreMedicines: false, medicinesError: message),
      ),
    );
  }

  Future<void> loadMore() async {
    if (isClosed) return;
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: state.currentPage + 1);
  }

  /// Derives whether more provider pages exist without trusting a single
  /// backend field. Prefers [totalPages], falls back to [totalCount], and
  /// finally to the full-page heuristic so a missing pagination field can
  /// never silently truncate the list to the first page.
  bool _hasMoreProviders({
    required int page,
    required int newItemsCount,
    required int? totalPages,
    required int? totalCount,
    required int pageSize,
  }) {
    if (totalPages != null) return page < totalPages;
    if (totalCount != null && pageSize > 0) return page * pageSize < totalCount;
    if (pageSize <= 0) return false;
    return newItemsCount >= pageSize;
  }

  Future<void> selectCategory(int? id) async {
    if (isClosed) return;
    if (id == null) {
      emit(state.copyWith(clearSelectedCategory: true));
    } else {
      emit(state.copyWith(selectedCategoryId: id));
    }
    await search(keyword: state.keyword);
  }

  Future<void> applyFilters({
    int? governorateId,
    int? cityId,
    int? sortBy,
  }) async {
    _governorateId = governorateId;
    _cityId = cityId;
    _sortBy = sortBy;

    // "Nearest to me" requires the user's coordinates. If we don't have them
    // yet, resolve the location first — triggering the OS permission and GPS
    // prompts — so the list can actually be sorted by proximity.
    if (sortBy == SearchCubit._nearestSortValue &&
        (state.userLatitude == null || state.userLongitude == null)) {
      final locationResult = await _resolveUserLocation();
      if (isClosed) return;

      if (locationResult.hasCoordinates) {
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] nearest sort resolved location at '
            '${locationResult.latitude}, ${locationResult.longitude}',
          );
        }
        emit(
          state.copyWith(
            userLatitude: locationResult.latitude,
            userLongitude: locationResult.longitude,
            clearFilterError: true,
          ),
        );
      } else {
        // Without coordinates the nearest sort can't be applied. Fall back to
        // the default ordering instead of silently bypassing the filter, and
        // let the UI tell the user what happened.
        _sortBy = null;
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] nearest sort skipped, location unavailable: '
            '${locationResult.status}',
          );
        }
        emit(
          state.copyWith(
            filterError: _locationUnavailableMessage(locationResult.status),
          ),
        );
      }
    }

    await search(keyword: state.keyword);
  }

  /// Returns the user's location, preferring the cached value so an already
  /// granted location is reused without prompting again.
  Future<LocationResult> _resolveUserLocation() {
    final cached = _locationRepository.cached;
    if (cached?.hasCoordinates == true) return Future.value(cached!);
    return _locationRepository.resolve(_locationService);
  }

  String _locationUnavailableMessage(LocationAccessStatus status) {
    return switch (status) {
      LocationAccessStatus.permanentlyDenied =>
        'sort_filter.location_permanently_denied'.tr(),
      LocationAccessStatus.serviceDisabled =>
        'sort_filter.location_service_disabled'.tr(),
      LocationAccessStatus.unavailable =>
        'sort_filter.location_unavailable'.tr(),
      LocationAccessStatus.granted ||
      LocationAccessStatus.denied => 'sort_filter.location_required'.tr(),
    };
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
      pageSize: SearchCubit._pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (data) {
        final newItems = data.items ?? const <SearchProviderModel>[];
        final merged = page == 1 ? newItems : [...state.items, ...newItems];
        final totalCount = data.totalCount;
        final providerCounts = Map<int, int>.from(state.providerCategoryCounts);
        if (state.selectedCategoryId != null &&
            totalCount != null &&
            totalCount > 0) {
          providerCounts[state.selectedCategoryId!] = totalCount;
        }
        emit(
          state.copyWith(
            items: merged,
            providerCategoryCounts: providerCounts,
            isLoading: false,
            isLoadingMore: false,
            hasMore: _hasMoreProviders(
              page: page,
              newItemsCount: newItems.length,
              totalPages: data.totalPages,
              totalCount: data.totalCount,
              pageSize: data.pageSize ?? SearchCubit._pageSize,
            ),
            currentPage: page,
            clearError: true,
          ),
        );
      },
      failure: (message) {
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
