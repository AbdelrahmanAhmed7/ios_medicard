import '../../../../core/constants/api_result.dart';
import '../../data/models/lookup_model.dart';
import '../repositories/search_repository.dart';

class GetCitiesUseCase {
  final SearchRepository _repository;

  GetCitiesUseCase(this._repository);

  Future<ApiResult<List<LookupModel>>> call(int governorateId) async {
    return _repository.getCities(governorateId);
  }
}
