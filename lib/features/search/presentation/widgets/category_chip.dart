import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/category_model.dart';

import '../../../../core/theming/app_text_styles.dart';


class CategoryChip extends StatelessWidget {
  final CategoryModel? category;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final label = category?.name ?? 'All';
    final activeColor = const Color(0xFF2D5FA6);
    final inactiveBgColor = const Color(0xFFF3F6F9);
    final inactiveContentColor = const Color(0xFF1E3F66);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(right: 8.w),
            width: 80.w,
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : inactiveBgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: isSelected
                  ? Border.all(color: activeColor, width: 1.5.w)
                  : Border.all(color: Colors.transparent, width: 1.5.w),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category != null && category!.imageUrl != null) ...[
                  CachedNetworkImage(
                    imageUrl: category!.imageUrl!,
                    width: 26.r,
                    height: 26.r,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => SizedBox(
                      width: 26.r,
                      height: 26.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: isSelected ? activeColor : inactiveContentColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image_not_supported_outlined,
                      size: 24.r,
                      color: isSelected ? activeColor : inactiveContentColor,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.grid_view_rounded,
                    size: 26.r,
                    color: isSelected ? activeColor : inactiveContentColor,
                  ),
                ],
                SizedBox(height: 6.h),
                Text(
                  label,
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveContentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -4.h,
              right: 2.w,
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D5FA6),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: AppTextStyles.of(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
