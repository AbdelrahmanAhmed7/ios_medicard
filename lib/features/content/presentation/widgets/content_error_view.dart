import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';

import '../../../../core/theming/app_text_styles.dart';


class ContentErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const ContentErrorView({
    super.key,
    required this.onRetry,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.sp,
              color: const Color(0xFF3872B1),
            ),
            SizedBox(height: 20.h),
            Text(
              'content.load_failed_title'.tr(),
              style: AppTextStyles.of(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: AuthPrimaryButton(
                onPressed: onRetry,
                label: 'common.try_again'.tr(),
                isLoading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
