import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_state.freezed.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _Initial;
  const factory ForgotPasswordState.loading() = _Loading;
  const factory ForgotPasswordState.otpSent(String phoneNumber, String otp) =
      _OtpSent;
  const factory ForgotPasswordState.otpVerified(
    String phoneNumber,
    String token,
  ) = _OtpVerified;
  const factory ForgotPasswordState.resetSuccess() = _ResetSuccess;
  const factory ForgotPasswordState.failed(String error) = _Failed;
}
