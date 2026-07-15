import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../core/constants/constants.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/auth_session_storage.dart';
import '../../core/auth/jwt_helper.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/utils/api_error_parser.dart';
import '../../data/auth_register_request_model.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState.initial());

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required bool isMale,
    required String birthDate,
    required String password,
    required String confirmPassword,
    String? nationalId,
    String? passportNumber,
  }) async {
    emit(const RegisterState.loading());

    try {
      final request = AuthRegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        isMale: isMale,
        birthDate: birthDate,
        password: password,
        confirmPassword: confirmPassword,
        nationalId: nationalId,
        passportNumber: passportNumber,
      );

      final result = await _registerUseCase.call(request);

      result.when(
        success: (response) async {
          final data = response.data;
          if (data?.token != null) {
            await SharedPrefHelper.setSecuredString(
              SharedPrefKeys.userToken,
              data!.token,
            );
            await const AuthSessionStorage().saveSession(
              AuthSession(
                accessToken: data.token,
                refreshToken: data.refreshToken ?? '',
                accessTokenExpiresAt:
                    data.expiresAt ?? getJwtExpiryDate(data.token),
                refreshTokenExpiresAt: data.refreshTokenExpiresAt,
              ),
            );
          }
          emit(RegisterState.success(response));
        },
        failure: (message) {
          emit(RegisterState.failed(error: message));
        },
      );
    } catch (e) {
      emit(RegisterState.failed(error: parseApiError(e)));
    }
  }
}
