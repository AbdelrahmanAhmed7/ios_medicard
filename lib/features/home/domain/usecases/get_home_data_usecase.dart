import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/home_response_model.dart';

class GetHomeDataUseCase {
  final MedicardRepository _repository;

  GetHomeDataUseCase(this._repository);

  Future<ApiResult<HomeResponseModel>> call({
    double? latitude,
    double? longitude,
  }) async {
    return await _repository.getHomeData(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
