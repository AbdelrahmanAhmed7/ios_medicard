import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';

import 'notification_error_message.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repo;
  MarkAllNotificationsReadUseCase(this._repo);

  Future<ApiResult<void>> call() async {
    try {
      await _repo.markAllAsRead();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(notificationErrorMessage(e));
    }
  }
}
