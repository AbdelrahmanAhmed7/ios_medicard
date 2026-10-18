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
  final VoidCallback onBack;
  final VoidCallback onBranchTap;
  final VoidCallback onRatingTap;

  const ProviderInfoRow({
    super.key,
    required this.data,
    required this.servicesCount,
    required this.selectedBranch,
    required this.onBack,
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
            SizedBox(
              width: 40.r,
              height: 40.r,
              child: IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF111827),
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 54.r,
              height: 54.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E9F0), width: 1.5),
              ),
              padding: EdgeInsets.all(6.r),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: data.providerLogo,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF3872B1),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.providerName,
                    style: AppTextStyles.of(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (data.categoryName.trim().isNotEmpty)
                        Text(
                          data.categoryName,
                          style: AppTextStyles.of(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'provider_page.services_count'.tr(
                            args: ['$servicesCount'],
                          ),
                          style: AppTextStyles.of(
                            color: const Color(0xFF2563EB),
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (data.rating != null)
                        GestureDetector(
                          onTap: onRatingTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFF5A623),
                                  size: 13.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  '${data.rating} (${data.reviewsCount ?? 0})',
                                  style: AppTextStyles.of(
                                    color: const Color(0xFF92400E),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (data.phones?.isNotEmpty == true) ...[
              SizedBox(width: 8.w),
              Tooltip(
                message: 'provider_page.call'.tr(),
                child: Material(
                  color: const Color(0xFFEFF6FF),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        UrlLauncherService().makePhoneCall(data.phones!.first),
                    child: SizedBox(
                      width: 36.r,
                      height: 36.r,
                      child: Icon(
                        Icons.phone_in_talk_rounded,
                        color: const Color(0xFF2563EB),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (data.branches?.isNotEmpty == true) ...[
          SizedBox(height: 8.h),
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11.r),
            child: InkWell(
              onTap: onBranchTap,
              borderRadius: BorderRadius.circular(11.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: const Color(0xFF3872B1),
                      size: 17.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        selectedBranch?.branchName ??
                            'provider_page.select_branch'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF3872B1),
                      size: 20.sp,
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
          color: const Color(0xFF94A3B8),
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
        'provider_page.no_services_found'.tr(),
        style: AppTextStyles.of(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
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
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: const Color(0xFF2563EB),
                  size: 13.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  serviceNames[index],
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: const Color(0xFF334155),
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

  const CartActionButton({
    super.key,
    required this.inCart,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: inCart ? const Color(0xFFEAF1F9) : const Color(0xFF3872B1),
          shape: BoxShape.circle,
          border: inCart
              ? Border.all(
                  color: const Color(0xFF3872B1).withValues(alpha: 0.35),
                )
              : null,
        ),
        child: Icon(
          inCart ? Icons.remove_rounded : Icons.add_rounded,
          size: 20.sp,
          color: inCart ? const Color(0xFF3872B1) : Colors.white,
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
