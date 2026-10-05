import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';
import 'package:medicard/features/notifications/data/domain/notification_service.dart';

class _FakeNotificationService implements NotificationService {
  int registerCalls = 0;
  String? lastAuthHeader;
  String? lastFcmToken;
  int? lastPlatform;

  @override
  Future<void> registerDeviceToken(
    String token, {
    required String fcmToken,
    required int platform,
  }) async {
    registerCalls++;
    lastAuthHeader = token;
    lastFcmToken = fcmToken;
    lastPlatform = platform;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  String? storedUserToken;

  setUp(() {
    storedUserToken = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'read') return storedUserToken;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NotificationRepository.registerDeviceToken', () {
    test('returns false and never calls the API when logged out', () async {
      final service = _FakeNotificationService();
      final repo = NotificationRepository(service);

      final registered = await repo.registerDeviceToken(
        fcmToken: 'fcm-abc',
        platform: 1,
      );

      expect(registered, isFalse);
      expect(service.registerCalls, 0);
    });

    test('posts fcmToken + platform with bearer header when logged in',
        () async {
      storedUserToken = 'user-jwt';
      final service = _FakeNotificationService();
      final repo = NotificationRepository(service);

      final registered = await repo.registerDeviceToken(
        fcmToken: 'fcm-abc',
        platform: 1,
      );

      expect(registered, isTrue);
      expect(service.registerCalls, 1);
      expect(service.lastAuthHeader, 'Bearer user-jwt');
      expect(service.lastFcmToken, 'fcm-abc');
      expect(service.lastPlatform, 1);
    });
  });
}
