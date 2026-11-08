import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/services/location_repository.dart';
import 'package:medicard/core/services/location_service.dart';
import 'package:medicard/features/cart/domain/models/cart.dart';
import 'package:medicard/features/cart/domain/models/category_counter.dart';
import 'package:medicard/features/cart/domain/models/category_services.dart';
import 'package:medicard/features/cart/domain/models/provider_option.dart';
import 'package:medicard/features/cart/domain/repository/cart_repository.dart';
import 'package:medicard/features/cart/domain/services/cart_sync_service.dart';
import 'package:medicard/features/search/data/models/category_model.dart';
import 'package:medicard/features/search/data/models/category_services_response_model.dart';
import 'package:medicard/features/search/data/models/lookup_model.dart';
import 'package:medicard/features/search/data/models/medicine_response_model.dart';
import 'package:medicard/features/search/data/models/search_provider_model.dart';
import 'package:medicard/features/search/data/models/search_response_model.dart';
import 'package:medicard/features/search/domain/repositories/search_repository.dart';
import 'package:medicard/features/search/domain/use_cases/get_categories_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/get_category_services_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/get_service_categories_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/search_providers_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/search_medicines_use_case.dart';
import 'package:medicard/features/search/presentation/cubit/search_cubit.dart';

void main() {
  group('SearchCubit services cart state', () {
    late _FakeSearchRepository searchRepository;
    late _FakeCartRepository cartRepository;
    late _FakeLocationService locationService;
    late LocationRepository locationRepository;
    late CartSyncService cartSyncService;
    late SearchCubit cubit;

    setUp(() {
      searchRepository = _FakeSearchRepository();
      cartRepository = _FakeCartRepository();
      locationService = _FakeLocationService(
        const LocationResult(status: LocationAccessStatus.denied),
      );
      locationRepository = LocationRepository();
      cartSyncService = CartSyncService();
      cubit = SearchCubit(
        SearchProvidersUseCase(searchRepository),
        SearchMedicinesUseCase(searchRepository),
        GetCategoriesUseCase(searchRepository),
        GetCategoryServicesUseCase(searchRepository),
        GetServiceCategoriesUseCase(searchRepository),
        cartRepository,
        cartSyncService,
        locationService: locationService,
        locationRepository: locationRepository,
      );
    });

    tearDown(() async {
      await cubit.close();
      cartSyncService.dispose();
    });

    test('loads category services and reuses cached category', () async {
      searchRepository.categoryServices[1] = _categoryData(1);

      await cubit.loadCategoryServices(1);
      await cubit.loadCategoryServices(1);

      expect(searchRepository.categoryServiceCalls[1], 1);
      expect(cubit.state.services.length, 2);
      expect(cubit.state.isLoadingServices, isFalse);
    });

    test('deduplicates in-flight category service requests', () async {
      final completer = Completer<ApiResult<CategoryServicesDataModel>>();
      searchRepository.categoryServiceCompleters[1] = completer;

      final firstLoad = cubit.loadCategoryServices(1);
      final secondLoad = cubit.loadCategoryServices(1);
      await Future<void>.delayed(Duration.zero);

      expect(searchRepository.categoryServiceCalls[1], 1);

      completer.complete(ApiResult.success(_categoryData(1)));
      await Future.wait([firstLoad, secondLoad]);

      expect(cubit.state.services.length, 2);
      expect(cubit.state.loadingServiceCategoryIds, isEmpty);
    });

    test(
      'late older category response does not replace latest category',
      () async {
        final first = Completer<ApiResult<CategoryServicesDataModel>>();
        final second = Completer<ApiResult<CategoryServicesDataModel>>();
        searchRepository.categoryServiceCompleters[1] = first;
        searchRepository.categoryServiceCompleters[2] = second;

        final firstLoad = cubit.loadCategoryServices(1);
        final secondLoad = cubit.loadCategoryServices(2);
        second.complete(ApiResult.success(_singleServiceCategory(2, 200)));
        await secondLoad;
        first.complete(ApiResult.success(_singleServiceCategory(1, 100)));
        await firstLoad;

        expect(cubit.state.servicesData?.categoryId, 2);
        expect(cubit.state.services.single.serviceId, 200);
        expect(
          cubit
              .state
              .servicesByCategoryId[1]
              ?.services
              ?.items
              ?.single
              .serviceId,
          100,
        );
      },
    );

    test(
      'latest category failure is shown and older success stays cached only',
      () async {
        final first = Completer<ApiResult<CategoryServicesDataModel>>();
        final second = Completer<ApiResult<CategoryServicesDataModel>>();
        searchRepository.categoryServiceCompleters[1] = first;
        searchRepository.categoryServiceCompleters[2] = second;

        final firstLoad = cubit.loadCategoryServices(1);
        final secondLoad = cubit.loadCategoryServices(2);
        second.complete(const ApiResult.failure('latest failed'));
        await secondLoad;
        first.complete(ApiResult.success(_singleServiceCategory(1, 100)));
        await firstLoad;

        expect(cubit.state.servicesError, 'latest failed');
        expect(cubit.state.servicesByCategoryId[1], isNotNull);
      },
    );

    test('add service success updates only loaded item locally', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      await cubit.loadCategoryServices(1);

      await cubit.addServiceToCart(serviceId: 2, categoryId: 1);

      expect(cartRepository.addCalls[2], 1);
      expect(searchRepository.categoryServiceCalls[1], 1);
      expect(cubit.state.isLoadingServices, isFalse);
      expect(_serviceSelected(cubit, 2), isTrue);
      expect(cubit.state.categorySelectedCounts[1], 2);
    });

    test('loads and paginates medicines using the search keyword', () async {
      searchRepository.medicinePages[1] = const MedicinePage(
        items: [MedicineModel(id: 165, enName: 'Abo Ali')],
        pageNumber: 1,
        pageSize: 1,
        totalCount: 2,
        totalPages: 2,
      );
      searchRepository.medicinePages[2] = const MedicinePage(
        items: [MedicineModel(id: 166, enName: 'Captopril')],
        pageNumber: 2,
        pageSize: 1,
        totalCount: 2,
        totalPages: 2,
      );

      await cubit.searchMedicines(search: 'cap');
      await cubit.loadMoreMedicines();

      expect(cubit.state.medicines.map((item) => item.id), [165, 166]);
      expect(searchRepository.medicineSearches, ['cap', 'cap']);
    });

    test('adds medicine id to cart as service id in category one', () async {
      await cubit.addServiceToCart(serviceId: 166, categoryId: 1, quantity: 1);

      expect(cartRepository.addCalls[166], 1);
      expect(cartRepository.addCategoryIds[166], 1);
      expect(cubit.state.selectedMedicineIds, contains(166));
    });

    test('add service failure preserves loaded data and selection', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      cartRepository.addResults[2] = const ApiResult.failure('Server error');
      await cubit.loadCategoryServices(1);

      await cubit.addServiceToCart(serviceId: 2, categoryId: 1);

      expect(cubit.state.services.length, 2);
      expect(cubit.state.isLoadingServices, isFalse);
      expect(_serviceSelected(cubit, 2), isFalse);
      expect(cubit.state.pendingServiceIds, isEmpty);
      expect(cubit.state.cartActionError, 'Server error');
    });

    test('cart action error is consumed after it is presented', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      cartRepository.addResults[2] = const ApiResult.failure('Server error');
      await cubit.loadCategoryServices(1);
      await cubit.addServiceToCart(serviceId: 2, categoryId: 1);

      cubit.consumeCartActionError();

      expect(cubit.state.cartActionError, isNull);
    });

    test('prevents duplicate pending add for same service', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      await cubit.loadCategoryServices(1);
      final completer = Completer<ApiResult<void>>();
      cartRepository.addCompleters[2] = completer;

      final firstAdd = cubit.addServiceToCart(serviceId: 2, categoryId: 1);
      final secondAdd = cubit.addServiceToCart(serviceId: 2, categoryId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(cartRepository.addCalls[2], 1);
      expect(cubit.state.pendingServiceIds, contains(2));

      completer.complete(const ApiResult.success(null));
      await Future.wait([firstAdd, secondAdd]);
      expect(cubit.state.pendingServiceIds, isEmpty);
    });

    test('supports two different pending services concurrently', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      await cubit.loadCategoryServices(1);
      final firstCompleter = Completer<ApiResult<void>>();
      final secondCompleter = Completer<ApiResult<void>>();
      cartRepository.addCompleters[1] = firstCompleter;
      cartRepository.addCompleters[2] = secondCompleter;

      final firstAdd = cubit.addServiceToCart(serviceId: 1, categoryId: 1);
      final secondAdd = cubit.addServiceToCart(serviceId: 2, categoryId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.pendingServiceIds, containsAll(<int>[1, 2]));

      firstCompleter.complete(const ApiResult.success(null));
      await firstAdd;
      expect(cubit.state.pendingServiceIds, contains(2));

      secondCompleter.complete(const ApiResult.success(null));
      await secondAdd;
      expect(cubit.state.pendingServiceIds, isEmpty);
      expect(_serviceSelected(cubit, 1), isTrue);
      expect(_serviceSelected(cubit, 2), isTrue);
    });

    test('remove service success and failure preserve loaded data', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      await cubit.loadCategoryServices(1);

      await cubit.removeServiceFromCart(serviceId: 1, categoryId: 1);
      expect(_serviceSelected(cubit, 1), isFalse);
      expect(cubit.state.categorySelectedCounts[1], 0);

      cartRepository.removeResults[1] = const ApiResult.failure('Timeout');
      await cubit.addServiceToCart(serviceId: 1, categoryId: 1);
      await cubit.removeServiceFromCart(serviceId: 1, categoryId: 1);

      expect(_serviceSelected(cubit, 1), isTrue);
      expect(cubit.state.services.length, 2);
      expect(cubit.state.cartActionError, 'Timeout');
    });

    test('ServiceAlreadyInCart reconciles item to selected', () async {
      searchRepository.categoryServices[1] = _categoryData(1);
      cartRepository.addResults[2] = const ApiResult.failure(
        'ServiceAlreadyInCart',
      );
      await cubit.loadCategoryServices(1);

      await cubit.addServiceToCart(serviceId: 2, categoryId: 1);

      expect(_serviceSelected(cubit, 2), isTrue);
      expect(cubit.state.cartActionError, isNull);
    });

    test(
      'authoritative selection snapshot preserves unrelated selected services',
      () async {
        searchRepository.categoryServices[1] = _categoryData(1);
        searchRepository.categoryServices[2] = _singleServiceCategory(2, 20);
        await cubit.loadCategoryServices(1);
        await cubit.loadCategoryServices(2);

        cartSyncService.selectionSnapshotChanged(
          selectedServiceIds: const [20],
          categorySelectedCounts: const {1: 0, 2: 1},
          refreshCart: false,
        );
        await Future<void>.delayed(Duration.zero);

        expect(
          cubit.state.servicesByCategoryId[1]!.services!.items!.every(
            (service) => service.isSelected == false,
          ),
          isTrue,
        );
        expect(
          cubit
              .state
              .servicesByCategoryId[2]!
              .services!
              .items!
              .single
              .isSelected,
          isTrue,
        );
        expect(cubit.state.categorySelectedCounts, {1: 0, 2: 1});
      },
    );

    test('provider search appends pages and stops at last page', () async {
      const provider1 = SearchProviderModel(providerId: 1);
      const provider2 = SearchProviderModel(providerId: 2);
      searchRepository.providerPages[1] = const SearchResponseData(
        items: [provider1],
        pageNumber: 1,
        pageSize: 15,
        totalCount: 2,
        totalPages: 2,
      );
      searchRepository.providerPages[2] = const SearchResponseData(
        items: [provider2],
        pageNumber: 2,
        pageSize: 15,
        totalCount: 2,
        totalPages: 2,
      );

      await cubit.search();
      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.currentPage, 1);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasMore, isFalse);

      await cubit.loadMore();
      expect(searchRepository.providerPages.keys, isNot(contains(3)));
      expect(cubit.state.items, hasLength(2));
    });

    test(
      'applyFilters nearest sort reuses cached location coordinates',
      () async {
        locationRepository.cache(LocationResult.granted(30.0444, 31.2357));
        searchRepository.providerPages[1] = const SearchResponseData(
          items: [SearchProviderModel(providerId: 1)],
          pageNumber: 1,
          pageSize: 15,
          totalCount: 1,
          totalPages: 1,
        );

        await cubit.applyFilters(sortBy: 1);

        expect(locationService.resolveCalls, 0);
        expect(cubit.state.userLatitude, 30.0444);
        expect(cubit.state.userLongitude, 31.2357);
        expect(cubit.state.filterError, isNull);
        expect(searchRepository.lastSortBy, 1);
        expect(searchRepository.lastUserLatitude, 30.0444);
        expect(searchRepository.lastUserLongitude, 31.2357);
      },
    );

    test(
      'applyFilters nearest sort resolves location when coordinates missing',
      () async {
        locationService.result = LocationResult.granted(29.987, 31.2143);
        searchRepository.providerPages[1] = const SearchResponseData(
          items: <SearchProviderModel>[SearchProviderModel(providerId: 1)],
          pageNumber: 1,
          pageSize: 15,
          totalCount: 1,
          totalPages: 1,
        );

        await cubit.applyFilters(sortBy: 1);

        expect(locationService.resolveCalls, 1);
        expect(cubit.state.userLatitude, 29.987);
        expect(cubit.state.userLongitude, 31.2143);
        expect(cubit.state.filterError, isNull);
        expect(searchRepository.lastSortBy, 1);
        expect(searchRepository.lastUserLatitude, 29.987);
        expect(searchRepository.lastUserLongitude, 31.2143);
      },
    );

    test(
      'applyFilters nearest sort without location falls back to default order',
      () async {
        searchRepository.providerPages[1] = const SearchResponseData(
          items: <SearchProviderModel>[SearchProviderModel(providerId: 1)],
          pageNumber: 1,
          pageSize: 15,
          totalCount: 1,
          totalPages: 1,
        );

        await cubit.applyFilters(sortBy: 1);

        expect(locationService.resolveCalls, 1);
        // The nearest sort must not be silently applied: coordinates are
        // unknown, the sort is dropped, the search runs in default order and
        // the user is informed.
        expect(cubit.state.userLatitude, isNull);
        expect(cubit.state.filterError, isNotNull);
        expect(searchRepository.lastSortBy, isNull);
        expect(searchRepository.lastUserLatitude, isNull);
        expect(searchRepository.lastUserLongitude, isNull);
      },
    );

    test('applyFilters non-nearest sort does not request location', () async {
      await cubit.applyFilters(sortBy: 2);

      expect(locationService.resolveCalls, 0);
      expect(cubit.state.filterError, isNull);
      expect(searchRepository.lastSortBy, 2);
    });

    test(
      'applyFilters does not touch category services (providers-only sort)',
      () async {
        searchRepository.categoryServices[1] = _categoryData(1);
        await cubit.loadCategoryServices(1);
        final callsBeforeFilter = searchRepository.categoryServiceCalls[1]!;

        await cubit.applyFilters(sortBy: 2);

        // The sort applies to the providers tab only: the services endpoints do
        // not support sorting and carry no discount data, so they must not be
        // refetched (or presented as re-ordered) when a filter is applied.
        expect(cubit.state.filterError, isNull);
        expect(searchRepository.lastSortBy, 2);
        expect(searchRepository.categoryServiceCalls[1], callsBeforeFilter);
      },
    );

    group('category loading failures surface an error instead of silence', () {
      test('categories failure sets categoriesError', () async {
        searchRepository.categoriesResult = const ApiResult.failure(
          'No network',
        );

        await cubit.init(enableCartFeatures: false);

        expect(cubit.state.categories, isEmpty);
        expect(cubit.state.categoriesError, 'No network');
      });

      test('service categories failure sets serviceCategoriesError', () async {
        searchRepository.serviceCategoriesResult = const ApiResult.failure(
          'Server down',
        );

        await cubit.init(enableCartFeatures: false);

        expect(cubit.state.serviceCategories, isEmpty);
        expect(cubit.state.serviceCategoriesError, 'Server down');
        expect(cubit.state.isLoadingServiceCategories, isFalse);
      });

      test('a successful retry clears the categories error', () async {
        searchRepository.categoriesResult = const ApiResult.failure(
          'No network',
        );
        await cubit.init(enableCartFeatures: false);
        expect(cubit.state.categoriesError, 'No network');

        searchRepository.categoriesResult = const ApiResult.success([
          CategoryModel(id: 9, name: 'Radiology'),
        ]);
        await cubit.init(enableCartFeatures: false);

        expect(cubit.state.categoriesError, isNull);
        expect(cubit.state.categories.map((c) => c.id), [9]);
      });
    });
  });
}

