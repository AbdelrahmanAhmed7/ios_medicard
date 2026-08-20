import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/cart/domain/models/cart.dart';
import 'package:medicard/features/cart/domain/models/category_counter.dart';
import 'package:medicard/features/cart/domain/models/category_services.dart';
import 'package:medicard/features/cart/domain/models/provider_option.dart';
import 'package:medicard/features/cart/domain/repository/cart_repository.dart';
import 'package:medicard/features/cart/domain/services/cart_sync_service.dart';
import 'package:medicard/features/search/data/models/category_model.dart';
import 'package:medicard/features/search/data/models/category_services_response_model.dart';
import 'package:medicard/features/search/data/models/lookup_model.dart';
import 'package:medicard/features/search/data/models/search_provider_model.dart';
import 'package:medicard/features/search/data/models/search_response_model.dart';
import 'package:medicard/features/search/domain/repositories/search_repository.dart';
import 'package:medicard/features/search/domain/use_cases/get_categories_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/get_category_services_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/get_service_categories_use_case.dart';
import 'package:medicard/features/search/domain/use_cases/search_providers_use_case.dart';
import 'package:medicard/features/search/presentation/cubit/search_cubit.dart';

void main() {
  group('SearchCubit services cart state', () {
    late _FakeSearchRepository searchRepository;
    late _FakeCartRepository cartRepository;
    late SearchCubit cubit;

    setUp(() {
      searchRepository = _FakeSearchRepository();
      cartRepository = _FakeCartRepository();
      cubit = SearchCubit(
        SearchProvidersUseCase(searchRepository),
        GetCategoriesUseCase(searchRepository),
        GetCategoryServicesUseCase(searchRepository),
        GetServiceCategoriesUseCase(searchRepository),
        cartRepository,
        CartSyncService(),
      );
    });

    tearDown(() => cubit.close());

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

    test('provider search appends pages and stops at last page', () async {
      final provider1 = const SearchProviderModel(providerId: 1);
      final provider2 = const SearchProviderModel(providerId: 2);
      searchRepository.providerPages[1] = SearchResponseData(
        items: [provider1],
        pageNumber: 1,
        pageSize: 15,
        totalCount: 2,
        totalPages: 2,
      );
      searchRepository.providerPages[2] = SearchResponseData(
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

class _FakeSearchRepository implements SearchRepository {
  final Map<int, CategoryServicesDataModel> categoryServices = {};
  final Map<int, Completer<ApiResult<CategoryServicesDataModel>>>
  categoryServiceCompleters = {};
  final Map<int, int> categoryServiceCalls = {};
  final Map<int, SearchResponseData> providerPages = {};

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
    final page = providerPages[pageNumber];
    if (page != null) return ApiResult.success(page);
    return const ApiResult.success(
      SearchResponseData(items: [], totalPages: 1),
    );
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    return const ApiResult.success([]);
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getServiceCategories() async {
    return const ApiResult.success([
      CategoryModel(id: 1, name: 'Labs'),
      CategoryModel(id: 2, name: 'Scans'),
    ]);
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
              items: [
                ServiceItemModel(serviceId: 3, serviceNameEn: 'CT-Scan'),
              ],
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
}

class _FakeCartRepository implements CartRepository {
  final Map<int, int> addCalls = {};
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
    final completer = addCompleters[serviceId];
    if (completer != null) return completer.future;
    return Future.value(addResults[serviceId] ?? const ApiResult.success(null));
  }

  @override
  Future<ApiResult<void>> removeFromCart(int serviceId) async {
    return removeResults[serviceId] ?? const ApiResult.success(null);
  }

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
