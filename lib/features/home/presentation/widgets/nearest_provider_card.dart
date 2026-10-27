import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/provider_model.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';
import 'home_horizontal_card_style.dart';

class NearestProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const NearestProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppSpacing.compactCardMaxTextScale,
      child: GestureDetector(
        onTap: () {
          if (provider.providerId != null) {
            context.push('/provider-page', extra: provider.providerId);
          }
        },
        child: Container(
          width: HomeHorizontalCardStyle.width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(HomeHorizontalCardStyle.radius),
            border: Border.all(
              color: HomeHorizontalCardStyle.line,
              width: HomeHorizontalCardStyle.borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              HomeHorizontalCardStyle.clippedRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      color: HomeHorizontalCardStyle.imageBackground,
                      height: HomeHorizontalCardStyle.imageHeight,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: provider.imageUrl,
                        memCacheWidth: 400,
                        memCacheHeight: 300,
                        height: HomeHorizontalCardStyle.imageHeight,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                        placeholder: (context, url) => Container(
                          color: HomeHorizontalCardStyle.imageBackground,
                          height: HomeHorizontalCardStyle.imageHeight,
                          width: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: HomeHorizontalCardStyle.imageBackground,
                          height: HomeHorizontalCardStyle.imageHeight,
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
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: HomeHorizontalCardStyle.ratingPadding,
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
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${provider.rating} (${provider.reviewCount})',
                                style: HomeHorizontalCardStyle.ratingText,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // الفاصل بين الصورة والبيانات
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: HomeHorizontalCardStyle.line,
                ),
                Expanded(
                  child: Padding(
                    padding: HomeHorizontalCardStyle.contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: const Color(0xFF3872B1),
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
                          style: HomeHorizontalCardStyle.titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (provider.type.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            provider.type,
                            style: HomeHorizontalCardStyle.supportingText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (provider.location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  provider.location,
                                  style: HomeHorizontalCardStyle.supportingText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (provider.distanceKm != null ||
                            provider.mapUrl.isNotEmpty) ...[
                          const Spacer(),
                          Row(
                            key: const ValueKey('nearest-provider-footer'),
                            children: [
                              if (provider.distanceKm != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.navigation_outlined,
                                        size: 12,
                                        color: Color(0xFF3872B1),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider.distanceKm!.toStringAsFixed(1)} km',
                                        style:
                                            HomeHorizontalCardStyle.actionText,
                                      ),
                                    ],
                                  ),
                                ),
                              const Spacer(),
                              if (provider.mapUrl.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => UrlLauncherService()
                                      .launchURL(provider.mapUrl),
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    size: 14,
                                    color: Color(0xFF3872B1),
                                  ),
                                  label: Text(
                                    'provider_page.open_map'.tr(),
                                    style: HomeHorizontalCardStyle.actionText,
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
