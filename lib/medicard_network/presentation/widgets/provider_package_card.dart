import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_spacing.dart';
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

  /// Keeps the card compact while allowing the 16:9 image to follow its width.
  static double preferredHeightForWidth(double cardWidth) {
    const contentHeight = 94.0;
    const minHeight = 174.0;
    const maxHeight = 210.0;
    return (cardWidth * 9 / 16 + contentHeight)
        .clamp(minHeight, maxHeight)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppSpacing.compactCardMaxTextScale,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: AppSpacing.compactCardBorderWidth,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: onDetailsTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6.5, 8, 5.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      SizedBox(height: 2.h),
                      Text(
                        packageData.description!.trim(),
                        style: AppTextStyles.of(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Row(
                      key: const ValueKey('provider-package-footer'),
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (packageData.priceBefore != null)
                                Text(
                                  '${formatPrice(packageData.priceBefore)} EGP',
                                  style: AppTextStyles.of(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF94A3B8),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (packageData.priceAfter != null)
                                Text(
                                  '${formatPrice(packageData.priceAfter)} EGP',
                                  style: AppTextStyles.of(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F6BC1),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IgnorePointer(
                          ignoring: onQuickAdd == null,
                          child: CartActionButton(
                            inCart: false,
                            onPressed: onQuickAdd ?? () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
