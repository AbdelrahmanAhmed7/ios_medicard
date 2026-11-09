import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/shimmer_card.dart';
import '../../../../core/widgets/app_blue_header.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Blue header placeholder
          SmoothShimmer(
            child: Container(
              width: double.infinity,
              height: statusBarHeight + kMainTabHeaderContentHeight,
              decoration: const BoxDecoration(
                color: AppColors.exactFFE8E8E8,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
          ),
          // User info row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: const ShimmerListItem(showAvatar: true, lines: 2),
          ),
          // Section title 1
          const _SectionTitleShimmer(),
          // Settings card
          ShimmerCard(
            width: double.infinity,
            height: 280.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(height: 24.h),
          // Section title 2
          const _SectionTitleShimmer(),
          // Links card
          ShimmerCard(
            width: double.infinity,
            height: 160.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _SectionTitleShimmer extends StatelessWidget {
  const _SectionTitleShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 12.h),
      child: SmoothShimmer(
        child: Container(
          height: 16.h,
          width: 100.w,
          decoration: BoxDecoration(
            color: AppColors.exactFFE8E8E8,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ),
    );
  }
}
