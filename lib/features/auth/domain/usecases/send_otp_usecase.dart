import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/otp_response_model.dart';

class SendOtpUseCase {
  final MedicardRepository _repository;

  SendOtpUseCase(this._repository);

  Future<ApiResult<OtpResponseModel>> call(String phoneNumber) {
    return _repository.sendOtp(phoneNumber);
  }
}
