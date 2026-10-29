import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_session_storage.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../medicard_network/domain/usecases/get_package_details_usecase.dart';
import '../../../../medicard_network/presentation/widgets/package_details_sheet.dart';
import '../../../../medicard_network/presentation/widgets/provider_shared_widgets.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/featured_service_model.dart';
import 'home_horizontal_card_style.dart';

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

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppSpacing.compactCardMaxTextScale,
      child: GestureDetector(
        onTap: () => _openPackageDetails(context),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      color: HomeHorizontalCardStyle.imageBackground,
                      height: HomeHorizontalCardStyle.imageHeight,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: service.imageUrl,
                        memCacheWidth: 400,
                        memCacheHeight: 300,
                        height: HomeHorizontalCardStyle.imageHeight,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Container(
                          color: HomeHorizontalCardStyle.imageBackground,
                          height: HomeHorizontalCardStyle.imageHeight,
                          width: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: HomeHorizontalCardStyle.imageBackground,
                          height: HomeHorizontalCardStyle.imageHeight,
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
                              memCacheWidth: 100,
                              memCacheHeight: 100,
                              width: 36,
                              height: 36,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Container(
                                color: HomeHorizontalCardStyle.imageBackground,
                              ),
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
                                '${service.rating} (${service.reviewCount})',
                                style: HomeHorizontalCardStyle.ratingText,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // الفاصل بين الصورة والوصف
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
                        Text(
                          service.serviceName,
                          style: HomeHorizontalCardStyle.titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: HomeHorizontalCardStyle.textGap),
                        Text(
                          service.providerName,
                          style: HomeHorizontalCardStyle.supportingText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: HomeHorizontalCardStyle.textGap),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF9CA3AF),
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                service.location,
                                style: HomeHorizontalCardStyle.supportingText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          key: const ValueKey('featured-package-footer'),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (service.originalPrice >
                                    service.discountedPrice &&
                                service.originalPrice > 0) ...[
                              Text(
                                formatPrice(
                                  service.originalPrice,
                                  showFreeWhenZero: false,
                                ),
                                style: HomeHorizontalCardStyle.priceBeforeText,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              formatPrice(service.discountedPrice),
                              style: HomeHorizontalCardStyle.priceAfterText,
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                ),
                                child: Text(
                                  'activity.book'.tr(),
                                  style: HomeHorizontalCardStyle.actionText
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
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
