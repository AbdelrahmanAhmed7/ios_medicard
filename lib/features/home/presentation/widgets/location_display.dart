import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

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
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: Colors.white.withValues(alpha: 0.85),
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.location_label'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
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
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
