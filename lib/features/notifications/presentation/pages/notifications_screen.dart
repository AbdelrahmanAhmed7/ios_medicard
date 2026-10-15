import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../data/model/notification_model.dart';
import '../../push_notification_service.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _messageSubscription;
  int _selectedIndex = 0;
  String? _activeLanguage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageSubscription = PushNotificationService.instance.onMessageReceived
        .listen((_) {
          if (!mounted) return;
          final cubit = context.read<NotificationCubit>();
          if (!cubit.state.isLoading) cubit.getNotifications();
        });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = context.locale.languageCode;
    final previousLanguage = _activeLanguage;
    _activeLanguage = language;
    if (previousLanguage == null || previousLanguage == language) return;

    // The backend localizes notification titles and bodies through the
    // Accept-Language header, so changing locale requires a fresh request.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().getNotifications();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  Future<void> _openNotification(
    BuildContext context,
    NotificationModel notification,
  ) async {
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    final data = notification.data;
    final rawProvider = data == null
        ? null
        : (data['ProviderId'] ?? data['providerId']);
    final providerId = rawProvider is int
        ? rawProvider
        : int.tryParse('${rawProvider ?? ''}');
    if (providerId != null && context.mounted) {
      context.push('/provider-page', extra: providerId);
      return;
    }

    final rawPackage = data == null
        ? null
        : (data['PackageId'] ?? data['packageId']);
    final packageId = rawPackage is int
        ? rawPackage
        : int.tryParse('${rawPackage ?? ''}');
    if (packageId == null || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      ),
    );
    final opened = await PushNotificationService.openNotificationPackage(
      packageId,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('errors.something_went_wrong'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (previous, current) =>
          previous.markReadError != current.markReadError &&
          current.markReadError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.markReadError!)));
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final unreadCount = state.items
                .where((notification) => !notification.isRead)
                .length;
            final visibleItems = _selectedIndex == 0
                ? state.items
                : state.items
                      .where((notification) => !notification.isRead)
                      .toList(growable: false);

            return Column(
              children: [
                // Local header matching the other list screens (back +
                // title + action) instead of the shared wide header.
                _NotificationsHeader(
                  unreadCount: unreadCount,
                  onMarkAllRead: () =>
                      context.read<NotificationCubit>().markAllAsRead(),
                ),
                _NotificationSegments(
                  selectedIndex: _selectedIndex,
                  unreadCount: unreadCount,
                  onTabSelected: (index) {
                    if (_selectedIndex == index) return;
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _buildBody(
                      context,
                      state,
                      visibleItems,
                      key: ValueKey(
                        '${_selectedIndex}_${state.isLoading}_${state.error != null}_${visibleItems.length}',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    List<NotificationModel> visibleItems, {
    required Key key,
  }) {
    if (state.isLoading && state.items.isEmpty) {
      return _NotificationsLoading(key: key);
    }

    if (state.error != null && state.items.isEmpty) {
      return _NotificationsMessage(
        key: key,
        icon: Icons.cloud_off_rounded,
        title: context.tr('notifications.load_failed_title'),
        message: state.error!,
        actionLabel: context.tr('common.retry'),
        onAction: context.read<NotificationCubit>().getNotifications,
      );
    }

    if (visibleItems.isEmpty) {
      return _NotificationsMessage(
        key: key,
        icon: _selectedIndex == 0
            ? Icons.notifications_none_rounded
            : Icons.task_alt_rounded,
        title: _selectedIndex == 0
            ? context.tr('notifications.empty_title')
            : context.tr('notifications.empty_unread_title'),
        message: _selectedIndex == 0
            ? context.tr('notifications.empty_message')
            : context.tr('notifications.empty_unread_message'),
      );
    }

    return RefreshIndicator(
      key: key,
      color: const Color(0xFF3872B1),
      onRefresh: context.read<NotificationCubit>().getNotifications,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(0, 6.h, 0, 24.h),
        itemCount: visibleItems.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visibleItems.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: const Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Color(0xFF3872B1),
                  ),
                ),
              ),
            );
          }

          final notification = visibleItems[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _openNotification(context, notification),
            onMarkAsRead: notification.isRead
                ? null
                : () => context.read<NotificationCubit>().markAsRead(
                    notification.id,
                  ),
          );
        },
      ),
    );
  }
}

/// Header matching the other list screens: back + bold title + a round
/// "mark all read" action.
class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const _NotificationsHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF111827),
                size: 22.sp,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Text(
                context.tr('notifications.title'),
                style: AppTextStyles.of(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tooltip(
              message: context.tr('notifications.mark_all_read'),
              child: GestureDetector(
                onTap: hasUnread ? onMarkAllRead : null,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: hasUnread
                        ? const Color(0xFFEAF1F9)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 20.sp,
                    color: hasUnread
                        ? const Color(0xFF3872B1)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single segmented control (All | Unread) replacing the old floating
/// chips with an overlapping badge.
class _NotificationSegments extends StatelessWidget {
  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onTabSelected;

  const _NotificationSegments({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 2.h),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentTab(
                label: context.tr('notifications.all'),
                isSelected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _SegmentTab(
                label: context.tr('notifications.unread'),
                isSelected: selectedIndex == 1,
                count: unreadCount,
                onTap: () => onTabSelected(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF3872B1);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(
                      0xFF0F172A,
                    ).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.of(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? brandBlue : const Color(0xFF64748B),
                ),
              ),
            ),
            if (count != null && count! > 0) ...[
              SizedBox(width: 6.w),
              Container(
                constraints: BoxConstraints(minWidth: 20.r, minHeight: 20.r),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: isSelected ? brandBlue : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    count! > 99 ? '99+' : '$count',
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 6.h),
      itemCount: 5,
      itemBuilder: (_, _) => const _NotificationSkeleton(),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE9ECF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBlock(width: 50, height: 50, radius: 14),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonBlock(width: 150, height: 13, radius: 5),
                SizedBox(height: 12.h),
                const _SkeletonBlock(height: 10, radius: 5),
                SizedBox(height: 8.h),
                const _SkeletonBlock(width: 190, height: 10, radius: 5),
                const Spacer(),
                const _SkeletonBlock(width: 58, height: 9, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBlock({
    this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _NotificationsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _NotificationsMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82.r,
              height: 82.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38.sp, color: const Color(0xFF3872B1)),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontWeight: FontWeight.w400,
                fontSize: 13.5.sp,
                color: const Color(0xFF6B7280),
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 20.h),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3872B1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 11.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
