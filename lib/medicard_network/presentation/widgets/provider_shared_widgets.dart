import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/url_launcher_service.dart';
import '../../../core/theming/app_text_styles.dart';
import '../../../core/utils/image_url_resolver.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_state.dart';

/// Shared stateless building blocks for the provider page sections.
/// Extracted verbatim from provider_page_screen.dart (mechanical move).

String formatPrice(double? price) {
  if (price == null) return '';
  return price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2);
}

String packageImageUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.startsWith('http')) return trimmed;
  final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  if (normalized.startsWith('uploads/')) {
    return 'https://medicard-api-v2.medicardeg.com/$normalized';
  }
  return 'https://medicard-api-v2.medicardeg.com/uploads/providers/$normalized';
}

class ProviderInfoRow extends StatelessWidget {
  final ProviderPageData data;
  final int servicesCount;
  final ProviderBranch? selectedBranch;
  final VoidCallback onBranchTap;
  final VoidCallback onRatingTap;

  const ProviderInfoRow({super.key,
    required this.data,
    required this.servicesCount,
    required this.selectedBranch,
    required this.onBranchTap,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Logo ────────────────────────────────────────────────────────────
        Container(
          width: 76.w,
          height: 76.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8.r),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: data.providerLogo,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.local_hospital, color: Color(0xFF3872B1)),
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // ── Name + branch + stats ────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.providerName,
                style: AppTextStyles.of(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: onBranchTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(34),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withAlpha(150)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          selectedBranch?.branchName ??
                              'provider_page.select_branch'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.layers_outlined,
                    color: Colors.white70,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'provider_page.services_count'.tr(args: ['$servicesCount']),
                    style: AppTextStyles.of(color: Colors.white, fontSize: 12.sp),
                  ),
                  if (data.phones != null && data.phones!.isNotEmpty) ...[
                    SizedBox(width: 14.w),
                    GestureDetector(
                      onTap: () =>
                          UrlLauncherService().makePhoneCall(data.phones!.first),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_in_talk_rounded,
                            color: Colors.white70,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            data.phones!.first,
                            style: AppTextStyles.of(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ── Rating badge ─────────────────────────────────────────────────────
        if (data.rating != null)
          GestureDetector(
            onTap: onRatingTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFF5A623),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${data.rating} (${data.reviewsCount ?? 0})',
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class PackageServiceNames extends StatelessWidget {
  final List<String> serviceNames;

  const PackageServiceNames({super.key, required this.serviceNames});

  @override
  Widget build(BuildContext context) {
    if (serviceNames.isEmpty) {
      return Text(
        'No services found',
        style: AppTextStyles.of(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: serviceNames.take(3).map((name) {
        return Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 11.sp,
                color: const Color(0xFF22C55E),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.of(
                    fontSize: 11.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PackagePlainServiceNames extends StatelessWidget {
  final List<String> serviceNames;

  const PackagePlainServiceNames({super.key, required this.serviceNames});

  @override
  Widget build(BuildContext context) {
    if (serviceNames.isEmpty) {
      return Text(
        'No services found',
        style: AppTextStyles.of(fontSize: 14.sp, color: const Color(0xFF64748B)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(serviceNames.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text(
            '${index + 1}-${serviceNames[index]}',
            style: AppTextStyles.of(
              fontSize: 14.sp,
              color: const Color(0xFF4B5563),
              height: 1.22,
            ),
          ),
        );
      }),
    );
  }
}

class ServiceBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;

  const ServiceBadge({super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
          ],
          Text(
            label,
            style: AppTextStyles.of(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTabChip extends StatelessWidget {
  final CategoryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTabChip({super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Chip body ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3872B1)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: const Color(0xFF3872B1),
                width: isSelected ? 0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3872B1).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category image when the backend provides one.
                if (tab.imageUrl != null && tab.imageUrl!.isNotEmpty) ...[
                  ClipOval(
                    child: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CachedNetworkImage(
                        imageUrl: resolveImageUrl(tab.imageUrl) ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                // Loading spinner while services are being fetched.
                if (tab.isLoading) ...[
                  SizedBox(
                    width: 12.r,
                    height: 12.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3872B1),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  tab.categoryName,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF3872B1),
                  ),
                ),
              ],
            ),
          ),

          // ── Badge (selected count) ─────────────────────────────────────
          if (tab.selectedCount > 0)
            Positioned(
              top: -6.h,
              right: -6.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: tab.selectedCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: tab.selectedCount > 9
                      ? BorderRadius.circular(9.r)
                      : null,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${tab.selectedCount}',
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
