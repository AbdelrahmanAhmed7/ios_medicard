import 'package:dartz/dartz.dart';
import '../../data/models/activate_card_request_model.dart';
import '../../data/models/activate_card_response_model.dart';

abstract class ActivateCardRepository {
  Future<Either<String, ActivateCardResponseModel>> activateCard(
    ActivateCardRequestModel request,
  );
}