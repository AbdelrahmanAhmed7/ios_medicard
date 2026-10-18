import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_session_storage.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../medicard_network/domain/usecases/get_package_details_usecase.dart';
import '../../../../medicard_network/presentation/widgets/package_details_sheet.dart';
import '../../../../medicard_network/presentation/widgets/provider_shared_widgets.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/featured_service_model.dart';

class FeaturedServiceCard extends StatefulWidget {
  final FeaturedServiceModel service;

  const FeaturedServiceCard({super.key, required this.service});

  @override
  State<FeaturedServiceCard> createState() => _FeaturedServiceCardState();
}

class _FeaturedServiceCardState extends State<FeaturedServiceCard> {
  bool _isBooking = false;

  FeaturedServiceModel get service => widget.service;

  @override
  Widget build(BuildContext context) {
    final hasProviderLogo = service.providerLogoUrl.trim().isNotEmpty;
    final hasRating = service.rating > 0 || service.reviewCount > 0;

    return GestureDetector(
      onTap: () => _openPackageDetails(context),
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    color: const Color(0xFFEEF3FB),
                    height: 148,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: service.imageUrl,
                      height: 148,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 148,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 148,
                        child: const Icon(
                          Icons.broken_image,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                  if (hasProviderLogo)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: service.providerLogoUrl,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: const Color(0xFFEEF3FB)),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 16),
                          ),
                        ),
                      ),
                    ),
                  if (hasRating)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
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
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${service.rating} (${service.reviewCount})',
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
              // الفاصل بين الصورة والوصف
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.serviceName,
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.providerName,
                      style: AppTextStyles.of(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            service.location,
                            style: AppTextStyles.of(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'cart.egp_amount'.tr(
                            args: ['${service.originalPrice.toInt()}'],
                          ),
                          style: AppTextStyles.of(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'cart.egp_amount'.tr(
                            args: ['${service.discountedPrice.toInt()}'],
                          ),
                          style: AppTextStyles.of(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3872B1),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            onPressed: () => _bookPackage(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF3872B1),
                              foregroundColor: const Color(0xFFFFFFFF),
                              side: const BorderSide(
                                color: Color(0xFF3872B1),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: Text(
                              'activity.book'.tr(),
                              style: AppTextStyles.of(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
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

  Future<void> _openPackageDetails(BuildContext cardContext) async {
    final packageId = service.packageId;
    if (packageId == null) return;

    showModalBottomSheet<void>(
      context: cardContext,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) => _PackageDetailsSheet(
        packageId: packageId,
        fallback: service,
        onBook: () {
          Navigator.of(sheetContext).pop();
          _bookPackage(cardContext);
        },
      ),
    );
  }

  Future<void> _bookPackage(BuildContext context) async {
    if (_isBooking) return;
    final packageId = service.packageId;
    if (packageId == null) return;

    final token = await sl<AuthSessionStorage>().getAccessToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      showLoginRequiredMessage(context);
      return;
    }

    _isBooking = true;
    try {
      if (!context.mounted) return;
      context.push(
        '/checkout',
        extra: {
          'providerId': service.providerId,
          'providerName': service.providerName,
          if (service.providerBranchId != null)
            'selectedBranch': ProviderBranch(
              branchId: service.providerBranchId!,
              branchName: service.location,
            ),
          'packageId': packageId,
          'packageName': service.serviceName,
          'packagePriceBefore': service.originalPrice,
          'packagePriceAfter': service.discountedPrice,
          'packageServiceNames': const <String>[],
        },
      );
    } finally {
      _isBooking = false;
    }
  }
}

class _PackageDetailsSheet extends StatefulWidget {
  final int packageId;
  final FeaturedServiceModel fallback;
  final VoidCallback onBook;

  const _PackageDetailsSheet({
    required this.packageId,
    required this.fallback,
    required this.onBook,
  });

  @override
  State<_PackageDetailsSheet> createState() => _PackageDetailsSheetState();
}

class _PackageDetailsSheetState extends State<_PackageDetailsSheet> {
  late Future<ApiResult<PackageDetailsResponse>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<ApiResult<PackageDetailsResponse>> _loadDetails() =>
      sl<GetPackageDetailsUseCase>().call(packageId: widget.packageId);

  void _retry() {
    setState(() {
      _detailsFuture = _loadDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult<PackageDetailsResponse>>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState != ConnectionState.done;
        final result = snapshot.data;
        PackageDetailsData? details;
        String? error;
        result?.when(
          success: (response) => details = response.data,
          failure: (message) => error = message,
        );

        final fallback = widget.fallback;
        final originalPrice = fallback.originalPrice;
        final fallbackDiscount = originalPrice > 0
            ? ((originalPrice - fallback.discountedPrice) / originalPrice) * 100
            : 0.0;

        return PackageDetailsSheetView(
          imageUrl: packageImageUrl(details?.image ?? fallback.imageUrl),
          name: details?.name ?? fallback.serviceName,
          description: details?.description ?? fallback.location,
          serviceNames: details?.serviceNames ?? const <String>[],
          priceBefore: details?.priceBefore ?? fallback.originalPrice,
          priceAfter: details?.priceAfter ?? fallback.discountedPrice,
          discount: details?.discountPercentage ?? fallbackDiscount,
          isLoading: isLoading,
          error: error,
          onRetry: _retry,
          onAdd: widget.onBook,
        );
      },
    );
  }
}
