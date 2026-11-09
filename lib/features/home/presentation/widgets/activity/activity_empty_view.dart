import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ActivityEmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const ActivityEmptyView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppColors.exactFFEFF6FF,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.exactFFD8E8FA),
              ),
              child: Icon(icon, size: 34.r, color: kAuthBlue),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.inkClr,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                height: 1.45,
                color: AppColors.exactFF6B7280,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

