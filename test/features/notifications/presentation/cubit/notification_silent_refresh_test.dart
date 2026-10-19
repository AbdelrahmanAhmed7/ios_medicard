import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/get_notifications_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/presentation/cubit/notification_cubit.dart';

class _FakeNotificationRepository implements NotificationRepository {
  /// Completer used to hold the re-sync request open mid-test.
  Completer<void>? gate;

  /// Mirrors a backend that has actually persisted a "mark all read".
  bool allRead = false;

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
    if (gate != null) await gate!.future;
    return NotificationData(
      items: [_item(1, isRead: allRead), _item(2, isRead: true)],
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalCount: 2,
      totalPages: 1,
    );
  }

  @override
  Future<void> markAsRead(int id) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('NotificationCubit silent re-sync', () {
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
      await cubit.getNotifications();
      expect(cubit.state.items.map((e) => e.id), [1, 2]);
      expect(cubit.state.isLoading, isFalse);
    }

    test('a cold load shows the loading skeleton', () async {
      final seen = <({bool isLoading, int itemCount})>[];
      final sub = cubit.stream.listen(
        (s) => seen.add((isLoading: s.isLoading, itemCount: s.items.length)),
      );

      unawaited(cubit.getNotifications());
      await Future<void>.delayed(Duration.zero);

      expect(seen.first.isLoading, isTrue);
      expect(seen.first.itemCount, 0);
      await sub.cancel();
    });

    test('silent re-sync keeps items on screen and never loads', () async {
      await seedItems();
      final seen = <({bool isLoading, int itemCount})>[];
      final sub = cubit.stream.listen(
        (s) => seen.add((isLoading: s.isLoading, itemCount: s.items.length)),
      );

      await cubit.getNotifications(silent: true);
      await Future<void>.delayed(Duration.zero);

      expect(seen, isNotEmpty);
      expect(
        seen.every((s) => !s.isLoading),
        isTrue,
        reason: 'a background re-sync must never flip back to loading',
      );
      expect(
        seen.every((s) => s.itemCount == 2),
        isTrue,
        reason: 'items must stay mounted for the whole re-sync',
      );
      sub.cancel();
    });

    test('markAllAsRead does not blank the list during its re-sync', () async {
      await seedItems();
      repo.allRead = true;
      final gate = Completer<void>();
      repo.gate = gate;

      final seen = <({bool isLoading, int itemCount})>[];
      final sub = cubit.stream.listen(
        (s) => seen.add((isLoading: s.isLoading, itemCount: s.items.length)),
      );

      final pending = cubit.markAllAsRead();
      await Future<void>.delayed(Duration.zero);

      expect(
        seen.any((s) => s.isLoading),
        isFalse,
        reason: 'mark-all must not collapse the list into the skeleton',
      );
      expect(seen, isNotEmpty);
      expect(seen.every((s) => s.itemCount == 2), isTrue);

      gate.complete();
      await pending;
      repo.gate = null;
      await sub.cancel();

      expect(
        cubit.state.items.every((e) => e.isRead),
        isTrue,
        reason: 'the post-success re-sync proves the read-all stuck',
      );
    });
  });
}