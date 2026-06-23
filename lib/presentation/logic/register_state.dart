import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/auth_response_model.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = Initial;
  const factory RegisterState.loading() = Loading;
  const factory RegisterState.success(AuthResponseModel response) = Success;
  const factory RegisterState.failed({required String error}) = Failed;
}
