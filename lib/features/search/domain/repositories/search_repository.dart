import '../../../../core/constants/api_result.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_services_response_model.dart';
import '../../data/models/lookup_model.dart';
import '../../data/models/search_provider_model.dart';

abstract class SearchRepository {
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
  });

  Future<ApiResult<List<CategoryModel>>> getCategories();

  Future<ApiResult<List<CategoryModel>>> getServiceCategories();

  Future<ApiResult<List<LookupModel>>> getGovernorates();

  Future<ApiResult<List<LookupModel>>> getCities(int governorateId);

  Future<ApiResult<CategoryServicesDataModel>> getCategoryServices(
    int categoryId,
    bool skipAuthInterceptor,
  );
}
