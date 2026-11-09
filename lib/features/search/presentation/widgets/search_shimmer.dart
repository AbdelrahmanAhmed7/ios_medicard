import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:medicard/core/theming/app_colors.dart';
class SearchShimmer extends StatelessWidget {
  const SearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.exactFFE5E7EB,
      highlightColor: AppColors.exactFFF3F4F6,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        itemBuilder: (_, _) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // لوجو وهمي بنفس حجم اللوجو الحقيقي
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      height: 22.h,
                      width: 70.w,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 22.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 12.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(6.r),
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

