import '../../core/constants/api_result.dart';
import '../../data/auth_register_request_model.dart';
import '../../data/auth_response_model.dart';
import '../medicard_repository.dart';

class RegisterUseCase {
  final MedicardRepository _repository;

  RegisterUseCase(this._repository);

  Future<ApiResult<AuthResponseModel>> call(
    AuthRegisterRequestModel request,
  ) async {
    return await _repository.register(request);
  }
}
