import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/domain/usecases/logout_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LogoutUseCase', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('completes without throwing even when a step fails', () async {
      // Secure storage has no platform channel in unit tests; the use case
      // must swallow step failures so sign-out can never trap the user.
      const usecase = LogoutUseCase();
      await expectLater(usecase(), completes);
    });
  });
}
