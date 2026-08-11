import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/otp_response_model.dart';

class ResetPasswordUseCase {
  final MedicardRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<ApiResult<OtpResponseModel>> call({
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
