import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/activate_card_request_model.dart';
import '../../domain/usecases/activate_card_usecase.dart';
import 'activate_card_state.dart';

class ActivateCardCubit extends Cubit<ActivateCardState> {
  final ActivateCardUseCase _useCase;

  ActivateCardCubit(this._useCase) : super(ActivateCardInitial());

  Future<void> activateCard(ActivateCardRequestModel request) async {
    emit(ActivateCardLoading());
    final result = await _useCase(request);
    result.fold(
      (error) => emit(ActivateCardError(error)),
      (response) => emit(ActivateCardSuccess(response)),
    );
  }
}