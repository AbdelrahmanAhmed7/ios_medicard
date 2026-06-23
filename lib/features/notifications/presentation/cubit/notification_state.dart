import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<NotificationModel> items,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int currentPage,
    String? error,
  }) = _NotificationState;
}
