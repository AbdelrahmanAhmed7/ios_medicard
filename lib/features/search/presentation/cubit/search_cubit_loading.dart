// These extensions are part of SearchCubit's library and intentionally call
// Cubit.emit to keep each responsibility in a focused file.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'search_cubit.dart';

extension SearchCubitLoading on SearchCubit {
  Future<void> _loadCategories() async {
    final result = await _getCategoriesUseCase.call();
    if (isClosed) return;
    result.when(
      success: (categories) {
        emit(
          state.copyWith(categories: categories, clearCategoriesError: true),
        );
        unawaited(_loadProviderCategoryCounts(categories));
      },
      failure: (message) {
        if (kDebugMode) debugPrint('[SearchCubit] load categories: $message');
        emit(state.copyWith(categoriesError: message));
      },
    );
  }

  /// Fetches the total provider count for every provider category so the
  /// provider-tab chips can show how many providers each one contains.
  /// Failures are ignored — the chips simply omit the count.
  Future<void> _loadProviderCategoryCounts(
    List<CategoryModel> categories,
  ) async {
    final targets = categories.where((category) => category.id != null);
    if (targets.isEmpty) return;

    final entries = await Future.wait(
      targets.map((category) async {
        final categoryId = category.id!;
        final result = await _searchProvidersUseCase.call(
          categoryId: categoryId,
          pageNumber: 1,
          pageSize: 1,
        );
        return result.when(
          success: (data) => MapEntry(categoryId, data.totalCount ?? 0),
          failure: (_) => MapEntry(categoryId, 0),
        );
      }),
    );
    if (isClosed) return;

    final counts = Map<int, int>.from(state.providerCategoryCounts);
    var changed = false;
    for (final entry in entries) {
      if (entry.value > 0 && counts[entry.key] != entry.value) {
        counts[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      emit(state.copyWith(providerCategoryCounts: counts));
    }
  }

  Future<void> _loadServiceCategories() async {
    if (isClosed) return;
    emit(state.copyWith(isLoadingServiceCategories: true));
    final result = await _getServiceCategoriesUseCase.call();
    if (isClosed) return;
    result.when(
      success: (categories) {
        emit(
          state.copyWith(
            serviceCategories: categories,
            isLoadingServiceCategories: false,
            clearServiceCategoriesError: true,
          ),
        );
        unawaited(_loadServiceCategoryCounts(categories));
      },
      failure: (message) {
        if (kDebugMode) {
          debugPrint('[SearchCubit] load service categories: $message');
        }
        emit(
          state.copyWith(
            isLoadingServiceCategories: false,
            serviceCategoriesError: message,
          ),
        );
      },
    );
  }

  /// Fetches the total service count for every category so the filter chips
  /// can show how many services each one contains. Failures are ignored — the
  /// chips simply omit the count.
  Future<void> _loadServiceCategoryCounts(
    List<CategoryModel> categories,
  ) async {
    final targets = categories.where((category) => category.id != null);
    if (targets.isEmpty) return;

    final entries = await Future.wait(
      targets.map((category) async {
        final categoryId = category.id!;
        final result = _enableCartFeatures
            ? await _getCategoryServicesUseCase.call(
                categoryId,
                pageNumber: 1,
                pageSize: 1,
              )
            : await _getCategoryServicesUseCase.callGuestServices(
                categoryId,
                pageNumber: 1,
                pageSize: 1,
              );
        return result.when(
          success: (data) =>
              MapEntry(categoryId, data.services?.totalCount ?? 0),
          failure: (_) => MapEntry(categoryId, 0),
        );
      }),
    );
    if (isClosed) return;

    final counts = Map<int, int>.from(state.categoryServiceCounts);
    var changed = false;
    for (final entry in entries) {
      if (entry.value > 0 && counts[entry.key] != entry.value) {
        counts[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      emit(state.copyWith(categoryServiceCounts: counts));
    }
  }

  Future<void> _loadCartCounters() async {
    if (kDebugMode) {
      debugPrint('[SearchCubit] loading cart counters for service badges');
    }
    final result = await _cartRepository.getCart();
    if (isClosed) return;
    result.when(
      success: (cart) {
        final counts = {
          for (final counter in cart.categoryCounters)
            counter.categoryId: counter.count,
        };
        final selectedMedicineIds = {
          for (final item in cart.items)
            if (item.categoryId == 1) item.serviceId,
        };
        emit(
          state.copyWith(
            categorySelectedCounts: counts,
            selectedMedicineIds: selectedMedicineIds,
          ),
        );
      },
      // Badges only: logged, never toasted — erroring on every init would
      // spam the user for non-critical background data.
      failure: (message) {
        if (kDebugMode) {
          debugPrint('[SearchCubit] load cart counters: $message');
        }
      },
    );
  }
}
