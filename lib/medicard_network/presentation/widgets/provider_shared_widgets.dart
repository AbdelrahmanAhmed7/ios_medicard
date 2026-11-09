import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/url_launcher_service.dart';
import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/category_image.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_state.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Shared stateless building blocks for the provider page sections.
/// Extracted verbatim from provider_page_screen.dart (mechanical move).

export '../../../core/utils/price_formatter.dart'
    show PriceFormatter, formatPrice;

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

  const ProviderInfoRow({
    super.key,
    required this.data,
    required this.servicesCount,
    required this.selectedBranch,
    required this.onBranchTap,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.whiteClr,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.exactFFE5E9F0),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: data.providerLogo.trim().isEmpty
                    ? const Icon(Icons.local_hospital, color: AppColors.brandBlueClr)
                    : CachedNetworkImage(
                        imageUrl: data.providerLogo,
                        fit: BoxFit.fill,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.local_hospital,
                          color: AppColors.brandBlueClr,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.providerName,
                    style: AppTextStyles.of(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkClr,
                      height: 1.3,
                    ),
                  ),
                  if (data.categoryName.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.categoryName,
                      style: AppTextStyles.of(
                        color: AppColors.inkMutedClr,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (data.phones?.isNotEmpty == true) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'provider_page.call'.tr(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.exactFFEFF6FF,
                  foregroundColor: AppColors.exactFF2563EB,
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () =>
                    UrlLauncherService().makePhoneCall(data.phones!.first),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 19),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Compact meta line: rating (tap opens reviews) followed by the
        // services count. Everything fits on one line and ellipsizes instead
        // of stacking into full-width tiles.
        Row(
          children: [
            if (data.rating != null) ...[
              Flexible(
                child: InkWell(
                  onTap: onRatingTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.exactFFF59E0B,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.rating!.toStringAsFixed(1),
                        style: AppTextStyles.of(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.exactFF92400E,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'provider_page.reviews_count'.tr(
                            args: ['${data.reviewsCount ?? 0}'],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.of(
                            fontSize: 12,
                            color: AppColors.exactFFB45309,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.exactFFB45309,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 14, color: AppColors.lineClr),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 15,
                    color: AppColors.exactFF2563EB,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'provider_page.services_count'.tr(
                        args: ['$servicesCount'],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.of(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.exactFF2563EB,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (data.branches?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Material(
            color: AppColors.exactFFF8FAFC,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onBranchTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lineClr),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.brandBlueClr,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        selectedBranch?.branchName ??
                            'provider_page.select_branch'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.of(
                          fontSize: 12.5,
                          color: AppColors.exactFF334155,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.brandBlueClr,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        style: AppTextStyles.of(
          fontSize: 11.sp,
          color: AppColors.inkFaintClr,
        ),
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
                color: AppColors.exactFF22C55E,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.of(
                    fontSize: 11.sp,
                    color: AppColors.inkSoftClr,
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
        'provider_page.no_services_found'.tr(),
        style: AppTextStyles.of(
          fontSize: 13.sp,
          color: AppColors.inkFaintClr,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(serviceNames.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < serviceNames.length - 1 ? 9.h : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20.r,
                height: 20.r,
                decoration: const BoxDecoration(
                  color: AppColors.exactFFDBEAFE,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.exactFF2563EB,
                  size: 13.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  serviceNames[index],
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: AppColors.exactFF334155,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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

  const ServiceBadge({
    super.key,
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

/// Round action button for a service card.
///
/// The cart stores each service as a single entry (no quantity), so the
/// button is a toggle: `+` when the service is not in the cart, `−` when it
/// is. Tapping always fires [onPressed]; the caller decides add vs remove.
class CartActionButton extends StatelessWidget {
  final bool inCart;
  final VoidCallback onPressed;
  final double? size;
  final double? iconSize;

  const CartActionButton({
    super.key,
    required this.inCart,
    required this.onPressed,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 38.r;
    final effectiveIconSize = iconSize ?? 20.sp;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          color: inCart ? AppColors.exactFFEAF1F9 : AppColors.brandBlueClr,
          shape: BoxShape.circle,
          border: inCart
              ? Border.all(
                  color: AppColors.brandBlueClr.withValues(alpha: 0.35),
                )
              : null,
        ),
        child: Icon(
          inCart ? Icons.remove_rounded : Icons.add_rounded,
          size: effectiveIconSize,
          color: inCart ? AppColors.brandBlueClr : AppColors.whiteClr,
        ),
      ),
    );
  }
}

class CategoryTabChip extends StatelessWidget {
  final CategoryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTabChip({
    super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = tab.imageUrl?.trim();
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
                  ? AppColors.brandBlueClr
                  : AppColors.exactFFEFF6FF,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: AppColors.brandBlueClr,
                width: isSelected ? 0 : 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category image when the backend provides one.
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  ClipOval(
                    child: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CategoryImage(
                        imageUrl: imageUrl,
                        width: 22.r,
                        height: 22.r,
                        errorWidget: _categoryImageError(isSelected),
                        placeholder: const SizedBox.shrink(),
                        svgColor: isSelected
                            ? AppColors.whiteClr
                            : AppColors.brandBlueClr,
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
                          ? AppColors.whiteClr
                          : AppColors.brandBlueClr,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  tab.categoryName,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.whiteClr : AppColors.brandBlueClr,
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
                  color: AppColors.exactFFEF4444,
                  shape: tab.selectedCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: tab.selectedCount > 9
                      ? BorderRadius.circular(9.r)
                      : null,
                  border: Border.all(color: AppColors.whiteClr, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${tab.selectedCount}',
                    style: AppTextStyles.of(
                      color: AppColors.whiteClr,
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

Widget _categoryImageError(bool isSelected) => Icon(
  Icons.image_not_supported_outlined,
  size: 16.r,
  color: isSelected ? AppColors.whiteClr : AppColors.brandBlueClr,
);

