import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../data/model/notification_model.dart';

/// Compact notification row matching the flat list treatment used by family
/// members. Unread state is communicated by a light tint, stronger title and
/// blue dot; marking as read stays an explicit trailing icon action.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  static const _brandBlue = Color(0xFF3872B1);
  static const _ink = Color(0xFF0B1435);
  static const _subtleText = Color(0xFF7481A1);

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return Semantics(
      button: onTap != null,
      child: Material(
        color: isUnread ? const Color(0xFFF4F8FD) : Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 78.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE9ECF2))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NotificationThumbnail(notification: notification),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isUnread) ...[
                            Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: _brandBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 7.w),
                          ],
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.of(
                                fontSize: 13.5.sp,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _ink,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.of(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: _subtleText,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11.5.sp,
                            color: const Color(0xFF98A2B3),
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              _formatRelativeTime(
                                context,
                                notification.createdAt,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.of(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF98A2B3),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUnread && onMarkAsRead != null) ...[
                  SizedBox(width: 6.w),
                  _MarkReadIconAction(
                    notificationId: notification.id,
                    onPressed: onMarkAsRead!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(BuildContext context, DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.isNegative || difference.inMinutes < 1) {
      return context.tr('notifications.now');
    }
    if (difference.inMinutes < 60) {
      return context.tr(
        'notifications.minutes_ago',
        args: ['${difference.inMinutes}'],
      );
    }
    if (difference.inHours < 24) {
      return context.tr(
        'notifications.hours_ago',
        args: ['${difference.inHours}'],
      );
    }
    if (difference.inDays < 7) {
      return context.tr(
        'notifications.days_ago',
        args: ['${difference.inDays}'],
      );
    }
    if (difference.inDays < 30) {
      return context.tr(
        'notifications.weeks_ago',
        args: ['${difference.inDays ~/ 7}'],
      );
    }
    if (difference.inDays < 365) {
      return context.tr(
        'notifications.months_ago',
        args: ['${difference.inDays ~/ 30}'],
      );
    }
    return context.tr(
      'notifications.years_ago',
      args: ['${difference.inDays ~/ 365}'],
    );
  }
}

class _MarkReadIconAction extends StatelessWidget {
  final int notificationId;
  final VoidCallback onPressed;

  const _MarkReadIconAction({
    required this.notificationId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: ValueKey('mark-notification-read-$notificationId'),
      tooltip: context.tr('notifications.mark_read'),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 40.r, minHeight: 48.r),
      icon: Container(
        width: 32.r,
        height: 32.r,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF1F9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.done_rounded,
          color: NotificationCard._brandBlue,
          size: 19.sp,
        ),
      ),
    );
  }
}

class _NotificationThumbnail extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationThumbnail({required this.notification});

  @override
  Widget build(BuildContext context) {
    final size = 42.r;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2FB),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _NotificationImage(
        imageUrl: notification.imageUrl,
        fallbackIcon: _fallbackIcon(notification.data),
      ),
    );
  }

  IconData _fallbackIcon(Map<String, dynamic>? data) {
    if (data == null) return Icons.notifications_none_rounded;
    if (data.containsKey('PackageId') || data.containsKey('packageId')) {
      return Icons.local_offer_outlined;
    }
    if (data.containsKey('ProviderId') || data.containsKey('providerId')) {
      return Icons.local_hospital_outlined;
    }
    return Icons.notifications_none_rounded;
  }
}

class _NotificationImage extends StatelessWidget {
  final String imageUrl;
  final IconData fallbackIcon;

  const _NotificationImage({
    required this.imageUrl,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _NotificationFallbackIcon(icon: fallbackIcon);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      placeholder: (_, _) => _NotificationFallbackIcon(icon: fallbackIcon),
      errorWidget: (_, _, _) => _NotificationFallbackIcon(icon: fallbackIcon),
    );
  }
}

class _NotificationFallbackIcon extends StatelessWidget {
  final IconData icon;

  const _NotificationFallbackIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, color: NotificationCard._brandBlue, size: 20.sp),
    );
  }
}
