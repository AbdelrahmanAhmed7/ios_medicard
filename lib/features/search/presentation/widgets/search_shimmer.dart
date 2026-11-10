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

class ProviderCategoriesShimmer extends StatelessWidget {
  const ProviderCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.exactFFE5E7EB,
      highlightColor: AppColors.exactFFF3F4F6,
      child: SizedBox(
        height: 58.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          itemCount: 5,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (_, index) => Container(
            width: index == 0 ? 68.w : 92.w,
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
        ),
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
            width: 92.r,
            height: 92.r,
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
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      height: 24.h,
                      width: 78.w,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 22.h,
                      width: 98.w,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 9.h),
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
