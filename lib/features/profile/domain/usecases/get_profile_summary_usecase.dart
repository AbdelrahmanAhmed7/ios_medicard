import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/profile_summary_response_model.dart';

class GetProfileSummaryUseCase {
  final MedicardRepository _repository;

  GetProfileSummaryUseCase(this._repository);

  Future<ApiResult<ProfileSummaryResponseModel>> call() async {
    return await _repository.getProfileSummary();
  }
}
