import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/category_model.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/category_image.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CategoryChip extends StatelessWidget {
  final CategoryModel? category;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final int? serviceCount;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
    this.serviceCount,
  });

  @override
  Widget build(BuildContext context) {
    final label = category?.name ?? 'All';
    const activeColor = AppColors.brandBlueClr;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsetsDirectional.only(end: 8.w),
            padding: EdgeInsetsDirectional.only(
              start: 6.w,
              end: 14.w,
              top: 7.h,
              bottom: 7.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : AppColors.whiteClr,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.exactFFE5E9F0,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chipImage(isSelected: isSelected),
                SizedBox(width: 8.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.of(
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.whiteClr
                            : AppColors.exactFF1E3A5F,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (serviceCount != null && serviceCount! > 0) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'search.services_count'.tr(args: ['$serviceCount']),
                        style: AppTextStyles.of(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.75)
                              : AppColors.exactFF8A94A6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -4.h,
              right: Directionality.of(context) == TextDirection.rtl
                  ? null
                  : 2.w,
              left: Directionality.of(context) == TextDirection.rtl
                  ? 2.w
                  : null,
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: const BoxDecoration(
                  color: AppColors.brandBlueClr,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: AppTextStyles.of(
                    color: AppColors.whiteClr,
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

  Widget _chipImage({required bool isSelected}) {
    const activeColor = AppColors.brandBlueClr;
    final imageUrl = category?.imageUrl;
    Widget content;
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      final placeholder = Container(
        width: 26.r,
        height: 26.r,
        color: isSelected ? activeColor : AppColors.exactFFEFF6FF,
      );
      final errorIcon = Icon(
        Icons.image_not_supported_outlined,
        size: 18.r,
        color: isSelected ? AppColors.whiteClr : activeColor,
      );
      content = CategoryImage(
        imageUrl: imageUrl,
        width: 26.r,
        height: 26.r,
        fit: BoxFit.fill,
        placeholder: placeholder,
        errorWidget: errorIcon,
        svgColor: isSelected ? AppColors.whiteClr : activeColor,
      );
    } else {
      content = Icon(
        Icons.grid_view_rounded,
        size: 18.r,
        color: isSelected ? AppColors.whiteClr : activeColor,
      );
    }
    return ClipOval(
      child: Container(
        width: 30.r,
        height: 30.r,
        color: isSelected ? activeColor : AppColors.exactFFEFF6FF,
        child: Center(
          child: SizedBox(width: 26.r, height: 26.r, child: content),
        ),
      ),
    );
  }
}

