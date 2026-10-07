import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/get_notifications_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/presentation/cubit/notification_cubit.dart';

class _FakeNotificationRepository implements NotificationRepository {
  bool markAsReadShouldFail = false;
  bool markAllAsReadShouldFail = false;

  NotificationModel _item(int id, {bool isRead = false}) => NotificationModel(
    id: id,
    title: 'Title $id',
    body: 'Body $id',
    imageUrl: '',
    isRead: isRead,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<NotificationData> getNotifications(
    int pageNumber,
    int pageSize,
  ) async {
    return NotificationData(
      items: [_item(1), _item(2, isRead: true)],
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalCount: 2,
      totalPages: 1,
    );
  }

  @override
  Future<void> markAsRead(int id) async {
    if (markAsReadShouldFail) throw Exception('offline');
  }

  @override
  Future<void> markAllAsRead() async {
    if (markAllAsReadShouldFail) throw Exception('offline');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('NotificationCubit mark-as-read failures', () {
    late _FakeNotificationRepository repo;
    late NotificationCubit cubit;

    setUp(() {
      repo = _FakeNotificationRepository();
      cubit = NotificationCubit(
        GetNotificationsUseCase(repo),
        MarkNotificationReadUseCase(repo),
        MarkAllNotificationsReadUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    Future<void> seedItems() async {
      // getNotifications seeds [unread #1, read #2] via the fake repo.
      await cubit.getNotifications();
      expect(cubit.state.items.map((e) => e.id), [1, 2]);
    }

    test('markAsRead failure rolls back to unread and reports the error',
        () async {
      await seedItems();
      repo.markAsReadShouldFail = true;

      await cubit.markAsRead(1);

      // UI claimed "read" optimistically, then rolled back to truth.
      expect(cubit.state.items.firstWhere((e) => e.id == 1).isRead, isFalse);
      expect(cubit.state.markReadError, isNotNull);
      // The already-read item is untouched.
      expect(cubit.state.items.firstWhere((e) => e.id == 2).isRead, isTrue);
    });

    test('markAsRead success keeps the optimistic update, no error', () async {
      await seedItems();

      await cubit.markAsRead(1);

      expect(cubit.state.items.firstWhere((e) => e.id == 1).isRead, isTrue);
      expect(cubit.state.markReadError, isNull);
    });

    test('markAllAsRead failure restores each previous read state', () async {
      await seedItems();
      repo.markAllAsReadShouldFail = true;

      await cubit.markAllAsRead();

      final byId = {for (final e in cubit.state.items) e.id: e.isRead};
      expect(byId, {1: false, 2: true});
      expect(cubit.state.markReadError, isNotNull);
    });

    test('a fresh attempt clears a stale markReadError', () async {
      await seedItems();
      repo.markAsReadShouldFail = true;
      await cubit.markAsRead(1);
      expect(cubit.state.markReadError, isNotNull);

      repo.markAsReadShouldFail = false;
      await cubit.markAsRead(1);
      expect(cubit.state.markReadError, isNull);
    });
  });
}
