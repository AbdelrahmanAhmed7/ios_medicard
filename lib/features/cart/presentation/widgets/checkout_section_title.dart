import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CheckoutSectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;

  const CheckoutSectionTitle({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: AppColors.exactFFEFF6FF,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.brandBlueClr),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.of(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkClr,
            ),
          ),
        ),
      ],
    );
  }
}

