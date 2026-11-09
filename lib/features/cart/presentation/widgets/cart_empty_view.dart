import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CartEmptyView extends StatelessWidget {
  final VoidCallback onExplore;

  const CartEmptyView({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 132.r,
              height: 132.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.exactFFEFF6FF, AppColors.whiteClr],
                ),
                border: Border.all(color: AppColors.exactFFDBEAFE, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlueClr.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.cart,
                size: 58.sp,
                color: AppColors.brandBlueClr,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'cart.empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.inkClr,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'cart.empty_message'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.exactFF6B7280,
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: onExplore,
                icon: Icon(Icons.search_rounded, size: 20.sp),
                label: Text(
                  'cart.explore_services'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteClr,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlueClr,
                  foregroundColor: AppColors.whiteClr,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

