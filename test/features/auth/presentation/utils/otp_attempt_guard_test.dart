import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/auth/presentation/utils/otp_attempt_guard.dart';

void main() {
  group('OtpAttemptGuard', () {
    test('blocks the third submission of the same OTP', () {
      final guard = OtpAttemptGuard();

      expect(guard.tryRegister('1234'), isTrue);
      expect(guard.tryRegister('1234'), isTrue);
      expect(guard.tryRegister('1234'), isFalse);
    });

    test('tracks different OTP values independently', () {
      final guard = OtpAttemptGuard();

      expect(guard.tryRegister('1234'), isTrue);
      expect(guard.tryRegister('1234'), isTrue);
      expect(guard.tryRegister('5678'), isTrue);
    });

    test('allows attempts again after OTP resend resets the guard', () {
      final guard = OtpAttemptGuard();
      guard.tryRegister('1234');
      guard.tryRegister('1234');

      guard.reset();

      expect(guard.tryRegister('1234'), isTrue);
    });
  });
}
