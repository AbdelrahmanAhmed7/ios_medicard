import '../../data/models/activate_card_response_model.dart';

abstract class ActivateCardState {}

class ActivateCardInitial extends ActivateCardState {}

class ActivateCardLoading extends ActivateCardState {}

class ActivateCardSuccess extends ActivateCardState {
  final ActivateCardResponseModel response;

  ActivateCardSuccess(this.response);
}

class ActivateCardError extends ActivateCardState {
  final String message;

  ActivateCardError(this.message);
}