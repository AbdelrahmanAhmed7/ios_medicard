import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../network/data/provider_page_response_model.dart';
import 'provider_shared_widgets.dart';

/// Package grid card. Pure: all actions come in as callbacks from the parent
/// section, which owns the cubit.
class ProviderPackageCard extends StatelessWidget {
  final ProviderPackage packageData;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onQuickAdd;

  const ProviderPackageCard({
    super.key,
    required this.packageData,
    this.onDetailsTap,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onDetailsTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: packageData.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF3872B1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.w,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: onQuickAdd,
                      child: Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3872B1),
                            width: 1.3,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: const Color(0xFF3872B1),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageData.name ?? '',
                      style: AppTextStyles.of(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (packageData.description?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 3.h),
                      Text(
                        packageData.description!.trim(),
                        style: AppTextStyles.of(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (packageData.priceBefore != null)
                          Flexible(
                            child: Text(
                              '${formatPrice(packageData.priceBefore)} EGP',
                              style: AppTextStyles.of(
                                fontSize: 11.sp,
                                color: Colors.black,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (packageData.priceAfter != null)
                          Text(
                            '${formatPrice(packageData.priceAfter)} EGP',
                            style: AppTextStyles.of(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F6BC1),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
