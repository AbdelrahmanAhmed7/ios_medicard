import 'package:dartz/dartz.dart';
import '../../data/models/activate_card_request_model.dart';
import '../../data/models/activate_card_response_model.dart';
import '../repository/activate_card_repository.dart';

class ActivateCardUseCase {
  final ActivateCardRepository _repository;

  ActivateCardUseCase(this._repository);

  Future<Either<String, ActivateCardResponseModel>> call(
    ActivateCardRequestModel request,
  ) => _repository.activateCard(request);
}