import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/profile_response_model.dart';

class DeleteProfileImageUseCase {
  final MedicardRepository _repository;

  DeleteProfileImageUseCase(this._repository);

  Future<ApiResult<ProfileResponseModel>> call() {
    return _repository.deleteProfileImage();
  }
}
