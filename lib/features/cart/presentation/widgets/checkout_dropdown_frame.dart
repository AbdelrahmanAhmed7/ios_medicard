import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CheckoutDropdownFrame extends StatelessWidget {
  final Widget child;

  const CheckoutDropdownFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.exactFFE5E9F0),
      ),
      child: child,
    );
  }
}

