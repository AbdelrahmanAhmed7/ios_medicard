import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medicard/core/utils/shimmer_card.dart';

class ContentShimmer extends StatelessWidget {
  const ContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        Container(
          height: 80.h + statusBarHeight,
          color: const Color(0xFF2D5FA6),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                ShimmerCard(width: double.infinity, height: 20.h),
                SizedBox(height: 12.h),
                ShimmerCard(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerCard(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerCard(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerCard(width: 0.8.sw, height: 16.h),
                SizedBox(height: 12.h),
                ShimmerCard(width: double.infinity, height: 20.h),
                SizedBox(height: 12.h),
                ShimmerCard(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerCard(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                ShimmerCard(width: 0.6.sw, height: 16.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
