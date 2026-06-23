import '../../../../core/constants/api_result.dart';
import '../../data/models/lookup_model.dart';
import '../repositories/search_repository.dart';

class GetGovernoratesUseCase {
  final SearchRepository _repository;

  GetGovernoratesUseCase(this._repository);

  Future<ApiResult<List<LookupModel>>> call() async {
    return _repository.getGovernorates();
  }
}
