import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../cart/domain/repository/cart_repository.dart';
import '../../../cart/domain/services/cart_sync_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_services_response_model.dart';
import '../../data/models/search_provider_model.dart';
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
  final LocationService _locationService;
  final LocationRepository _locationRepository;

  static const int _pageSize = 15;
  static const int _servicesPageSize = 20;

  /// Sort value sent to the API for "Nearest to me". Must stay in sync with
  /// [FilterCubit]'s supported sort values.
  static const int _nearestSortValue = 1;

  int? _governorateId;
  int? _cityId;
  int? _sortBy;
  var _enableCartFeatures = true;
  StreamSubscription<CartSyncEvent>? _cartSyncSubscription;

  /// Search keyword used to load each category's services in guest mode,
  /// so the cache is invalidated when the keyword changes.
  final Map<int, String?> _guestServicesKeyword = {};

  /// Whether the services cache belongs to the current mode (auth vs guest).
  /// Guards against a logged-in session showing stale guest (or vice-versa)
  /// cached services, since [SearchCubit] is a shared singleton.
  bool? _servicesCacheMode = true;
  var _serviceCategoryRequestGeneration = 0;

  SearchCubit(
    this._searchProvidersUseCase,
    this._getCategoriesUseCase,
    this._getCategoryServicesUseCase,
    this._getServiceCategoriesUseCase,
    this._cartRepository,
    this._cartSyncService, {
    LocationService? locationService,
    LocationRepository? locationRepository,
  }) : _locationService = locationService ?? LocationService(),
       _locationRepository = locationRepository ?? LocationRepository(),
       super(const SearchState()) {
    _cartSyncSubscription = _cartSyncService.stream.listen(_onCartSyncEvent);
  }

  bool get enableCartFeatures => _enableCartFeatures;

  Future<void> init({
    double? lat,
    double? lng,
    int? categoryId,
    bool enableCartFeatures = true,
  }) async {
    if (isClosed) return;
    _enableCartFeatures = enableCartFeatures;
    _servicesCacheMode = enableCartFeatures;
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
      if (_enableCartFeatures) _loadCartCounters(),
      search(),
    ]);
  }

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
        emit(state.copyWith(categorySelectedCounts: counts));
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
            pageSize: _servicesPageSize,
          )
        : await _getCategoryServicesUseCase.callGuestServices(
            categoryId,
            search: search,
            pageNumber: 1,
            pageSize: _servicesPageSize,
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
            pageSize: _servicesPageSize,
          )
        : await _getCategoryServicesUseCase.callGuestServices(
            categoryId,
            search: _guestServicesKeyword[categoryId],
            pageNumber: nextPage,
            pageSize: _servicesPageSize,
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
            pageSize: paged?.pageSize ?? _servicesPageSize,
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

  Future<void> addServiceToCart({
    required int serviceId,
    required int categoryId,
  }) async {
    if (isClosed) return;
    if (!_enableCartFeatures) {
      emit(state.copyWith(cartActionError: 'auth.please_login_first'.tr()));
      return;
    }
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

  /// UI errors are one-shot events. Clearing after presentation prevents an
  /// unrelated state update from presenting the same message again.
  void consumeCartActionError() {
    if (isClosed || state.cartActionError == null) return;
    emit(state.copyWith(clearCartActionError: true));
  }

  Future<void> removeServiceFromCart({
    required int serviceId,
    required int categoryId,
  }) async {
    if (isClosed) return;
    if (!_enableCartFeatures) {
      emit(state.copyWith(cartActionError: 'auth.please_login_first'.tr()));
      return;
    }
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
    if (sortBy == _nearestSortValue &&
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
      pageSize: _pageSize,
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
              pageSize: data.pageSize ?? _pageSize,
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
    final selectedServiceIds = event.selectedServiceIds;
    if (selectedServiceIds != null) {
      _emitSelectionSnapshot(
        selectedServiceIds,
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
