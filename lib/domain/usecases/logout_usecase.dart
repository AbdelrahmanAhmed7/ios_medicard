import 'package:flutter/foundation.dart';

import '../../core/auth/auth_session_storage.dart';
import '../../core/constants/constants.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/network/dio_factory.dart';
import '../../core/services/selected_address_store.dart';

/// Single teardown point for signing the user out: session storage, cached
/// card number, and the auth header.
///
/// Screens and cubits navigate or delegate — they never clear credentials
/// themselves — so a credential-storage change touches this file only.
class LogoutUseCase {
  const LogoutUseCase();

  Future<void> call() async {
    try {
      await const AuthSessionStorage().clearSession();
      await SharedPrefHelper.removeData(SharedPrefKeys.medicardCardNo);
      await SelectedAddressStore.clear();
      DioFactory.clearTokenFromHeader();
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutUseCase] teardown: $e');
    }
  }
}
