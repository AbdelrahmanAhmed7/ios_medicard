import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../data/data_sources/search_remote_data_source.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_services_response_model.dart';
import '../../data/models/lookup_model.dart';
import '../../data/models/search_response_model.dart';
import '../../data/models/medicine_response_model.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _dataSource;

  SearchRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<MedicinePage>> searchMedicines({
    String? search,
    int? pageNumber,
    int? pageSize,
  }) async => const ApiResult.failure('Medicine search is not supported.');

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
    try {
      final response = await _dataSource.searchProviders(
        keyword: keyword,
        categoryId: categoryId,
        governorateId: governorateId,
        cityId: cityId,
        providerId: providerId,
        branchId: branchId,
        sortBy: sortBy,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              _responseMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to search providers.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dataSource.getCategories();
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to load categories.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getServiceCategories() async {
    try {
      final response = await _dataSource.getServiceCategories();
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to load service categories.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<LookupModel>>> getGovernorates() async {
    try {
      final response = await _dataSource.getGovernorates();
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to load governorates.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<LookupModel>>> getCities(int governorateId) async {
    try {
      final response = await _dataSource.getCities(governorateId);
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to load cities.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CategoryServicesDataModel>> getCategoryServices(
    int categoryId, {
    int? pageNumber,
    int? pageSize,
    bool skipAuthInterceptor = false,
  }) async {
    try {
      final response = await _dataSource.getCategoryServices(
        categoryId,
        pageNumber,
        pageSize,
        skipAuthInterceptor
            ? {'skipAuthInterceptor': true}
            : const <String, dynamic>{},
      );
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(response.data!)
          : ApiResult.failure(
              _responseMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to load category services.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CategoryServicesDataModel>> getGuestCategoryServices(
    int categoryId, {
    String? search,
    int? pageNumber,
    int? pageSize,
  }) async {
    try {
      final response = await _dataSource.getGuestCategoryServices(
        categoryId,
        search,
        pageNumber,
        pageSize,
      );
      return (response.succeeded == true && response.data != null)
          ? ApiResult.success(
              response.data!.toCategoryServicesDataModel(categoryId),
            )
          : ApiResult.failure(
              _responseMessage(
                errors: response.errors,
                message: response.message,
                fallback: 'Failed to load category services.',
              ),
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}

String _responseMessage({
  required dynamic errors,
  required String? message,
  required String fallback,
}) {
  final errorText = _extractMessages(errors);
  if (errorText.isNotEmpty) return errorText;
  if (message?.trim().isNotEmpty == true) return message!.trim();
  return fallback;
}

String _extractMessages(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Iterable) {
    return value
        .map(_extractMessages)
        .where((message) => message.isNotEmpty)
        .join('\n');
  }
  if (value is Map) {
    return value.values
        .map(_extractMessages)
        .where((message) => message.isNotEmpty)
        .join('\n');
  }
  return value.toString().trim();
}
