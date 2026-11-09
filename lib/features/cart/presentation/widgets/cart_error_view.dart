import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CartErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CartErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52.sp,
              color: AppColors.exactFFD1D5DB,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(fontSize: 14.sp, color: AppColors.exactFF6B7280),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlueClr,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'common.retry'.tr(),
                style: AppTextStyles.of(
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteClr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

