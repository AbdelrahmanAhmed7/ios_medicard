import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/guest_home_response_model.dart';

part 'guest_home_state.freezed.dart';

@freezed
class GuestHomeState with _$GuestHomeState {
  const factory GuestHomeState.initial() = _Initial;
  const factory GuestHomeState.loading() = _Loading;
  const factory GuestHomeState.success(GuestHomeResponseModel data) = _Success;
  const factory GuestHomeState.failed(String error) = _Failed;
}
