import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_session_storage.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../medicard_network/domain/usecases/get_package_details_usecase.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/featured_service_model.dart';

import '../../../../core/theming/app_text_styles.dart';

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
          borderRadius: BorderRadius.circular(
            15,
          ), // حل مشكلة تسريب اللون الأبيض عند الحواف
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    color: const Color(0xFFEEF3FB),
                    height: 159,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: service.imageUrl,
                      height: 159,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 159,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFEEF3FB),
                        height: 159,
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.serviceName,
                      style: AppTextStyles.of(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.providerName,
                      style: AppTextStyles.of(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            service.location,
                            style: AppTextStyles.of(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${service.originalPrice.toInt()} EGP',
                          style: AppTextStyles.of(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${service.discountedPrice.toInt()} EGP',
                          style: AppTextStyles.of(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3872B1),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            onPressed: () => _bookPackage(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF3872B1),
                              foregroundColor: const Color(0xFF3872B1),
                              side: const BorderSide(
                                color: Color(0xFF3872B1),
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: Text(
                              'activity.book'.tr(),
                              style: AppTextStyles.of(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
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
      backgroundColor: Colors.transparent,
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
          if (service.providerBranchId != null)
            'selectedBranch': ProviderBranch(
              branchId: service.providerBranchId!,
              branchName: service.location,
            ),
          'packageId': packageId,
          'packageName': service.serviceName,
          'packagePriceBefore': service.originalPrice,
          'packagePriceAfter': service.discountedPrice,
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
  late final Future<ApiResult<PackageDetailsResponse>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = sl<GetPackageDetailsUseCase>().call(
      packageId: widget.packageId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResult<PackageDetailsResponse>>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState != ConnectionState.done;
        final result = snapshot.data;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              : result == null
              ? const SizedBox.shrink()
              : result.when(
                  success: (response) => _PackageDetailsSheetContent(
                    details: response.data,
                    fallback: widget.fallback,
                    onBook: widget.onBook,
                  ),
                  failure: (error) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error),
                  ),
                ),
        );
      },
    );
  }
}

class _PackageDetailsSheetContent extends StatelessWidget {
  final PackageDetailsData? details;
  final FeaturedServiceModel fallback;
  final VoidCallback onBook;

  const _PackageDetailsSheetContent({
    required this.details,
    required this.fallback,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final image = _imageUrl(details?.image ?? fallback.imageUrl);
    final name = details?.name ?? fallback.serviceName;
    final description = details?.description ?? fallback.location;
    final serviceNames = details?.serviceNames ?? const <String>[];
    final priceBefore = details?.priceBefore ?? fallback.originalPrice;
    final priceAfter = details?.priceAfter ?? fallback.discountedPrice;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 18;

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        Container(
          color: const Color(0xFFEEF3FB),
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => SizedBox(
              height: 180,
              width: double.infinity,
              child: const Icon(Icons.broken_image, color: Color(0xFF9CA3AF)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.of(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppTextStyles.of(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              if (serviceNames.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'provider_page.tests_included'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  serviceNames.length,
                  (index) => Text(
                    '${index + 1}-${serviceNames[index]}',
                    style: AppTextStyles.of(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    'cart.total_amount'.tr(),
                    style: AppTextStyles.of(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'cart.egp_amount'.tr(args: ['${priceBefore.toInt()}']),
                    style: AppTextStyles.of(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'cart.egp_amount'.tr(args: ['${priceAfter.toInt()}']),
                    style: AppTextStyles.of(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3872B1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3872B1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('activity.book'.tr()),
                ),
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ],
    );
  }

  String _imageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith('http')) return trimmed;
    final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (normalized.startsWith('uploads/')) {
      return 'https://medicard-api-v2.medicardeg.com/$normalized';
    }
    return 'https://medicard-api-v2.medicardeg.com/uploads/providers/$normalized';
  }
}
