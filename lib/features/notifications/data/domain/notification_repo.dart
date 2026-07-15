import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/helpers/shared_pref_helper.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';

import 'notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository(this._service);

  Future<String> get _bearerToken async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    return 'Bearer $token';
  }

  Future<NotificationData> getNotifications(
    int pageNumber,
    int pageSize,
  ) async {
    return await _service.getNotifications(
      await _bearerToken,
      pageNumber,
      pageSize,
    );
  }

  Future<void> markAsRead(int id) async {
    await _service.markAsRead(await _bearerToken, id);
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead(await _bearerToken);
  }
}
