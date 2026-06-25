import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/guest_home_response_model.dart';

class GetGuestHomeDataUseCase {
  final MedicardRepository _repository;

  GetGuestHomeDataUseCase(this._repository);

  Future<ApiResult<GuestHomeResponseModel>> call({
    double? latitude,
    double? longitude,
  }) async {
    return await _repository.getGuestHomeData(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
