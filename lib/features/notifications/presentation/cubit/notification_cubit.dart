import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/get_notifications_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart';
import 'package:medicard/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';

import '../../../../core/constants/api_result.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  StreamSubscription<dynamic>? _messageSubscription;
  bool _hasStarted = false;

  static const int _pageSize = 10;

  NotificationCubit(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase, {
    Stream<dynamic>? messageStream,
  }) : super(const NotificationState()) {
    _messageSubscription = messageStream?.listen((_) {
      if (isClosed || !_hasStarted || state.isLoading) return;
      unawaited(getNotifications(silent: true));
    });
  }

  Future<void> init() async {
    if (isClosed || state.isLoading) return;
    await getNotifications(silent: state.items.isNotEmpty);
  }

  /// Loads page 1.
  ///
  /// When [silent] is true the already-loaded items stay on screen (the state
  /// never flips to the loading skeleton) so background re-syncs — pull to
  /// refresh, a new push message, the post "mark all read" re-sync — never
  /// blank the list out from under the user.
  Future<void> getNotifications({bool silent = false}) async {
    if (isClosed) return;
    _hasStarted = true;
    emit(
      state.copyWith(
        isLoading: !silent,
        items: silent ? state.items : [],
        hasMore: true,
        currentPage: 1,
        error: null,
      ),
    );
    await _fetch(page: 1, silent: silent);
  }

  Future<void> loadMore() async {
    if (isClosed) return;
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: state.currentPage + 1);
  }

  Future<void> _fetch({required int page, bool silent = false}) async {
    final result = await _getNotificationsUseCase.call(
      pageNumber: page,
      pageSize: _pageSize,
    );

    if (isClosed) return;

    result.when(
      success: (newItems) {
        if (isClosed) return;
        final merged = page == 1 ? newItems : [...state.items, ...newItems];
        emit(
          state.copyWith(
            items: merged,
            isLoading: false,
            isLoadingMore: false,
            hasMore: newItems.length >= _pageSize,
            currentPage: page,
            error: null,
          ),
        );
      },
      failure: (message) {
        if (isClosed) return;
        // A silent re-sync keeps the stale-but-usable list on screen; only a
        // cold load surfaces the error page.
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            error: silent ? null : message,
          ),
        );
      },
    );
  }

  Future<void> markAsRead(int id) async {
    if (isClosed) return;

    // Snapshot BEFORE the optimistic update so a failure rolls back to truth.
    final wasRead = state.items
        .where((notif) => notif.id == id)
        .map((notif) => notif.isRead)
        .firstOrNull;

    final updatedItems = state.items.map((notif) {
      if (notif.id == id) {
        return NotificationModel(
          id: notif.id,
          title: notif.title,
          body: notif.body,
          imageUrl: notif.imageUrl,
          isRead: true,
          createdAt: notif.createdAt,
          data: notif.data,
        );
      }
      return notif;
    }).toList();

    emit(state.copyWith(items: updatedItems, markReadError: null));

    final result = await _markNotificationReadUseCase.call(id);

    if (isClosed) return;

    result.when(
      success: (_) {},
      failure: (message) {
        if (isClosed) return;
        // Roll back the optimistic update so the badge stays truthful.
        final rolledBack = state.items.map((notif) {
          if (notif.id == id) {
            return NotificationModel(
              id: notif.id,
              title: notif.title,
              body: notif.body,
              imageUrl: notif.imageUrl,
              isRead: wasRead ?? false,
              createdAt: notif.createdAt,
              data: notif.data,
            );
          }
          return notif;
        }).toList();
        emit(state.copyWith(items: rolledBack, markReadError: message));
      },
    );
  }

  Future<void> markAllAsRead() async {
    if (isClosed) return;

    // Snapshot BEFORE the optimistic update so a failure rolls back to truth.
    final previousById = {for (final n in state.items) n.id: n.isRead};

    final updatedItems = state.items.map((notif) {
      return NotificationModel(
        id: notif.id,
        title: notif.title,
        body: notif.body,
        imageUrl: notif.imageUrl,
        isRead: true,
        createdAt: notif.createdAt,
        data: notif.data,
      );
    }).toList();

    emit(state.copyWith(items: updatedItems, markReadError: null));

    final result = await _markAllNotificationsReadUseCase.call();

    if (isClosed) return;

    String? failureMessage;
    result.when(
      success: (_) {},
      failure: (message) {
        failureMessage = message;
      },
    );

    if (isClosed) return;

    if (failureMessage == null) {
      // Success: re-sync with the server (source of truth). The optimistic
      // update above only covers already-loaded pages; refetching page 1
      // proves the backend actually persisted the read-all (an API can
      // return 200 without persisting for this user/token) and pulls any
      // not-yet-loaded pages in their new read state. The sync is silent so
      // the list never collapses into the loading skeleton mid-interaction.
      await getNotifications(silent: true);
      return;
    }

    // Failure: roll back to restore each item's read state from before
    // the attempt.
    final rolledBack = state.items.map((notif) {
      return NotificationModel(
        id: notif.id,
        title: notif.title,
        body: notif.body,
        imageUrl: notif.imageUrl,
        isRead: previousById[notif.id] ?? notif.isRead,
        createdAt: notif.createdAt,
        data: notif.data,
      );
    }).toList();
    emit(state.copyWith(items: rolledBack, markReadError: failureMessage));
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    return super.close();
  }
}
