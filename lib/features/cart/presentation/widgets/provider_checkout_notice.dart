import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Explains that provider groups are checked out independently.
class ProviderCheckoutNotice extends StatelessWidget {
  final String message;

  const ProviderCheckoutNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.exactFFEFF6FF,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.exactFFBFDBFE),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(
              color: AppColors.exactFFDBEAFE,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.exactFF2563EB,
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cart.separate_checkout_title'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.exactFF1E3A8A,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  message,
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    color: AppColors.inkSoftClr,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

