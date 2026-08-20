import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.w),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notification.isRead)
              Padding(
                padding: EdgeInsets.only(top: 18.h, right: 8.w),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: ClipOval(child: _NotificationImage(notification.imageUrl)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF3B82F6),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                _formatRelativeTime(notification.createdAt),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'notifications.now'.tr();
    if (difference.inMinutes < 60) {
      return 'notifications.minutes_ago'.tr(args: ['${difference.inMinutes}']);
    }
    if (difference.inHours < 24) {
      return 'notifications.hours_ago'.tr(args: ['${difference.inHours}']);
    }
    if (difference.inDays < 7) {
      return 'notifications.days_ago'.tr(args: ['${difference.inDays}']);
    }
    if (difference.inDays < 30) {
      return 'notifications.weeks_ago'.tr(args: ['${difference.inDays ~/ 7}']);
    }
    if (difference.inDays < 365) {
      return 'notifications.months_ago'.tr(
        args: ['${difference.inDays ~/ 30}'],
      );
    }

    return 'notifications.years_ago'.tr(args: ['${difference.inDays ~/ 365}']);
  }
}

class _NotificationImage extends StatelessWidget {
  final String imageUrl;

  const _NotificationImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const _NotificationFallbackIcon();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => const _NotificationFallbackIcon(),
    );
  }
}

class _NotificationFallbackIcon extends StatelessWidget {
  const _NotificationFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.notifications_outlined,
        color: const Color(0xFF94A3B8),
        size: 24.sp,
      ),
    );
  }
}
