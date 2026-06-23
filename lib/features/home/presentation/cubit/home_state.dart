import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/home_response_model.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.success(HomeResponseModel data) = _Success;
  const factory HomeState.failed(String error) = _Failed;
}
