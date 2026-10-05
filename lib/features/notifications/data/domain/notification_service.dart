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
    final response = await _client.registerDeviceToken(token, {
      'fcmToken': fcmToken,
      'platform': platform,
    });

    if (!response.succeeded) {
      throw Exception(response.message);
    }
  }
}
