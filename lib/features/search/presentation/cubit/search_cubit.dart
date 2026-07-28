import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_result.dart';
import '../../../cart/domain/repository/cart_repository.dart';
import '../../../cart/domain/services/cart_sync_service.dart';
import '../../data/models/category_services_response_model.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/get_category_services_use_case.dart';
import '../../domain/use_cases/get_service_categories_use_case.dart';
import '../../domain/use_cases/search_providers_use_case.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProvidersUseCase _searchProvidersUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCategoryServicesUseCase _getCategoryServicesUseCase;
  final GetServiceCategoriesUseCase _getServiceCategoriesUseCase;
  final CartRepository _cartRepository;
  final CartSyncService _cartSyncService;

  static const int _pageSize = 15;

  int? _governorateId;
  int? _cityId;
  int? _sortBy;
  StreamSubscription<CartSyncEvent>? _cartSyncSubscription;

  SearchCubit(
    this._searchProvidersUseCase,
    this._getCategoriesUseCase,
    this._getCategoryServicesUseCase,
    this._getServiceCategoriesUseCase,
    this._cartRepository,
    this._cartSyncService,
  ) : super(const SearchState()) {
    _cartSyncSubscription = _cartSyncService.stream.listen(_onCartSyncEvent);
  }

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
    await Future.wait([
      _loadCategories(),
      _loadServiceCategories(),
      _loadCartCounters(),
      search(),
    ]);
  }

  Future<void> _loadCategories() async {
    final result = await _getCategoriesUseCase.call();
    if (isClosed) return;
    result.when(
      success: (categories) => emit(state.copyWith(categories: categories)),
      failure: (_) {},
    );
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
          ),
        );
      },
      failure: (_) => emit(state.copyWith(isLoadingServiceCategories: false)),
    );
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
        emit(state.copyWith(categorySelectedCounts: counts));
      },
      failure: (_) {},
    );
  }

  Future<bool> loadCategoryServices(int categoryId) async {
    if (isClosed) return false;

    final cached = state.servicesByCategoryId[categoryId];
    if (cached != null) {
      if (kDebugMode) {
        debugPrint('[SearchCubit] reused cached services category=$categoryId');
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

    final result = await _getCategoryServicesUseCase.call(categoryId);
    if (isClosed) return false;

    final loadingIds = Set<int>.from(state.loadingServiceCategoryIds)
      ..remove(categoryId);

    return result.when(
      success: (data) {
        final counts = Map<int, int>.from(state.categorySelectedCounts);
        counts[categoryId] = data.totalSelectedCount ?? 0;
        final cachedCategories = Map<int, CategoryServicesDataModel>.from(
          state.servicesByCategoryId,
        )..[categoryId] = data;

        emit(
          state.copyWith(
            isLoadingServices: false,
            loadingServiceCategoryIds: loadingIds,
            servicesByCategoryId: cachedCategories,
            servicesData: data,
            services: data.services?.items ?? const [],
            clearServicesError: true,
            categorySelectedCounts: counts,
          ),
        );
        return (data.services?.items ?? const []).isNotEmpty;
      },
      failure: (message) {
        emit(
          state.copyWith(
            isLoadingServices: false,
            loadingServiceCategoryIds: loadingIds,
            servicesError: message,
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

  Future<void> addServiceToCart({
    required int serviceId,
    required int categoryId,
  }) async {
    if (isClosed) return;
    if (serviceId <= 0 || categoryId <= 0) {
      emit(
        state.copyWith(
          cartActionError:
              'Service data is incomplete. Please refresh and try again.',
        ),
      );
      return;
    }
    if (state.pendingServiceIds.contains(serviceId)) {
      if (kDebugMode) {
        debugPrint('[SearchCubit] duplicate add ignored service=$serviceId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[SearchCubit] add service started service=$serviceId');
    }
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
        clearCartActionError: true,
      ),
    );

    final result = await _cartRepository.addToCart(
      serviceId: serviceId,
      categoryId: categoryId,
      providerId: null,
      cardNumber: null,
      price: null,
    );

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingServiceIds)..remove(serviceId);

    result.when(
      success: (_) {
        _emitLocalServiceSelection(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
          pendingServiceIds: pending,
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: true,
        );
        _loadCartCounters();
      },
      failure: (message) {
        final alreadyInCart =
            message.contains('ServiceAlreadyInCart') ||
            message.toLowerCase().contains('already');
        if (alreadyInCart) {
          _emitLocalServiceSelection(
            serviceId: serviceId,
            categoryId: categoryId,
            isSelected: true,
            pendingServiceIds: pending,
          );
          _cartSyncService.serviceSelectionChanged(
            serviceId: serviceId,
            categoryId: categoryId,
            isSelected: true,
          );
          return;
        }
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] add service failed service=$serviceId message=$message',
          );
        }
        emit(
          state.copyWith(pendingServiceIds: pending, cartActionError: message),
        );
      },
    );
  }

  Future<void> removeServiceFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    if (isClosed) return;
    if (serviceId <= 0 || categoryId <= 0) {
      emit(
        state.copyWith(
          cartActionError:
              'Service data is incomplete. Please refresh and try again.',
        ),
      );
      return;
    }
    if (state.pendingServiceIds.contains(serviceId)) {
      if (kDebugMode) {
        debugPrint('[SearchCubit] duplicate remove ignored service=$serviceId');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[SearchCubit] remove service started service=$serviceId');
    }
    emit(
      state.copyWith(
        pendingServiceIds: {...state.pendingServiceIds, serviceId},
        clearCartActionError: true,
      ),
    );

    final result = await _cartRepository.removeFromCart(serviceId);

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingServiceIds)..remove(serviceId);

    result.when(
      success: (_) {
        _emitLocalServiceSelection(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
          pendingServiceIds: pending,
        );
        _cartSyncService.serviceSelectionChanged(
          serviceId: serviceId,
          categoryId: categoryId,
          isSelected: false,
        );
        _loadCartCounters();
      },
      failure: (message) {
        if (kDebugMode) {
          debugPrint(
            '[SearchCubit] remove service failed service=$serviceId message=$message',
          );
        }
        emit(
          state.copyWith(pendingServiceIds: pending, cartActionError: message),
        );
      },
    );
  }

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

  Future<void> loadMore() async {
    if (isClosed) return;
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: state.currentPage + 1);
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

  @override
  Future<void> close() {
    _cartSyncSubscription?.cancel();
    return super.close();
  }
}
