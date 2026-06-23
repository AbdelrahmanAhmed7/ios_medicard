import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/profile_response_model.dart';

class GetProfileUseCase {
  final MedicardRepository _repository;

  GetProfileUseCase(this._repository);

  Future<ApiResult<ProfileResponseModel>> call() async {
    return await _repository.getProfile();
  }
}
