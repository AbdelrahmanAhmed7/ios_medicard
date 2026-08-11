import '../../../../core/constants/api_result.dart';
import '../../../../domain/medicard_repository.dart';
import '../../data/models/member_card_activation_response_model.dart';

class ActivateMemberCardUseCase {
  final MedicardRepository _repository;

  ActivateMemberCardUseCase(this._repository);

  Future<ApiResult<MemberCardActivationResponseModel>> call({
    required String cardNumber,
  }) {
    return _repository.activateMemberCard(cardNumber: cardNumber);
  }
}
