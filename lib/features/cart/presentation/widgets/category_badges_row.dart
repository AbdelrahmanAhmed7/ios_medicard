import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../domain/models/category_counter.dart';

class CategoryBadgesRow extends StatelessWidget {
  final List<CategoryCounter> counters;

  const CategoryBadgesRow({super.key, required this.counters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'cart.categories'.tr(),
          style: AppTextStyles.of(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 4.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.only(top: 8.h, bottom: 2.h),
          child: Row(
            children: counters
                .map(
                  (c) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 10.w),
                    child: CategoryChip(counter: c),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final CategoryCounter counter;

  const CategoryChip({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF3872B1), width: 1.2),
          ),
          child: Text(
            counter.categoryName,
            style: AppTextStyles.of(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3872B1),
            ),
          ),
        ),
        if (counter.count > 0)
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Container(
              constraints: BoxConstraints(minWidth: 20.r, minHeight: 20.r),
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              decoration: BoxDecoration(
                color: const Color(0xFF3872B1),
                shape: counter.count > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: counter.count > 9
                    ? BorderRadius.circular(10.r)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${counter.count}',
                  style: AppTextStyles.of(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
