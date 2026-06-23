import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';

import 'notification_error_message.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repo;
  GetNotificationsUseCase(this._repo);

  Future<ApiResult<List<NotificationModel>>> call({required int pageNumber, required int pageSize}) async {
    try {
      final data = await _repo.getNotifications(pageNumber, pageSize);
      return ApiResult.success(data.items);
    } catch (e) {
      return ApiResult.failure(notificationErrorMessage(e));
    }
  }
}
