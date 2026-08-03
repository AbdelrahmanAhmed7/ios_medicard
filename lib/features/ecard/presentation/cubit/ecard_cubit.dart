import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../domain/usecases/get_card_data_usecase.dart';
import 'ecard_state.dart';

class ECardCubit extends Cubit<ECardState> {
  final GetCardDataUseCase _getCardDataUseCase;
  Future<void>? _cardLoad;

  ECardCubit(this._getCardDataUseCase) : super(const ECardState.initial());

  Future<void> loadCardData({bool forceRefresh = false}) {
    if (isClosed) return Future.value();

    final activeLoad = _cardLoad;
    if (activeLoad != null) return activeLoad;

    final hasData = state.maybeWhen(
      loaded: (_) => true,
      orElse: () => false,
    );
    if (hasData && !forceRefresh) return Future.value();

    final load = _performLoad();
    _cardLoad = load;
    return load.whenComplete(() {
      if (identical(_cardLoad, load)) _cardLoad = null;
    });
  }

  Future<void> _performLoad() async {
    if (isClosed) return;
    emit(const ECardState.loading());
    try {
      final result = await _getCardDataUseCase.call();
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          if (kDebugMode) {
            debugPrint(
              '[ECardCubit] card loaded (hasData=${response.data != null})',
            );
          }
          emit(ECardState.loaded(response.data));
        },
        failure: (message) {
          if (isClosed) return;
          if (kDebugMode) {
            debugPrint('[ECardCubit] card load failed: $message');
          }
          emit(ECardState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      if (kDebugMode) debugPrint('[ECardCubit] card load exception: $e');
      emit(ECardState.failed(parseApiError(e)));
    }
  }
}
