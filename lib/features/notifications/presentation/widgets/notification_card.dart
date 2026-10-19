import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../data/model/notification_model.dart';

/// Notification list item.
///
/// Flat bordered card matching the rest of the app (addresses, family
/// members, invoices): 8.w side margin, 14.r radius, no heavy shadows.
/// Unread items get a tinted background, a brand-colored border and a dot.
///
/// The timestamp sits on the title row so read items (which carry no action)
/// stay two lines tall instead of reserving a third row for an empty footer.
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
  static const _ink = Color(0xFF111827);
  static const _subtleText = Color(0xFF6B7280);
  static const _faintText = Color(0xFF98A2B3);
  static const _cardBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final showAction = isUnread && onMarkAsRead != null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      child: Semantics(
        button: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isUnread ? const Color(0xFFF2F7FD) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isUnread
                    ? _brandBlue.withValues(alpha: 0.4)
                    : _cardBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationThumbnail(notification: notification),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.of(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 14.sp,
                                color: _ink,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(top: 3.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 12.sp,
                                    color: _faintText,
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
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp,
                                        color: _faintText,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        notification.body,
                        style: AppTextStyles.of(
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp,
                          color: _subtleText,
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isUnread) ...[
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                color: _brandBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                context.tr('notifications.unread_label'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.of(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _brandBlue,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (showAction) ...[
                              SizedBox(width: 8.w),
                              Flexible(
                                child: _MarkReadAction(
                                  onPressed: onMarkAsRead!,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
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

/// Pill action on the unread footer.
class _MarkReadAction extends StatelessWidget {
  final VoidCallback onPressed;

  const _MarkReadAction({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr('notifications.mark_read'),
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: NotificationCard._brandBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 14.sp,
                color: NotificationCard._brandBlue,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  context.tr('notifications.mark_read'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: NotificationCard._brandBlue,
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

class _NotificationThumbnail extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationThumbnail({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        borderRadius: BorderRadius.circular(14.r),
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
      fit: BoxFit.cover,
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
      child: Icon(
        icon,
        color: NotificationCard._brandBlue,
        size: 22.sp,
      ),
    );
  }
}
