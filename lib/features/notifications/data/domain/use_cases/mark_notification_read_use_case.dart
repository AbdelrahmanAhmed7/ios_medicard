import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';

import 'notification_error_message.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repo;
  MarkNotificationReadUseCase(this._repo);

  Future<ApiResult<void>> call(int id) async {
    try {
      await _repo.markAsRead(id);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(notificationErrorMessage(e));
    }
  }
}
