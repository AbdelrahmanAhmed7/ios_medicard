import 'package:flutter/foundation.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/data/notification_client.dart';

class NotificationService {
  final NotificationClient _client;

  NotificationService(this._client);

  Future<NotificationData> getNotifications(
    String token,
    int pageNumber,
    int pageSize,
  ) async {
    final response = await _client.getNotifications(token, pageNumber, pageSize);

    if (response.succeeded && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> markAsRead(String token, int id) async {
    final response = await _client.markAsRead(token, id);

    if (!response.succeeded) {
      throw Exception(response.message);
    }
  }

  Future<void> markAllAsRead(String token) async {
    final response = await _client.markAllAsRead(token);

    if (!response.succeeded) {
      throw Exception(response.message);
    }
  }

  Future<void> registerDeviceToken(
    String token, {
    required String fcmToken,
    required int platform,
  }) async {
    // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
    debugPrint(
      '[FCM] POST Notification/register-device-token '
      '(platform=$platform, token=${_short(fcmToken)})',
    );
    final response = await _client.registerDeviceToken(token, {
      'fcmToken': fcmToken,
      'platform': platform,
    });

    // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
    debugPrint(
      '[FCM] response: http=${response.httpStatusCode} '
      'succeeded=${response.succeeded} message=${response.message}',
    );

    if (!response.succeeded) {
      throw Exception(response.message);
    }
  }
}

// TEMP-FCM-DEBUG: truncated token only — never log full tokens.
String _short(String token) =>
    token.length > 12 ? '${token.substring(0, 12)}…' : token;
