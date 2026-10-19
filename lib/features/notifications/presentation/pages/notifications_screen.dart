import 'package:medicard/core/widgets/app_simple_header.dart';
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

const _brandBlue = Color(0xFF3872B1);
const _ink = Color(0xFF111827);
const _inkFaint = Color(0xFF9CA3AF);

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
          // Silent: a push arriving while the user reads the list must not
          // collapse it into the loading skeleton.
          if (!cubit.state.isLoading) cubit.getNotifications(silent: true);
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
      if (mounted) {
        context.read<NotificationCubit>().getNotifications(silent: true);
      }
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
        body: Column(
          children: [
            // Toolbar only depends on the unread count, so it is insulated
            // from the list rebuilds caused by paging / mark-as-read.
            BlocSelector<NotificationCubit, NotificationState, int>(
              selector: (state) => state.items
                  .where((notification) => !notification.isRead)
                  .length,
              builder: (context, unreadCount) => _NotificationsToolbar(
                unreadCount: unreadCount,
                selectedFilter: _selectedIndex,
                onFilterSelected: _onFilterSelected,
                onMarkAllRead: _markAllAsRead,
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  final visibleItems = _selectedIndex == 0
                      ? state.items
                      : state.items
                            .where((notification) => !notification.isRead)
                            .toList(growable: false);
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    // Keyed on the *status* only — never on the item count.
                    // Keying on length tore down and cross-faded the whole
                    // scroll view on every mark-as-read and every page load,
                    // which is what made switching filters and "mark all
                    // read" visibly lag.
                    child: _buildBody(
                      context,
                      state,
                      visibleItems,
                      key: ValueKey(_bodyStatus(state, visibleItems)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Coarse status of the list — the only thing the body swap should react to.
  String _bodyStatus(
    NotificationState state,
    List<NotificationModel> visibleItems,
  ) {
    if (state.isLoading && state.items.isEmpty) return 'loading';
    if (state.error != null && state.items.isEmpty) return 'error';
    if (visibleItems.isEmpty) return 'empty_$_selectedIndex';
    return 'list_$_selectedIndex';
  }

  void _onFilterSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _markAllAsRead() async {
    final unreadCount = context
        .read<NotificationCubit>()
        .state
        .items
        .where((notification) => !notification.isRead)
        .length;
    if (unreadCount == 0) return;

    final messenger = ScaffoldMessenger.of(context);
    await context.read<NotificationCubit>().markAllAsRead();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          context.tr('notifications.all_marked_read'),
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
      color: _brandBlue,
      // Silent: the indicator already reports progress, so clearing the list
      // to the skeleton underneath it is pure jank.
      onRefresh: () =>
          context.read<NotificationCubit>().getNotifications(silent: true),
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
                    color: _brandBlue,
                  ),
                ),
              ),
            );
          }

          final notification = visibleItems[index];
          // Per-tile repaint isolation: marking one item read repaints only
          // that card instead of the whole viewport.
          return RepaintBoundary(
            child: NotificationCard(
              notification: notification,
              onTap: () => _openNotification(context, notification),
              onMarkAsRead: notification.isRead
                  ? null
                  : () => context.read<NotificationCubit>().markAsRead(
                      notification.id,
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Header + filter row. Split out of the list so the (cheap) toolbar is not
/// rebuilt by every list-state change.
class _NotificationsToolbar extends StatelessWidget {
  final int unreadCount;
  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;
  final VoidCallback onMarkAllRead;

  const _NotificationsToolbar({
    required this.unreadCount,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return AppSimpleHeader(
      title: context.tr('notifications.title'),
      subtitle: unreadCount == 0
          ? context.tr('notifications.all_caught_up')
          : context.tr('notifications.unread_count', args: ['$unreadCount']),
      subtitleColor: unreadCount == 0 ? _inkFaint : _brandBlue,
      actions: [
        _MarkAllReadAction(enabled: unreadCount > 0, onPressed: onMarkAllRead),
      ],
      bottomChild: _NotificationFilters(
        selectedIndex: selectedFilter,
        unreadCount: unreadCount,
        onSelected: onFilterSelected,
      ),
    );
  }
}

/// Labelled "mark all read" pill — an icon-only round button gave no clue what
/// it did and was a 40pt target with no affordance for its state.
class _MarkAllReadAction extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _MarkAllReadAction({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: context.tr('notifications.mark_all_read'),
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFEAF1F9) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: enabled
                  ? _brandBlue.withValues(alpha: 0.25)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 15.sp,
                color: enabled ? _brandBlue : _inkFaint,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  context.tr('notifications.mark_all_read_short'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: enabled ? _brandBlue : _inkFaint,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// All / Unread filter chips. Replaces the segmented control, which reserved
/// a full-width bar for two short labels and clipped them at large text
/// scales.
class _NotificationFilters extends StatelessWidget {
  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onSelected;

  const _NotificationFilters({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(8.w, 4.h, 8.w, 6.h),
        children: [
          _FilterChip(
            label: context.tr('notifications.all'),
            isSelected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: context.tr('notifications.unread'),
            isSelected: selectedIndex == 1,
            count: unreadCount,
            onTap: () => onSelected(1),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int? count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : _ink;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: isSelected ? _brandBlue : Colors.white,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected ? _brandBlue : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  height: 1.2,
                ),
              ),
              if (count != null && count! > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : const Color(0xFFEAF1F9),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    count! > 99 ? '99+' : '$count',
                    style: AppTextStyles.of(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
      height: 132.h,
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
          const _SkeletonBlock(width: 52, height: 52, radius: 14),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonBlock(width: 150, height: 13, radius: 5),
                SizedBox(height: 5.h),
                const _SkeletonBlock(height: 10, radius: 5),
                SizedBox(height: 8.h),
                const _SkeletonBlock(width: 190, height: 10, radius: 5),
                const Spacer(),
                Row(
                  children: [
                    const _SkeletonBlock(width: 8, height: 8, radius: 4),
                    SizedBox(width: 8.w),
                    const _SkeletonBlock(width: 34, height: 9, radius: 5),
                    const Spacer(),
                    const _SkeletonBlock(width: 84, height: 22, radius: 11),
                  ],
                ),
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
