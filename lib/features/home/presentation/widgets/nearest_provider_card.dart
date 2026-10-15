import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/provider_model.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_text_styles.dart';

class NearestProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const NearestProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (provider.providerId != null) {
          context.push('/provider-page', extra: provider.providerId);
        }
      },
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15), // حل مشكلة الحواف البيضاء
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    color: const Color(0xFFEEF3FB),
                    height: 148,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: provider.imageUrl,
                      height: 148,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 148,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 148,
                        width: double.infinity,
                        child: const Icon(
                          Icons.broken_image,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                  if (provider.rating > 0 || provider.reviewCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFF5A623),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${provider.rating} (${provider.reviewCount})',
                              style: AppTextStyles.of(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // الفاصل بين الصورة والبيانات
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.badges.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 3,
                        children: provider.badges
                            .map(
                              (badge) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF3FB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF3872B1),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  badge,
                                  style: AppTextStyles.of(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3872B1),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      provider.name,
                      style: AppTextStyles.of(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (provider.type.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        provider.type,
                        style: AppTextStyles.of(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (provider.location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              provider.location,
                              style: AppTextStyles.of(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (provider.distanceKm != null ||
                        provider.mapUrl.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          if (provider.distanceKm != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.navigation_outlined,
                                    size: 12.sp,
                                    color: const Color(0xFF3872B1),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${provider.distanceKm!.toStringAsFixed(1)} km',
                                    style: AppTextStyles.of(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3872B1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (provider.mapUrl.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => UrlLauncherService().launchURL(
                                provider.mapUrl,
                              ),
                              icon: Icon(
                                Icons.map_outlined,
                                size: 14.sp,
                                color: const Color(0xFF3872B1),
                              ),
                              label: Text(
                                'provider_page.open_map'.tr(),
                                style: AppTextStyles.of(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3872B1),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                    ],
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
