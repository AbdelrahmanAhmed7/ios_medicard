import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

class CartEmptyView extends StatelessWidget {
  final VoidCallback onExplore;

  const CartEmptyView({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 108.r,
            height: 108.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_checkout_rounded,
              size: 50.sp,
              color: const Color(0xFF3872B1),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'cart.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'cart.empty_message'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 14.sp,
              height: 1.4,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: onExplore,
              icon: Icon(Icons.search_rounded, size: 19.sp),
              label: Text('cart.explore_services'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
