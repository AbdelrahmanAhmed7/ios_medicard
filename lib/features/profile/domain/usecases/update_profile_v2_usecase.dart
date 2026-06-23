import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/profile_response_model.dart';

class UpdateProfileV2UseCase {
  final MedicardRepository _repository;

  UpdateProfileV2UseCase(this._repository);

  Future<ApiResult<ProfileResponseModel>> call({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
  }) async {
    return await _repository.updateProfileV2(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      nationalId: nationalId,
      passportNumber: passportNumber,
      isMale: isMale,
      birthDate: birthDate,
      imagePath: imagePath,
    );
  }
}
