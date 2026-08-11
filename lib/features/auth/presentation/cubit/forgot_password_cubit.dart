import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgotPasswordCubit(
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._resetPasswordUseCase,
  ) : super(const ForgotPasswordState.initial());

  Future<void> sendOtp(String phoneNumber) async {
    if (isClosed) return;
    emit(const ForgotPasswordState.loading());
    try {
      final result = await _sendOtpUseCase.call(phoneNumber);
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          final otp = response.data;
          if (otp == null || otp.isEmpty) {
            emit(ForgotPasswordState.failed(
              'auth.forgot.otp_not_received'.tr(),
            ));
            return;
          }
          emit(ForgotPasswordState.otpSent(phoneNumber, otp));
        },
        failure: (message) {
          if (isClosed) return;
          emit(ForgotPasswordState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ForgotPasswordState.failed(parseApiError(e)));
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (isClosed) return;
    emit(const ForgotPasswordState.loading());
    try {
      final result = await _verifyOtpUseCase.call(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      if (isClosed) return;
      result.when(
        success: (response) {
          if (isClosed) return;
          final token = response.data;
          if (token == null || token.isEmpty) {
            emit(ForgotPasswordState.failed(
              'auth.forgot.otp_invalid'.tr(),
            ));
            return;
          }
          emit(ForgotPasswordState.otpVerified(phoneNumber, token));
        },
        failure: (message) {
          if (isClosed) return;
          emit(ForgotPasswordState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ForgotPasswordState.failed(parseApiError(e)));
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    if (isClosed) return;
    emit(const ForgotPasswordState.loading());
    try {
      final result = await _resetPasswordUseCase.call(
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (isClosed) return;
      result.when(
        success: (_) {
          if (isClosed) return;
          emit(const ForgotPasswordState.resetSuccess());
        },
        failure: (message) {
          if (isClosed) return;
          emit(ForgotPasswordState.failed(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ForgotPasswordState.failed(parseApiError(e)));
    }
  }
}
