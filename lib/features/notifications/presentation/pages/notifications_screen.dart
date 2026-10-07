import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/widgets/app_blue_header.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';

import '../../../../core/theming/app_text_styles.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listenWhen: (previous, current) =>
          previous.markReadError != current.markReadError &&
          current.markReadError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.markReadError!)),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          AppBlueHeader(
            title: 'notifications.title'.tr(),
            bottomChild: _NotificationsTabsHeader(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
              onMarkAllRead: () =>
                  context.read<NotificationCubit>().markAllAsRead(),
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final visibleItems = _selectedIndex == 0
                    ? state.items
                    : state.items.where((item) => !item.isRead).toList();

                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null && state.items.isEmpty) {
                  return _NotificationsMessage(
                    icon: Icons.error_outline,
                    title: 'notifications.load_failed_title'.tr(),
                    message: state.error!,
                    actionLabel: 'common.retry'.tr(),
                    onAction: context
                        .read<NotificationCubit>()
                        .getNotifications,
                  );
                }

                if (visibleItems.isEmpty) {
                  return _NotificationsMessage(
                    icon: _selectedIndex == 0
                        ? Icons.notifications_none
                        : Icons.mark_email_read_outlined,
                    title: _selectedIndex == 0
                        ? 'notifications.empty_title'.tr()
                        : 'notifications.empty_unread_title'.tr(),
                    message: _selectedIndex == 0
                        ? 'notifications.empty_message'.tr()
                        : 'notifications.empty_unread_message'.tr(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: context.read<NotificationCubit>().getNotifications,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    itemCount:
                        visibleItems.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= visibleItems.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final notification = visibleItems[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationCubit>().markAsRead(
                              notification.id,
                            );
                          }
                        },
                      );
                    },
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
}

class _NotificationsTabsHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onMarkAllRead;

  const _NotificationsTabsHeader({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 4.w, right: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _NotificationTab(
                title: 'notifications.all'.tr(),
                isSelected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              SizedBox(width: 32.w),
              _NotificationTab(
                title: 'notifications.unread'.tr(),
                isSelected: selectedIndex == 1,
                onTap: () => onTabSelected(1),
              ),
            ],
          ),
          GestureDetector(
            onTap: onMarkAllRead,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done_all,
                    color: const Color(0xFF1E293B),
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'notifications.mark_all_read'.tr(),
                    style: AppTextStyles.of(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotificationTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.of(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 16.sp,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 3.h,
            width: 42.w,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
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
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42.sp, color: const Color(0xFF94A3B8)),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 16.h),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