bool _serviceSelected(SearchCubit cubit, int serviceId) {
  return cubit.state.services
          .firstWhere((service) => service.serviceId == serviceId)
          .isSelected ==
      true;
}

CategoryServicesDataModel _categoryData(int categoryId) {
  return CategoryServicesDataModel(
    categoryId: categoryId,
    categoryName: 'Labs',
    totalSelectedCount: 1,
    services: const PagedServicesModel(
      items: [
        ServiceItemModel(serviceId: 1, serviceNameEn: 'MRI', isSelected: true),
        ServiceItemModel(
          serviceId: 2,
          serviceNameEn: 'X-Ray',
          isSelected: false,
        ),
      ],
      pageNumber: 1,
      pageSize: 20,
      totalCount: 2,
      totalPages: 1,
    ),
  );
}

CategoryServicesDataModel _singleServiceCategory(
  int categoryId,
  int serviceId,
) {
  return CategoryServicesDataModel(
    categoryId: categoryId,
    categoryName: 'Category $categoryId',
    totalSelectedCount: 0,
    services: PagedServicesModel(
      items: [
        ServiceItemModel(
          serviceId: serviceId,
          serviceNameEn: 'Service $serviceId',
        ),
      ],
      pageNumber: 1,
      pageSize: 20,
      totalCount: 1,
      totalPages: 1,
    ),
  );
}

