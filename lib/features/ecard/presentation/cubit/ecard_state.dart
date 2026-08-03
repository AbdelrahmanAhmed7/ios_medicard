import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/card_data_response_model.dart';

part 'ecard_state.freezed.dart';

@freezed
class ECardState with _$ECardState {
  const factory ECardState.initial() = _Initial;
  const factory ECardState.loading() = _Loading;
  const factory ECardState.loaded(CardData? data) = _Loaded;
  const factory ECardState.failed(String error) = _Failed;
}
