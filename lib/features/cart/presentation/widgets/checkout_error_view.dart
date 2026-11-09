import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CheckoutErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CheckoutErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.inkFaintClr,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(fontSize: 14.sp, color: AppColors.inkMutedClr),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlueClr,
                foregroundColor: AppColors.whiteClr,
              ),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

