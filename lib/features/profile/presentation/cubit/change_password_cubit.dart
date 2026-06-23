import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/utils/api_error_parser.dart';

import '../../domain/usecases/change_password_usecase.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordState.initial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (isClosed) return;
    emit(const ChangePasswordState.loading());
    try {
      final result = await _changePasswordUseCase.call(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      if (isClosed) return;
      result.when(
        success: (_) {
          if (isClosed) return;
          emit(const ChangePasswordState.success());
        },
        failure: (message) {
          if (isClosed) return;
          emit(ChangePasswordState.failure(message));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(ChangePasswordState.failure(parseApiError(e)));
    }
  }
}
