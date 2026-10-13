import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../data/models/search_provider_model.dart';

import '../../../../core/theming/app_text_styles.dart';


class ProviderCard extends StatelessWidget {
  final SearchProviderModel provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (provider.providerId != null) {
          context.push(
            '/provider-page',
            extra: provider.providerId,
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 124.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 13.h, 12.w, 13.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    if (_hasText(provider.providerName)) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.providerName!.trim(),
                              style: AppTextStyles.of(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14.sp,
                            color: const Color(0xFFC3CEDD),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                    ],
                      if ((provider.maxDiscountPercentage ?? 0) > 0) ...[
                        _DiscountChipsRow(
                          categoryName: provider.categoryName,
                          maxDiscount: provider.maxDiscountPercentage,
                        ),
                        SizedBox(height: 7.h),
                      ],
                      _RatingAndLocationRow(provider: provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      width: 108.w,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: provider.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFEEF3FB),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: const Color(0xFFB9CBE4),
                  size: 30.sp,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFEEF3FB),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: const Color(0xFF3872B1),
                  size: 30.sp,
                ),
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
    final hasCategory =
        categoryName != null && categoryName!.trim().isNotEmpty;

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        if (hasCategory)
          _buildChip(
            categoryName!.trim(),
            const Color(0xFFF1F5F9),
            const Color(0xFF64748B),
            FontWeight.w500,
          ),
        _buildChip(
          'search.up_to_discount'.tr(args: [pct]),
          const Color(0xFFEFF6FF),
          const Color(0xFF3872B1),
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
        style: AppTextStyles.of(
          fontSize: 11.sp,
          color: fg,
          fontWeight: weight,
        ),
      ),
    );
  }
}

class _RatingAndLocationRow extends StatelessWidget {
  final SearchProviderModel provider;

  const _RatingAndLocationRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasRating = (provider.averageRating ?? 0) > 0;
    final hasDistance = provider.distanceKm != null;
    final hotline = provider.hotline?.trim() ?? '';

    if (!hasRating && !hasDistance && hotline.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (hasRating) ...[
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFF5A623),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                provider.totalReviews != null && provider.totalReviews! > 0
                    ? '${provider.averageRating!.toStringAsFixed(1)} (${provider.totalReviews})'
                    : provider.averageRating!.toStringAsFixed(1),
                style: AppTextStyles.of(fontSize: 12.sp),
              ),
            ],
            if (hasRating && hasDistance) const Spacer(),
            if (hasDistance) ...[
              Icon(
                Icons.location_on_outlined,
                size: 14.sp,
                color: const Color(0xFF475569),
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
          ],
        ),
        if (hotline.isNotEmpty) ...[
          SizedBox(height: 7.h),
          Row(
            children: [
              GestureDetector(
                onTap: () => UrlLauncherService().makePhoneCall(hotline),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded,
                        size: 13.sp,
                        color: const Color(0xFF16A34A),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        hotline,
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => UrlLauncherService().launchWhatsApp(hotline),
                child: SvgPicture.asset(
                  'assets/whatsapp-svgrepo-com.svg',
                  width: 28.r,
                  height: 28.r,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
