import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../core/constants/api_result.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/auth_session_storage.dart';
import '../../core/auth/jwt_helper.dart';
import '../../core/network/dio_factory.dart';
import '../../core/cubit/app_refresh_cubit.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/api_error_parser.dart';
import '../../core/utils/platform_type.dart';
import '../../data/auth_login_request_model.dart';
import '../../domain/usecases/login_card_usecase.dart';
import '../../features/notifications/push_notification_service.dart';
import 'medicard_login_state.dart';

class MedicardLoginCubit extends Cubit<MedicardLoginState> {
  final LoginCardUseCase _loginCardUseCase;

  MedicardLoginCubit(this._loginCardUseCase)
    : super(const MedicardLoginState.initial());

  Future<void> login({
    String? cardNumber,
    String? phoneNumber,
    required String password,
  }) async {
    emit(const MedicardLoginState.loading());

    try {
      final request = AuthLoginRequestModel(
        cardNumber: cardNumber,
        phoneNumber: phoneNumber,
        password: password,
        platformType: PlatformType.current.value,
      );

      final result = await _loginCardUseCase.call(request);
      if (isClosed) return;

      await result.when<Future<void>>(
        success: (response) async {
          final data = response.data;
          final token = data?.token;
          final refreshToken = data?.refreshToken;
          if (token == null ||
              token.isEmpty ||
              refreshToken == null ||
              refreshToken.isEmpty) {
            if (isClosed) return;
            emit(MedicardLoginState.failed(error: parseApiError('')));
            return;
          }

          await const AuthSessionStorage().saveSession(
            AuthSession(
              accessToken: token,
              refreshToken: refreshToken,
              accessTokenExpiresAt: data?.expiresAt ?? getJwtExpiryDate(token),
              refreshTokenExpiresAt: data?.refreshTokenExpiresAt,
            ),
          );
          DioFactory.setTokenIntoHeaderAfterLogin(token);
          sl<AppRefreshCubit>().triggerAuthRefresh();
          // The FCM token may have arrived before login (or rotated); bind
          // this device to the user now so pushes can reach it.
          unawaited(PushNotificationService.instance.registerDeviceToken());
          if (isClosed) return;
          emit(MedicardLoginState.success(response));
        },
        failure: (message) async {
          if (isClosed) return;
          emit(MedicardLoginState.failed(error: message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(MedicardLoginState.failed(error: parseApiError(e)));
    }
  }
}
