import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/category_model.dart';

import '../../../../core/theming/app_text_styles.dart';

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
    const activeColor = Color(0xFF3872B1);

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
              color: isSelected ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE5E9F0),
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
                            ? Colors.white
                            : const Color(0xFF1E3A5F),
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
                              : const Color(0xFF8A94A6),
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
                  color: Color(0xFF3872B1),
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

  Widget _chipImage({required bool isSelected}) {
    const activeColor = Color(0xFF3872B1);
    final imageUrl = category?.imageUrl;
    Widget content;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final placeholder = Container(
        width: 26.r,
        height: 26.r,
        color: const Color(0xFFEFF6FF),
      );
      final errorIcon = Icon(
        Icons.image_not_supported_outlined,
        size: 18.r,
        color: isSelected ? Colors.white : activeColor,
      );
      content = isSvgImageUrl(imageUrl)
          ? SvgPicture.network(
              imageUrl,
              width: 26.r,
              height: 26.r,
              fit: BoxFit.fill,
              placeholderBuilder: (_) => placeholder,
              errorBuilder: (_, _, _) => errorIcon,
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: 26.r,
              height: 26.r,
              fit: BoxFit.fill,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => errorIcon,
            );
    } else {
      content = Icon(
        Icons.grid_view_rounded,
        size: 18.r,
        color: isSelected ? Colors.white : activeColor,
      );
    }
    return ClipOval(
      child: Container(
        width: 30.r,
        height: 30.r,
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFEFF6FF),
        child: Center(
          child: SizedBox(width: 26.r, height: 26.r, child: content),
        ),
      ),
    );
  }
}

@visibleForTesting
bool isSvgImageUrl(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  return path.toLowerCase().endsWith('.svg');
}
