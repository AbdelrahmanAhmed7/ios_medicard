import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/notifivation_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D5FA6),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _NotificationsTabsHeader(
            selectedIndex: _selectedIndex,
            onTabSelected: (index) => setState(() => _selectedIndex = index),
            onMarkAllRead: () =>
                context.read<NotificationCubit>().markAllAsRead(),
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
                    title: 'Could not load notifications',
                    message: state.error!,
                    actionLabel: 'Retry',
                    onAction: context.read<NotificationCubit>().getNotifications,
                  );
                }

                if (visibleItems.isEmpty) {
                  return _NotificationsMessage(
                    icon: _selectedIndex == 0
                        ? Icons.notifications_none
                        : Icons.mark_email_read_outlined,
                    title: _selectedIndex == 0
                        ? 'No notifications yet'
                        : 'No unread notifications',
                    message: _selectedIndex == 0
                        ? 'New updates will show up here.'
                        : 'Everything is caught up.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: context.read<NotificationCubit>().getNotifications,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
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
                            context
                                .read<NotificationCubit>()
                                .markAsRead(notification.id);
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
    return Container(
      color: const Color(0xFF2D5FA6),
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _NotificationTab(
                title: 'All',
                isSelected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              SizedBox(width: 24.w),
              _NotificationTab(
                title: 'Unread',
                isSelected: selectedIndex == 1,
                onTap: () => onTabSelected(1),
              ),
            ],
          ),
          GestureDetector(
            onTap: onMarkAllRead,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC6D8EC),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.done_all,
                    color: const Color(0xFF1E293B),
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
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
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 3.h,
            width: 40.w,
            color: isSelected ? Colors.white : Colors.transparent,
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
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
