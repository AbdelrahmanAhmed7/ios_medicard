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
import '../../domain/use_cases/search_medicines_use_case.dart';
import 'search_state.dart';

part 'search_cubit_loading.dart';
part 'search_cubit_services.dart';
part 'search_cubit_cart.dart';
part 'search_cubit_provider_search.dart';
part 'search_cubit_selection.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchProvidersUseCase _searchProvidersUseCase;
  final SearchMedicinesUseCase _searchMedicinesUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCategoryServicesUseCase _getCategoryServicesUseCase;
  final GetServiceCategoriesUseCase _getServiceCategoriesUseCase;
  final CartRepository _cartRepository;
  final CartSyncService _cartSyncService;
  final LocationService _locationService;
  final LocationRepository _locationRepository;

  static const int _pageSize = 15;
  static const int _servicesPageSize = 20;
  static const int _medicinesPageSize = 15;

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
  var _medicineRequestGeneration = 0;
  String? _medicineKeyword;

  SearchCubit(
    this._searchProvidersUseCase,
    this._searchMedicinesUseCase,
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

  @override
  Future<void> close() {
    _cartSyncSubscription?.cancel();
    return super.close();
  }
}
