import '../../core/constants/api_result.dart';
import '../../data/auth_login_request_model.dart';
import '../../data/auth_response_model.dart';
import '../medicard_repository.dart';

class LoginCardUseCase {
  final MedicardRepository _repository;

  LoginCardUseCase(this._repository);

  Future<ApiResult<AuthResponseModel>> call(
    AuthLoginRequestModel request,
  ) async {
    return await _repository.login(request);
  }
}
