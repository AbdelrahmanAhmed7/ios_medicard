import '../../core/constants/api_result.dart';
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

  Future<ApiResult<NetworkCategoryResponse>> getCategories(String lang) async {
    try {
      final response = await _apiService.getCategories(lang);
      if (response.success) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (e) {
      return ApiResult.failure(e.toString());
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
      return ApiResult.failure(e.toString());
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
      return ApiResult.failure(e.toString());
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
      return ApiResult.failure(e.toString());
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
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<ProviderPageResponse>> getProviderPage({
    required int providerId,
  }) async {
    try {
      final response = await _apiService.getProviderPage(providerId);
      print('🟡 getProviderPage FULL RESPONSE JSON: ${response.toJson()}');
      if (response.succeeded == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(
          response.message ?? 'Failed to load provider page',
        );
      }
    } catch (e, s) {
      print('getProviderPage error: $e');
      print('Stack trace: $s');
      return ApiResult.failure(e.toString());
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
    } catch (e, s) {
      print('getProviderServices error: $e');
      print('Stack trace: $s');
      return ApiResult.failure(e.toString());
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
    } catch (e, s) {
      print('getProviderReviews error: $e');
      print('Stack trace: $s');
      return ApiResult.failure(e.toString());
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
    } catch (e, s) {
      print('getProviderPackages error: $e');
      print('Stack trace: $s');
      return ApiResult.failure(e.toString());
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
      return ApiResult.failure(e.toString());
    }
  }
}
