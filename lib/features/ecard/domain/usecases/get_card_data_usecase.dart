import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/card_data_response_model.dart';

class GetCardDataUseCase {
  final MedicardRepository _repository;

  GetCardDataUseCase(this._repository);

  Future<ApiResult<CardDataResponseModel>> call() async {
    return await _repository.getCardData();
  }
}