class _FakeSearchRepository implements SearchRepository {
  final Map<int, CategoryServicesDataModel> categoryServices = {};
  final Map<int, Completer<ApiResult<CategoryServicesDataModel>>>
  categoryServiceCompleters = {};
  final Map<int, int> categoryServiceCalls = {};
  final Map<int, SearchResponseData> providerPages = {};
  final Map<int, MedicinePage> medicinePages = {};
  final List<String?> medicineSearches = [];

  ApiResult<List<CategoryModel>> categoriesResult = const ApiResult.success([]);
  ApiResult<List<CategoryModel>> serviceCategoriesResult =
      const ApiResult.success([
        CategoryModel(id: 1, name: 'Labs'),
        CategoryModel(id: 2, name: 'Scans'),
      ]);

  double? lastUserLatitude;
  double? lastUserLongitude;
  int? lastSortBy;

  @override
  Future<ApiResult<MedicinePage>> searchMedicines({
    String? search,
    int? pageNumber,
    int? pageSize,
  }) async {
    medicineSearches.add(search);
    return ApiResult.success(medicinePages[pageNumber] ?? const MedicinePage());
  }

  @override
  Future<ApiResult<SearchResponseData>> searchProviders({
    String? keyword,
    int? categoryId,
    int? governorateId,
    int? cityId,
    int? providerId,
    int? branchId,
    int? sortBy,
    double? userLatitude,
    double? userLongitude,
    int? pageNumber,
    int? pageSize,
  }) async {
    lastSortBy = sortBy;
    lastUserLatitude = userLatitude;
    lastUserLongitude = userLongitude;
    final page = providerPages[pageNumber];
    if (page != null) return ApiResult.success(page);
    return const ApiResult.success(
      SearchResponseData(items: [], totalPages: 1),
    );
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    return categoriesResult;
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getServiceCategories() async {
    return serviceCategoriesResult;
  }

  @override
  Future<ApiResult<List<LookupModel>>> getGovernorates() async {
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<List<LookupModel>>> getCities(int governorateId) async {
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<CategoryServicesDataModel>> getCategoryServices(
    int categoryId, {
    int? pageNumber,
    int? pageSize,
    bool skipAuthInterceptor = false,
  }) {
    categoryServiceCalls[categoryId] =
        (categoryServiceCalls[categoryId] ?? 0) + 1;
    final completer = categoryServiceCompleters[categoryId];
    if (completer != null) return completer.future;
    final data = categoryServices[categoryId] ?? _categoryData(categoryId);
    if (pageNumber != null && pageNumber > (data.services?.pageNumber ?? 1)) {
      return Future.value(
        ApiResult.success(
          CategoryServicesDataModel(
            categoryId: data.categoryId,
            categoryName: data.categoryName,
            totalSelectedCount: data.totalSelectedCount,
            services: const PagedServicesModel(
              items: [ServiceItemModel(serviceId: 3, serviceNameEn: 'CT-Scan')],
              pageNumber: 2,
              pageSize: 20,
              totalCount: 3,
              totalPages: 2,
            ),
          ),
        ),
      );
    }
    return Future.value(ApiResult.success(data));
  }

  @override
  Future<ApiResult<CategoryServicesDataModel>> getGuestCategoryServices(
    int categoryId, {
    String? search,
    int? pageNumber,
    int? pageSize,
  }) async {
    final data = categoryServices[categoryId];
    if (data != null) {
      if (pageNumber != null && pageNumber > (data.services?.pageNumber ?? 1)) {
        return ApiResult.success(
          CategoryServicesDataModel(
            categoryId: data.categoryId,
            categoryName: data.categoryName,
            services: const PagedServicesModel(
              items: [],
              pageNumber: 2,
              pageSize: 20,
              totalCount: 0,
              totalPages: 1,
            ),
          ),
        );
      }
      return ApiResult.success(data);
    }
    return ApiResult.success(
      CategoryServicesDataModel(
        categoryId: categoryId,
        services: const PagedServicesModel(
          items: [],
          pageNumber: 1,
          pageSize: 20,
          totalCount: 0,
          totalPages: 1,
        ),
      ),
    );
  }
}

class _FakeCartRepository implements CartRepository {
  final Map<int, int> addCalls = {};
  final Map<int, int> addCategoryIds = {};
  final Map<int, ApiResult<void>> addResults = {};
  final Map<int, Completer<ApiResult<void>>> addCompleters = {};
  final Map<int, ApiResult<void>> removeResults = {};

  @override
  Future<ApiResult<Cart>> getCart() async {
    return const ApiResult.success(
      Cart(
        items: [],
        totalCount: 1,
        categoryCounters: [
          CategoryCounter(categoryId: 1, categoryName: 'Labs', count: 1),
        ],
      ),
    );
  }

  @override
  Future<ApiResult<void>> addToCart({
    required int serviceId,
    required int categoryId,
    int? providerId,
    String? cardNumber,
    double? price,
  }) {
    addCalls[serviceId] = (addCalls[serviceId] ?? 0) + 1;
    addCategoryIds[serviceId] = categoryId;
    final completer = addCompleters[serviceId];
    if (completer != null) return completer.future;
    return Future.value(addResults[serviceId] ?? const ApiResult.success(null));
  }

  @override
  Future<ApiResult<void>> removeFromCart(int serviceId) async {
    return removeResults[serviceId] ?? const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> updateMedicineQuantity({
    required int serviceId,
    required int quantity,
  }) async => const ApiResult.success(null);

  @override
  Future<ApiResult<void>> addMedicineToCart({
    required int serviceId,
    required int categoryId,
    required int quantity,
  }) {
    addCalls[serviceId] = (addCalls[serviceId] ?? 0) + 1;
    addCategoryIds[serviceId] = categoryId;
    final completer = addCompleters[serviceId];
    if (completer != null) return completer.future;
    return Future.value(addResults[serviceId] ?? const ApiResult.success(null));
  }

  @override
  Future<ApiResult<List<ProviderOption>>> getMedicinePharmacies() async =>
      const ApiResult.success([]);

  @override
  Future<ApiResult<void>> updateMedicineProvider({
    required int providerId,
  }) async => const ApiResult.success(null);

  @override
  Future<ApiResult<CategoryServices>> getCategoryServices(
    int categoryId,
  ) async {
    return const ApiResult.success(CategoryServices(items: []));
  }

  @override
  Future<ApiResult<void>> clearCart() async {
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<List<ProviderOption>>> getChooseProviders() async {
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<void>> updateCartProvider({
    required int cartId,
    required int providerId,
  }) async {
    return const ApiResult.success(null);
  }
}

class _FakeLocationService extends LocationService {
  LocationResult result;
  int resolveCalls = 0;

  _FakeLocationService(this.result);

  @override
  Future<LocationResult> resolveLocation({
    bool requestIfNeeded = false,
    Future<bool> Function()? showRationaleDialog,
  }) async {
    resolveCalls++;
    return result;
  }
}
