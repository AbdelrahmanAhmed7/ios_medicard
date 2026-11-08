// These extensions are part of SearchCubit's library and intentionally call
// Cubit.emit to keep each responsibility in a focused file.
// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

part of 'search_cubit.dart';

extension SearchCubitSelection on SearchCubit {
  void _emitLocalServiceSelection({
    required int serviceId,
    required int categoryId,
    required bool isSelected,
    required Set<int> pendingServiceIds,
  }) {
    final currentData =
        state.servicesByCategoryId[categoryId] ??
        (state.servicesData?.categoryId == categoryId
            ? state.servicesData
            : null);
    final updatedData = currentData == null
        ? null
        : _copyCategoryServiceSelection(
            currentData,
            serviceId: serviceId,
            isSelected: isSelected,
          );

    final cachedCategories = Map<int, CategoryServicesDataModel>.from(
      state.servicesByCategoryId,
    );
    if (updatedData != null) cachedCategories[categoryId] = updatedData;

    final counts = Map<int, int>.from(state.categorySelectedCounts);
    final oldCount = counts[categoryId] ?? currentData?.totalSelectedCount ?? 0;
    final previousSelection = _serviceSelection(currentData, serviceId);
    counts[categoryId] =
        updatedData?.totalSelectedCount ??
        (previousSelection == isSelected
            ? oldCount
            : _nextSelectedCount(oldCount, increment: isSelected));
    final selectedMedicineIds = Set<int>.from(state.selectedMedicineIds);
    if (categoryId == 1) {
      if (isSelected) {
        selectedMedicineIds.add(serviceId);
      } else {
        selectedMedicineIds.remove(serviceId);
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[SearchCubit] local service update service=$serviceId selected=$isSelected',
      );
    }

    final visibleCategoryId = state.servicesData?.categoryId;
    emit(
      state.copyWith(
        pendingServiceIds: pendingServiceIds,
        servicesByCategoryId: cachedCategories,
        servicesData: visibleCategoryId == categoryId
            ? updatedData ?? state.servicesData
            : state.servicesData,
        services: visibleCategoryId == categoryId && updatedData != null
            ? updatedData.services?.items ?? const []
            : state.services,
        categorySelectedCounts: counts,
        selectedMedicineIds: selectedMedicineIds,
      ),
    );
  }

  CategoryServicesDataModel _copyCategoryServiceSelection(
    CategoryServicesDataModel data, {
    required int serviceId,
    required bool isSelected,
  }) {
    final services = data.services;
    if (services == null) return data;

    var changed = false;
    final updatedItems = (services.items ?? const <ServiceItemModel>[])
        .map((service) {
          if (service.serviceId != serviceId) return service;
          if (service.isSelected == isSelected) return service;
          changed = true;
          return ServiceItemModel(
            serviceId: service.serviceId,
            serviceNameEn: service.serviceNameEn,
            serviceNameAr: service.serviceNameAr,
            isSelected: isSelected,
          );
        })
        .toList(growable: false);

    final currentCount = data.totalSelectedCount ?? 0;
    return CategoryServicesDataModel(
      categoryId: data.categoryId,
      categoryName: data.categoryName,
      totalSelectedCount: changed
          ? _nextSelectedCount(currentCount, increment: isSelected)
          : currentCount,
      services: PagedServicesModel(
        items: updatedItems,
        pageNumber: services.pageNumber,
        pageSize: services.pageSize,
        totalCount: services.totalCount,
        totalPages: services.totalPages,
      ),
    );
  }

  int _nextSelectedCount(int current, {required bool increment}) {
    if (increment) return current + 1;
    return current > 0 ? current - 1 : 0;
  }

  bool? _serviceSelection(CategoryServicesDataModel? data, int serviceId) {
    final items = data?.services?.items ?? const <ServiceItemModel>[];
    for (final service in items) {
      if (service.serviceId == serviceId) return service.isSelected == true;
    }
    return null;
  }

  void _onCartSyncEvent(CartSyncEvent event) {
    if (isClosed) return;
    final selectedServiceIds = event.selectedServiceIds;
    if (selectedServiceIds != null) {
      _emitSelectionSnapshot(
        selectedServiceIds,
        selectedMedicineIds: event.selectedMedicineIds,
        categorySelectedCounts: event.categorySelectedCounts,
      );
      return;
    }
    if (event.cartCleared) {
      _emitAllServicesUnselected();
      _loadCartCounters();
      return;
    }

    final serviceId = event.serviceId;
    final isSelected = event.isSelected;
    if (serviceId == null || isSelected == null) return;

    final categoryId = event.categoryId;
    if (categoryId != null) {
      _emitLocalServiceSelection(
        serviceId: serviceId,
        categoryId: categoryId,
        isSelected: isSelected,
        pendingServiceIds: state.pendingServiceIds,
      );
    } else {
      _emitServiceSelectionInLoadedCategories(
        serviceId: serviceId,
        isSelected: isSelected,
      );
    }
    _loadCartCounters();
  }

