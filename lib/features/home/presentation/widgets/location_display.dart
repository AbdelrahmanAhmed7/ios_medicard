import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class LocationDisplay extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const LocationDisplay({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Rebuild when the locale changes so the label follows the language.
    final _ = context.locale;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.brandBlueClr,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'home.location_label'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.exactFF6B7280,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5.sp,
                    color: AppColors.inkClr,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.exactFF6B7280,
                size: 18.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

