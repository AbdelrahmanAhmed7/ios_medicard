import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../medicard_network/repository/medicard_network_repository.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/featured_service_model.dart';

class FeaturedServiceCard extends StatelessWidget {
  final FeaturedServiceModel service;

  const FeaturedServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final hasProviderLogo = service.providerLogoUrl.trim().isNotEmpty;
    final hasRating = service.rating > 0 || service.reviewCount > 0;

    return GestureDetector(
      onTap: () => _openPackageDetails(context),
      child: Container(
        width: 280,
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
                  CachedNetworkImage(
                    imageUrl: service.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFEEF3FB),
                      height: 120,
                      width: double.infinity,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFEEF3FB),
                      height: 120,
                      child: const Icon(
                        Icons.broken_image,
                        color: Color(0xFF9CA3AF),
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
                              style: const TextStyle(
                                fontFamily: 'Inter',
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
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
                            style: const TextStyle(
                              fontFamily: 'Inter',
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
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${service.discountedPrice.toInt()} EGP',
                          style: const TextStyle(
                            fontFamily: 'Inter',
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
                            child: const Text(
                              'Book',
                              style: TextStyle(
                                fontFamily: 'Inter',
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

  Future<void> _openPackageDetails(BuildContext context) async {
    final packageId = service.packageId;
    if (packageId == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<ApiResult<PackageDetailsResponse>>(
          future: sl<MedicardNetworkRepository>().getPackageDetails(
            packageId: packageId,
          ),
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
                        fallback: service,
                        onBook: () => _bookPackage(context),
                      ),
                      failure: (error) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(error),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Future<void> _bookPackage(BuildContext context) async {
    final packageId = service.packageId;
    if (packageId == null) return;

    final branchId = await _resolveBranchId();
    if (!context.mounted) return;
    if (branchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('provider_page.no_provider_branch_found'.tr())),
      );
      return;
    }

    context.push(
      '/checkout',
      extra: {
        'providerId': service.providerId,
        'selectedBranch': ProviderBranch(
          branchId: branchId,
          branchName: service.location,
        ),
        'packageId': packageId,
        'packageName': service.serviceName,
        'packagePriceBefore': service.originalPrice,
        'packagePriceAfter': service.discountedPrice,
      },
    );
  }

  Future<int?> _resolveBranchId() async {
    if (service.providerBranchId != null) return service.providerBranchId;
    final providerId = service.providerId;
    if (providerId == null) return null;

    final result = await sl<MedicardNetworkRepository>().getProviderPage(
      providerId: providerId,
    );
    return result.maybeWhen(
      success: (response) => response.data?.branches?.firstOrNull?.branchId,
      orElse: () => null,
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
        CachedNetworkImage(
          imageUrl: image,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => Container(
            height: 160,
            color: const Color(0xFFEEF3FB),
            child: const Icon(Icons.broken_image),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              if (serviceNames.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'provider_page.tests_included'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  serviceNames.length,
                  (index) => Text(
                    '${index + 1}-${serviceNames[index]}',
                    style: const TextStyle(
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'cart.egp_amount'.tr(args: ['${priceBefore.toInt()}']),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'cart.egp_amount'.tr(args: ['${priceAfter.toInt()}']),
                    style: const TextStyle(
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