  void _emitSelectionSnapshot(
    Set<int> selectedServiceIds, {
    Set<int>? selectedMedicineIds,
    Map<int, int>? categorySelectedCounts,
  }) {
    final cachedCategories = <int, CategoryServicesDataModel>{};
    for (final entry in state.servicesByCategoryId.entries) {
      final services = entry.value.services;
      final updatedItems = (services?.items ?? const <ServiceItemModel>[])
          .map(
            (service) => ServiceItemModel(
              serviceId: service.serviceId,
              serviceNameEn: service.serviceNameEn,
              serviceNameAr: service.serviceNameAr,
              isSelected: selectedServiceIds.contains(service.serviceId),
            ),
          )
          .toList(growable: false);
      final selectedCount =
          categorySelectedCounts?[entry.key] ??
          updatedItems.where((service) => service.isSelected == true).length;
      cachedCategories[entry.key] = CategoryServicesDataModel(
        categoryId: entry.value.categoryId,
        categoryName: entry.value.categoryName,
        totalSelectedCount: selectedCount,
        services: services == null
            ? null
            : PagedServicesModel(
                items: updatedItems,
                pageNumber: services.pageNumber,
                pageSize: services.pageSize,
                totalCount: services.totalCount,
                totalPages: services.totalPages,
              ),
      );
    }

    final visibleCategoryId = state.servicesData?.categoryId;
    final visibleData = visibleCategoryId == null
        ? state.servicesData
        : cachedCategories[visibleCategoryId] ?? state.servicesData;
    emit(
      state.copyWith(
        servicesByCategoryId: cachedCategories,
        servicesData: visibleData,
        services: visibleData?.services?.items ?? const [],
        categorySelectedCounts:
            categorySelectedCounts ?? state.categorySelectedCounts,
        selectedMedicineIds:
            selectedMedicineIds ??
            state.selectedMedicineIds.intersection(selectedServiceIds),
      ),
    );
  }

  void _emitServiceSelectionInLoadedCategories({
    required int serviceId,
    required bool isSelected,
  }) {
    var emitted = false;
    for (final entry in state.servicesByCategoryId.entries) {
      if (_serviceSelection(entry.value, serviceId) == null) continue;
      _emitLocalServiceSelection(
        serviceId: serviceId,
        categoryId: entry.key,
        isSelected: isSelected,
        pendingServiceIds: state.pendingServiceIds,
      );
      emitted = true;
    }
    if (!emitted && state.servicesData?.categoryId != null) {
      _emitLocalServiceSelection(
        serviceId: serviceId,
        categoryId: state.servicesData!.categoryId!,
        isSelected: isSelected,
        pendingServiceIds: state.pendingServiceIds,
      );
    }
  }

  void _emitAllServicesUnselected() {
    final cachedCategories = <int, CategoryServicesDataModel>{};
    for (final entry in state.servicesByCategoryId.entries) {
      cachedCategories[entry.key] = _copyAllCategoryServicesSelection(
        entry.value,
        isSelected: false,
      );
    }

    final visibleCategoryId = state.servicesData?.categoryId;
    final visibleData = visibleCategoryId == null
        ? state.servicesData
        : cachedCategories[visibleCategoryId] ?? state.servicesData;

    emit(
      state.copyWith(
        servicesByCategoryId: cachedCategories,
        servicesData: visibleData,
        services: visibleData?.services?.items ?? const [],
        categorySelectedCounts: const {},
        selectedMedicineIds: const {},
      ),
    );
  }

  CategoryServicesDataModel _copyAllCategoryServicesSelection(
    CategoryServicesDataModel data, {
    required bool isSelected,
  }) {
    final services = data.services;
    if (services == null) return data;
    return CategoryServicesDataModel(
      categoryId: data.categoryId,
      categoryName: data.categoryName,
      totalSelectedCount: isSelected ? data.totalSelectedCount : 0,
      services: PagedServicesModel(
        items: (services.items ?? const <ServiceItemModel>[])
            .map(
              (service) => ServiceItemModel(
                serviceId: service.serviceId,
                serviceNameEn: service.serviceNameEn,
                serviceNameAr: service.serviceNameAr,
                isSelected: isSelected,
              ),
            )
            .toList(growable: false),
        pageNumber: services.pageNumber,
        pageSize: services.pageSize,
        totalCount: services.totalCount,
        totalPages: services.totalPages,
      ),
    );
  }
}
