// These extensions are part of SearchCubit's library and intentionally call
// Cubit.emit to keep each responsibility in a focused file.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'search_cubit.dart';

extension SearchCubitServices on SearchCubit {
  Future<bool> loadCategoryServices(int categoryId, {String? search}) async {
    if (isClosed) return false;

    final cached = state.servicesByCategoryId[categoryId];
    final cachedKeyword = _guestServicesKeyword[categoryId];
    if (cached != null &&
        _servicesCacheMode == _enableCartFeatures &&
        cachedKeyword == search) {
      _serviceCategoryRequestGeneration++;
      if (kDebugMode) {
        debugPrint(
          '[SearchCubit] reused cached services category=$categoryId '
          'keyword=$search',
        );
      }
      emit(
        state.copyWith(
          servicesData: cached,
          services: cached.services?.items ?? const [],
          isLoadingServices: false,
          clearServicesError: true,
        ),
      );
      return (cached.services?.items ?? const []).isNotEmpty;
    }

    if (state.loadingServiceCategoryIds.contains(categoryId)) {
      if (kDebugMode) {
        debugPrint(
          '[SearchCubit] duplicate category load ignored category=$categoryId',
        );
      }
      return false;
    }

    final requestGeneration = ++_serviceCategoryRequestGeneration;

    if (kDebugMode) {
      debugPrint('[SearchCubit] loading services category=$categoryId');
    }
    emit(
      state.copyWith(
        isLoadingServices: true,
        loadingServiceCategoryIds: {
          ...state.loadingServiceCategoryIds,
          categoryId,
        },
        clearServicesError: true,
      ),
    );

    final result = _enableCartFeatures
        ? await _getCategoryServicesUseCase.call(
            categoryId,
            pageNumber: 1,
            pageSize: SearchCubit._servicesPageSize,
          )
        : await _getCategoryServicesUseCase.callGuestServices(
            categoryId,
            search: search,
            pageNumber: 1,
            pageSize: SearchCubit._servicesPageSize,
          );
    if (isClosed) return false;

    final loadingIds = Set<int>.from(state.loadingServiceCategoryIds)
      ..remove(categoryId);

    return result.when(
      success: (data) {
        _guestServicesKeyword[categoryId] = search;
        final counts = Map<int, int>.from(state.categorySelectedCounts);
        counts[categoryId] = data.totalSelectedCount ?? 0;
        final serviceCounts = Map<int, int>.from(state.categoryServiceCounts);
        final totalCount = data.services?.totalCount;
        if (totalCount != null && totalCount > 0) {
          serviceCounts[categoryId] = totalCount;
        }
        final cachedCategories = Map<int, CategoryServicesDataModel>.from(
          state.servicesByCategoryId,
        )..[categoryId] = data;

        final isLatest = requestGeneration == _serviceCategoryRequestGeneration;
        emit(
          state.copyWith(
            isLoadingServices: loadingIds.isNotEmpty,
            loadingServiceCategoryIds: loadingIds,
            servicesByCategoryId: cachedCategories,
            servicesData: isLatest ? data : state.servicesData,
            services: isLatest
                ? data.services?.items ?? const []
                : state.services,
            clearServicesError: isLatest,
            categorySelectedCounts: counts,
            categoryServiceCounts: serviceCounts,
          ),
        );
        return (data.services?.items ?? const []).isNotEmpty;
      },
      failure: (message) {
        final isLatest = requestGeneration == _serviceCategoryRequestGeneration;
        emit(
          state.copyWith(
            isLoadingServices: loadingIds.isNotEmpty,
            loadingServiceCategoryIds: loadingIds,
            servicesError: isLatest ? message : state.servicesError,
          ),
        );
        return false;
      },
    );
  }

  Future<int?> loadFirstServiceCategoryWithData() async {
    if (isClosed) return null;
    for (final category in state.serviceCategories) {
      final categoryId = category.id;
      if (categoryId == null) continue;
      final hasServices = await loadCategoryServices(categoryId);
      if (isClosed) return null;
      if (hasServices) return categoryId;
    }
    return null;
  }

  bool hasMoreCategoryServices(int categoryId) {
    final cached = state.servicesByCategoryId[categoryId];
    final pageNumber = cached?.services?.pageNumber ?? 1;
    final totalPages = cached?.services?.totalPages ?? 1;
    return pageNumber < totalPages;
  }

  Future<bool> loadMoreCategoryServices(int categoryId) async {
    if (isClosed) return false;
    final cached = state.servicesByCategoryId[categoryId];
    if (cached == null) return false;
    if (!hasMoreCategoryServices(categoryId)) return false;
    if (state.loadingServiceCategoryIds.contains(categoryId) ||
        state.loadingMoreServiceCategoryIds.contains(categoryId)) {
      return false;
    }

    final nextPage = (cached.services?.pageNumber ?? 1) + 1;
    emit(
      state.copyWith(
        loadingMoreServiceCategoryIds: {
          ...state.loadingMoreServiceCategoryIds,
          categoryId,
        },
      ),
    );

    final result = _enableCartFeatures
        ? await _getCategoryServicesUseCase.call(
            categoryId,
            pageNumber: nextPage,
            pageSize: SearchCubit._servicesPageSize,
          )
        : await _getCategoryServicesUseCase.callGuestServices(
            categoryId,
            search: _guestServicesKeyword[categoryId],
            pageNumber: nextPage,
            pageSize: SearchCubit._servicesPageSize,
          );
    if (isClosed) return false;

    return result.when(
      success: (data) {
        final currentItems =
            cached.services?.items ?? const <ServiceItemModel>[];
        final paged = data.services;
        final existingIds = {for (final item in currentItems) item.serviceId};
        final visibleItems = [
          ...currentItems,
          ...?paged?.items?.where(
            (item) => !existingIds.contains(item.serviceId),
          ),
        ];
        final merged = CategoryServicesDataModel(
          categoryId: data.categoryId ?? cached.categoryId,
          categoryName: data.categoryName ?? cached.categoryName,
          totalSelectedCount:
              data.totalSelectedCount ?? cached.totalSelectedCount,
          services: PagedServicesModel(
            items: visibleItems,
            pageNumber: paged?.pageNumber ?? nextPage,
            pageSize: paged?.pageSize ?? SearchCubit._servicesPageSize,
            totalCount: paged?.totalCount ?? cached.services?.totalCount,
            totalPages: paged?.totalPages ?? cached.services?.totalPages,
          ),
        );
        final cachedCategories = Map<int, CategoryServicesDataModel>.from(
          state.servicesByCategoryId,
        )..[categoryId] = merged;

        final isVisible = state.servicesData?.categoryId == categoryId;
        emit(
          state.copyWith(
            loadingMoreServiceCategoryIds: {
              ...state.loadingMoreServiceCategoryIds,
            }..remove(categoryId),
            servicesByCategoryId: cachedCategories,
            servicesData: isVisible ? merged : state.servicesData,
            services: isVisible ? visibleItems : state.services,
            clearServicesError: true,
          ),
        );
        return true;
      },
      failure: (message) {
        emit(
          state.copyWith(
            loadingMoreServiceCategoryIds: {
              ...state.loadingMoreServiceCategoryIds,
            }..remove(categoryId),
          ),
        );
        return false;
      },
    );
  }
}
