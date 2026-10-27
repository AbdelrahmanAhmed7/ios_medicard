import 'dart:math' as math;

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

  /// Keeps the grid card tall enough for its 16:9 image and fullest footer.
  static double preferredHeightForWidth(
    BuildContext context,
    double cardWidth,
  ) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: AppSpacing.compactCardMaxTextScale);
    final titleHeight = _singleLineHeight(
      context,
      AppTextStyles.of(fontSize: 13.sp, fontWeight: FontWeight.w700),
      textScaler,
    );
    final descriptionHeight = _singleLineHeight(
      context,
      AppTextStyles.of(fontSize: 10.5.sp, height: 1.3),
      textScaler,
    );
    final pricesHeight =
        _singleLineHeight(
          context,
          AppTextStyles.of(fontSize: 10.5.sp),
          textScaler,
        ) +
        _singleLineHeight(
          context,
          AppTextStyles.of(fontSize: 13.sp, fontWeight: FontWeight.w600),
          textScaler,
        );
    final footerHeight = math.max(38.r, pricesHeight);
    final contentHeight =
        6.5 + titleHeight + 2.h + descriptionHeight + 4.h + footerHeight + 5.5;
    const borderHeight = AppSpacing.compactCardBorderWidth * 2;
    final imageWidth = math.max(0.0, cardWidth - borderHeight);

    return imageWidth * 9 / 16 + contentHeight + borderHeight;
  }

  static double _singleLineHeight(
    BuildContext context,
    TextStyle style,
    TextScaler textScaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'Ag',
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: textScaler,
    )..layout();
    return painter.height;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppSpacing.compactCardMaxTextScale,
      child: DecoratedBox(
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
                    fit: BoxFit.fill,
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
