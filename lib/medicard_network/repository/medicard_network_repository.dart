import 'package:flutter/foundation.dart';

import '../../core/constants/api_result.dart';
import '../../core/utils/api_error_parser.dart';
import '../../network/data/city_response_model.dart';
import '../../network/data/government_response_model.dart';
import '../../network/data/network_category_response_model.dart';
import '../../network/data/network_provider_response_model.dart';
import '../../network/data/top_providers_slider_model.dart';
import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';
import '../service/medicard_network_api_service.dart';

class MedicardNetworkRepository {
  final MedicardNetworkApiService _apiService;

  MedicardNetworkRepository(this._apiService);

  String _cleanError(Object error) => parseApiError(error);

  void _logDebugError(String operation, Object error) {
    if (kDebugMode) {
      debugPrint('[$operation] ${_cleanError(error)}');
    }
  }

  Future<ApiResult<NetworkCategoryResponse>> getCategories(String lang) async {
    try {
      final response = await _apiService.getCategories(lang);
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      _logDebugError('getCategories', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<NetworkProviderResponse>> searchProviders({
    required String lang,
    String? cardNo,
    String? searchKey,
    int? categoryId,
    int? governmentId,
    int? cityId,
    double? latitude,
    double? longitude,
    bool? orderByDiscounts,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.searchProviders(
        lang,
        cardNo: cardNo,
        searchKey: searchKey,
        categoryId: categoryId,
        governmentId: governmentId,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
        orderByDiscounts: orderByDiscounts,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      _logDebugError('searchProviders', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<GovernmentResponse>> getGovernments(
    String lang, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiService.getGovernments(
        lang,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      _logDebugError('getGovernments', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<CityResponse>> getCitiesByGovernment(
    String lang,
    int governmentId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiService.getCitiesByGovernment(
        lang,
        governmentId: governmentId,
        page: page,
        pageSize: pageSize,
      );
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      _logDebugError('getCitiesByGovernment', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<TopProvidersSliderResponse>> getTopProvidersForSlider(
    String lang,
  ) async {
    try {
      final response = await _apiService.getTopProvidersForSlider(lang);
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      _logDebugError('getTopProvidersForSlider', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<ProviderPageResponse>> getProviderPage({
    required int providerId,
  }) async {
    try {
      final response = await _apiService.getProviderPage(providerId);
      if (kDebugMode) {
        debugPrint(
          '[getProviderPage] loaded providerId=$providerId '
          '(succeeded=${response.succeeded})',
        );
      }
      if (response.succeeded == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider page',
        );
      }
    } catch (e) {
      _logDebugError('getProviderPage', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<List<ProviderBranch>>> getProviderBranchLocations({
    required int providerId,
  }) async {
    try {
      final response = await _apiService.getProviderBranchLocations(providerId);
      if (response.succeeded == true) {
        return ApiResult.success(response.data ?? []);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider branches',
        );
      }
    } catch (e) {
      _logDebugError('getProviderBranchLocations', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<ProviderServicesResponse>> getProviderServices({
    required int providerId,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getProviderServices(
        providerId,
        search: search,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      if (response.succeeded == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider services',
        );
      }
    } catch (e) {
      _logDebugError('getProviderServices', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<ProviderReviewsResponse>> getProviderReviews({
    required int providerId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getProviderReviews(
        providerId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      if (response.succeeded == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider reviews',
        );
      }
    } catch (e) {
      _logDebugError('getProviderReviews', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<ProviderPackagesResponse>> getProviderPackages({
    required int providerId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.getProviderPackages(
        providerId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      if (response.succeeded == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider packages',
        );
      }
    } catch (e) {
      _logDebugError('getProviderPackages', e);
      return ApiResult.failure(_cleanError(e));
    }
  }

  Future<ApiResult<PackageDetailsResponse>> getPackageDetails({
    required int packageId,
  }) async {
    try {
      final response = await _apiService.getPackageDetails(packageId);
      if (response.succeeded == true && response.data != null) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load package details',
        );
      }
    } catch (e) {
      _logDebugError('getPackageDetails', e);
      return ApiResult.failure(_cleanError(e));
    }
  }
}
