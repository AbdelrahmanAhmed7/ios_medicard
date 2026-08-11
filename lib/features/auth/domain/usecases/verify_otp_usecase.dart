import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/otp_response_model.dart';

class VerifyOtpUseCase {
  final MedicardRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<ApiResult<OtpResponseModel>> call({
    required String phoneNumber,
    required String otp,
  }) {
    return _repository.verifyOtp(phoneNumber: phoneNumber, otp: otp);
  }
}
