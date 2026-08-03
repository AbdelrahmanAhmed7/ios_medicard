import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/constants/constants.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/auth_session_storage.dart';
import '../../core/auth/jwt_helper.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/network/dio_factory.dart';
import '../../core/utils/api_error_parser.dart';
import '../../data/auth_login_request_model.dart';
import '../../domain/usecases/login_card_usecase.dart';
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
      );

      final result = await _loginCardUseCase.call(request);

      result.when(
        success: (response) async {
          final data = response.data;
          final token = data?.token;
          if (token != null && token.isNotEmpty) {
            await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.userToken,
              token,
            );
            await const AuthSessionStorage().saveSession(
              AuthSession(
                accessToken: token,
                refreshToken: data?.refreshToken ?? '',
                accessTokenExpiresAt:
                    data?.expiresAt ?? getJwtExpiryDate(token),
                refreshTokenExpiresAt: data?.refreshTokenExpiresAt,
              ),
            );
            DioFactory.setTokenIntoHeaderAfterLogin(token);
          }
          emit(MedicardLoginState.success(response));
        },
        failure: (message) {
          emit(MedicardLoginState.failed(error: message));
        },
      );
    } catch (e) {
      emit(MedicardLoginState.failed(error: parseApiError(e)));
    }
  }
}
