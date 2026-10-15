import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/theming/app_toast.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import 'provider_shared_widgets.dart';

/// Opens the package details bottom sheet, fetching details on first open.
void openPackageDetailsSheet(
  BuildContext context,
  ProviderPageCubit cubit,
  ProviderPackage packageData,
  ProviderBranch? selectedBranch,
) {
  final packageId = packageData.id;
  if (packageId == null) return;

  if (!cubit.state.packageDetailsById.containsKey(packageId) &&
      !cubit.state.loadingPackageDetailsIds.contains(packageId)) {
    cubit.togglePackageDetails(packageId);
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: _PackageDetailsSheetBody(
          packageData: packageData,
          selectedBranch: selectedBranch,
        ),
      );
    },
  );
}

/// Quick-adds a package: resolves it from the loaded list, then routes
/// through the checkout gate.
Future<void> createPackageInvoice(
  BuildContext context,
  ProviderPageCubit cubit,
  int packageId,
  ProviderBranch? selectedBranch,
) async {
  final packageData = cubit.state.packages
      .where((package) => package.id == packageId)
      .firstOrNull;
  if (packageData == null) return;
  openPackageCheckout(context, cubit, packageData, selectedBranch);
}

/// Login + branch gate before pushing /checkout for a package.
Future<void> openPackageCheckout(
  BuildContext context,
  ProviderPageCubit cubit,
  ProviderPackage packageData,
  ProviderBranch? selectedBranch, {
  PackageDetailsData? details,
}) async {
  final packageId = details?.id ?? packageData.id;
  if (packageId == null) return;

  if (!await cubit.requireAuth()) {
    if (!context.mounted) return;
    showLoginRequiredMessage(context);
    return;
  }
  if (!context.mounted) return;

  var resolvedDetails = details ?? cubit.state.packageDetailsById[packageId];
  var packageProviderId = resolvedDetails?.providerId ?? packageData.providerId;
  if (packageProviderId == null) {
    await cubit.togglePackageDetails(packageId);
    if (!context.mounted) return;
    resolvedDetails = cubit.state.packageDetailsById[packageId];
    packageProviderId = resolvedDetails?.providerId;
  }
  if (packageProviderId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package provider data is missing.')),
    );
    return;
  }

  final isArabic = context.locale.languageCode == 'ar';
  final detailsProviderName = resolvedDetails?.providerName(isArabic) ?? '';
  final packageProviderName = packageData.providerName(isArabic);
  final providerName = detailsProviderName.isNotEmpty
      ? detailsProviderName
      : packageProviderName.isNotEmpty
      ? packageProviderName
      : cubit.state.providerData?.name;

  context.push(
    '/checkout',
    extra: {
      'providerId': packageProviderId,
      'providerName': providerName,
      'selectedBranch': selectedBranch,
      'packageId': packageId,
      'packageName': resolvedDetails?.name ?? packageData.name,
      'packageServiceNames':
          resolvedDetails?.serviceNames ?? packageData.serviceNames ?? const [],
      'packagePriceBefore':
          resolvedDetails?.priceBefore ?? packageData.priceBefore,
      'packagePriceAfter':
          resolvedDetails?.priceAfter ?? packageData.priceAfter,
    },
  );
}

class _PackageDetailsSheetBody extends StatelessWidget {
  final ProviderPackage packageData;
  final ProviderBranch? selectedBranch;

  const _PackageDetailsSheetBody({
    required this.packageData,
    required this.selectedBranch,
  });

  @override
  Widget build(BuildContext context) {
    final packageId = packageData.id;
    if (packageId == null) return const SizedBox.shrink();
    final cubit = context.read<ProviderPageCubit>();

    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      // The sheet only cares about its own package's details slice.
      buildWhen: (previous, current) =>
          ProviderRebuildScopes.isPackageSheetSliceChanged(
            packageId,
            previous,
            current,
          ),
      builder: (context, state) {
        final details = state.packageDetailsById[packageId];
        final isLoading = state.loadingPackageDetailsIds.contains(packageId);
        final error = state.packageDetailsErrors[packageId];
        final imageUrl = packageImageUrl(
          details?.image ?? packageData.imageUrl ?? '',
        );
        final name = details?.name ?? packageData.name ?? '';
        final description =
            details?.description ?? packageData.description ?? '';
        final serviceNames = details?.serviceNames ?? const <String>[];
        final priceBefore = details?.priceBefore ?? packageData.priceBefore;
        final priceAfter = details?.priceAfter ?? packageData.priceAfter;
        final discount =
            details?.discountPercentage ?? packageData.discountPercentage;

        return DraggableScrollableSheet(
          initialChildSize: 0.64,
          minChildSize: 0.42,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 136.h,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const ColoredBox(
                            color: Color(0xFFE2E8F0),
                            child: Center(
                              child: Icon(
                                Icons.local_hospital,
                                color: Color(0xFF3872B1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 9.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 132.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16.w,
                        right: 110.w,
                        bottom: 18.h,
                        child: Text(
                          name,
                          style: AppTextStyles.of(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (discount != null && discount > 0)
                        Positioned(
                          right: 16.w,
                          bottom: 14.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7FFFA),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Save ${discount.toStringAsFixed(0)}%',
                              style: AppTextStyles.of(
                                color: const Color(0xFF16A99A),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                    child: isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : error != null
                        ? Text(
                            error,
                            style: AppTextStyles.of(
                              color: const Color(0xFFEF4444),
                              fontSize: 13.sp,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: AppTextStyles.of(
                                  color: const Color(0xFF4B5563),
                                  fontSize: 14.sp,
                                  height: 1.24,
                                ),
                              ),
                              SizedBox(height: 28.h),
                              Text(
                                'Tests included',
                                style: AppTextStyles.of(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              PackagePlainServiceNames(
                                serviceNames: serviceNames,
                              ),
                              SizedBox(height: 30.h),
                              Row(
                                children: [
                                  Text(
                                    'Total',
                                    style: AppTextStyles.of(
                                      color: const Color(0xFF64748B),
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (priceBefore != null) ...[
                                    Text(
                                      '${formatPrice(priceBefore)} EGP',
                                      style: AppTextStyles.of(
                                        color: Colors.black,
                                        fontSize: 13.sp,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                  ],
                                  if (priceAfter != null)
                                    Text(
                                      '${formatPrice(priceAfter)} EGP',
                                      style: AppTextStyles.of(
                                        color: const Color(0xFF1F6BC1),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                          openPackageCheckout(
                                            context,
                                            cubit,
                                            packageData,
                                            selectedBranch,
                                            details: details,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3872B1),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Add',
                                    style: AppTextStyles.of(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom +
                                    16.h,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
