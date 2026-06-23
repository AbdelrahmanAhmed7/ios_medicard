import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/change_password_response_model.dart';

class ChangePasswordUseCase {
  final MedicardRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<ApiResult<ChangePasswordResponseModel>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
