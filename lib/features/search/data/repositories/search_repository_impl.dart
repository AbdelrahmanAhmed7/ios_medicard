import '../../../../core/constants/api_result.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/helpers/shared_pref_helper.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../data/data_sources/search_remote_data_source.dart';
import '../../data/models/category_model.dart';
import '../../data/models/lookup_model.dart';
import '../../data/models/search_provider_model.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _dataSource;

  SearchRepositoryImpl(this._dataSource);

  Future<String> get _bearerToken async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    return 'Bearer $token';
  }

  @override
  Future<ApiResult<List<SearchProviderModel>>> searchProviders({
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
      final token = await _bearerToken;
      final response = await _dataSource.searchProviders(
        token,
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
          ? ApiResult.success(response.data!.items ?? [])
          : ApiResult.failure(
              (response.errors != null && response.errors!.isNotEmpty)
                  ? response.errors!.join('\n')
                  : response.message?.isNotEmpty == true
                  ? response.message!
                  : 'Failed to search providers.',
            );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.getCategories(token);
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
  Future<ApiResult<List<LookupModel>>> getGovernorates() async {
    try {
      final token = await _bearerToken;
      final response = await _dataSource.getGovernorates(token);
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
      final token = await _bearerToken;
      final response = await _dataSource.getCities(token, governorateId);
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
}
