import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../data/models/search_provider_model.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ProviderCard extends StatelessWidget {
  final SearchProviderModel provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (provider.providerId != null) {
          context.push('/provider-page', extra: provider.providerId);
        }
      },
      child: Container(
        key: ValueKey('provider_card_${provider.providerId}'),
        constraints: BoxConstraints(minHeight: 124.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.whiteClr,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.exactFFE5E9F0, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.exactFF0F172A.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImageSection(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _hasText(provider.providerName)
                                ? provider.providerName!.trim()
                                : '',
                            style: AppTextStyles.of(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: AppColors.exactFF0F172A,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: AppColors.exactFFC3CEDD,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    if ((provider.maxDiscountPercentage ?? 0) > 0) ...[
                      _DiscountChipsRow(
                        categoryName: provider.categoryName,
                        maxDiscount: provider.maxDiscountPercentage,
                      ),
                      SizedBox(height: 5.h),
                    ],
                    _LocationAndContactRow(provider: provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      key: ValueKey('provider_image_${provider.providerId}'),
      width: 108.w,
      height: 108.h,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: provider.imageUrl ?? '',
                memCacheWidth: 300,
                memCacheHeight: 300,
                fit: BoxFit.fill,
                placeholder: (context, url) => ColoredBox(
                  color: AppColors.exactFFEEF3FB,
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.exactFFB9CBE4,
                    size: 30.sp,
                  ),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: AppColors.exactFFEEF3FB,
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.brandBlueClr,
                    size: 30.sp,
                  ),
                ),
              ),
              if ((provider.averageRating ?? 0) > 0)
                PositionedDirectional(
                  top: 6.h,
                  start: 6.w,
                  child: _RatingBadge(
                    key: ValueKey('provider_rating_${provider.providerId}'),
                    rating: provider.averageRating!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.exactFFFFF8E7,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.exactFFFDE6AE),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: AppColors.exactFFF5A623, size: 13.sp),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.of(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.exactFF1F2937,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountChipsRow extends StatelessWidget {
  final String? categoryName;
  final double? maxDiscount;

  const _DiscountChipsRow({this.categoryName, this.maxDiscount});

  @override
  Widget build(BuildContext context) {
    if (maxDiscount == null || maxDiscount! <= 0) {
      return const SizedBox.shrink();
    }

    final pct = maxDiscount!.toStringAsFixed(0);
    final hasCategory = categoryName != null && categoryName!.trim().isNotEmpty;

    return Row(
      children: [
        if (hasCategory)
          Flexible(
            child: _buildChip(
              categoryName!.trim(),
              AppColors.exactFFF1F5F9,
              AppColors.inkMutedClr,
              FontWeight.w500,
            ),
          ),
        if (hasCategory) SizedBox(width: 6.w),
        _buildChip(
          'search.up_to_discount'.tr(args: [pct]),
          AppColors.exactFFEFF6FF,
          AppColors.brandBlueClr,
          FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color bg, Color fg, FontWeight weight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.of(fontSize: 11.sp, color: fg, fontWeight: weight),
      ),
    );
  }
}

class _LocationAndContactRow extends StatelessWidget {
  final SearchProviderModel provider;

  const _LocationAndContactRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasDistance = provider.distanceKm != null;
    final hotline = provider.hotline?.trim() ?? '';
    final whatsApp = provider.whatsApp?.trim() ?? '';
    final hasContactAction = hotline.isNotEmpty || whatsApp.isNotEmpty;

    if (!hasDistance && !hasContactAction) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDistance)
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14.sp,
                color: AppColors.inkSoftClr,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  '${provider.distanceKm!.toStringAsFixed(1)} km',
                  style: AppTextStyles.of(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (hasContactAction) ...[
          SizedBox(height: 7.h),
          Row(
            children: [
              if (hotline.isNotEmpty)
                GestureDetector(
                  key: ValueKey('provider_phone_${provider.providerId}'),
                  onTap: () => UrlLauncherService().makePhoneCall(hotline),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.exactFFECFDF5,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_in_talk_rounded,
                          size: 13.sp,
                          color: AppColors.exactFF16A34A,
                        ),
                        SizedBox(width: 5.w),
                        Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: Text(
                            hotline,
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.exactFF15803D,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (whatsApp.isNotEmpty)
                Tooltip(
                  message: 'help_center.whatsapp'.tr(),
                  child: GestureDetector(
                    key: ValueKey('provider_whatsapp_${provider.providerId}'),
                    onTap: () => UrlLauncherService().launchWhatsApp(whatsApp),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox.square(
                      dimension: 28.r,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/whatsapp-svgrepo-com.svg',
                          width: 20.r,
                          height: 20.r,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

