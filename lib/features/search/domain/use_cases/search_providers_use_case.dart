import '../../../../core/constants/api_result.dart';
import '../../data/models/search_response_model.dart';
import '../repositories/search_repository.dart';

class SearchProvidersUseCase {
  final SearchRepository _repository;

  SearchProvidersUseCase(this._repository);

  Future<ApiResult<SearchResponseData>> call({
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
    return _repository.searchProviders(
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
  }
}
