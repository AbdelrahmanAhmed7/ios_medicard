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
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: _PackageDetailsSheetBody(
          pageContext: context,
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
  final BuildContext pageContext;
  final ProviderPackage packageData;
  final ProviderBranch? selectedBranch;

  const _PackageDetailsSheetBody({
    required this.pageContext,
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

        return PackageDetailsSheetView(
          imageUrl: imageUrl,
          name: name,
          description: description,
          serviceNames: serviceNames,
          priceBefore: priceBefore,
          priceAfter: priceAfter,
          discount: discount,
          isLoading: isLoading,
          error: error,
          onRetry: () => cubit.togglePackageDetails(packageId),
          onAdd: () {
            Navigator.of(context).pop();
            if (!pageContext.mounted) return;
            openPackageCheckout(
              pageContext,
              cubit,
              packageData,
              selectedBranch,
              details: details,
            );
          },
        );
      },
    );
  }
}

/// Shared package-details presentation used by provider, View All, and Home.
class PackageDetailsSheetView extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final List<String> serviceNames;
  final double? priceBefore;
  final double? priceAfter;
  final double? discount;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onAdd;

  const PackageDetailsSheetView({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.serviceNames,
    required this.priceBefore,
    required this.priceAfter,
    required this.discount,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.76,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      snap: true,
      snapSizes: const [0.76, 0.94],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 20.h),
                  children: [
                    _PackageImage(imageUrl: imageUrl, discount: discount),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                        child: Text(
                          'cart.package'.tr(),
                          style: AppTextStyles.of(
                            color: const Color(0xFF2563EB),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      name,
                      style: AppTextStyles.of(
                        color: const Color(0xFF111827),
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      SizedBox(height: 7.h),
                      Text(
                        description.trim(),
                        style: AppTextStyles.of(
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3872B1),
                          ),
                        ),
                      )
                    else if (error != null)
                      _PackageDetailsError(message: error!, onRetry: onRetry)
                    else ...[
                      Row(
                        children: [
                          Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fact_check_outlined,
                              color: const Color(0xFF3872B1),
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Text(
                            'provider_page.tests_included'.tr(),
                            style: AppTextStyles.of(
                              color: const Color(0xFF111827),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (serviceNames.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${serviceNames.length}',
                                style: AppTextStyles.of(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: PackagePlainServiceNames(
                          serviceNames: serviceNames,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _PackageCheckoutBar(
                priceBefore: priceBefore,
                priceAfter: priceAfter,
                isLoading: isLoading,
                onAdd: onAdd,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 9.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          SizedBox(height: 7.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'provider_page.package_details'.tr(),
                  style: AppTextStyles.of(
                    color: const Color(0xFF0F172A),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 38.r, height: 38.r),
                onPressed: onClose,
                icon: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF334155),
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageImage extends StatelessWidget {
  final String imageUrl;
  final double? discount;

  const _PackageImage({required this.imageUrl, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => ColoredBox(
                color: const Color(0xFFF1F5F9),
                child: Center(
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: const Color(0xFF3872B1),
                    size: 38.sp,
                  ),
                ),
              ),
            ),
          ),
          if (discount != null && discount! > 0)
            PositionedDirectional(
              top: 10.h,
              end: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  'cart.discount_percent'.tr(
                    args: [discount!.toStringAsFixed(0)],
                  ),
                  style: AppTextStyles.of(
                    color: const Color(0xFF047857),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PackageDetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PackageDetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFDC2626),
            size: 21.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.of(
                color: const Color(0xFF991B1B),
                fontSize: 12.5.sp,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _PackageCheckoutBar extends StatelessWidget {
  final double? priceBefore;
  final double? priceAfter;
  final bool isLoading;
  final VoidCallback onAdd;

  const _PackageCheckoutBar({
    required this.priceBefore,
    required this.priceAfter,
    required this.isLoading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'cart.total_amount'.tr(),
                      style: AppTextStyles.of(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        if (priceAfter != null)
                          Flexible(
                            child: Text(
                              'cart.egp_amount'.tr(
                                args: [formatPrice(priceAfter)],
                              ),
                              style: AppTextStyles.of(
                                color: const Color(0xFF1F6BC1),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (priceBefore != null && priceAfter != null) ...[
                          SizedBox(width: 7.w),
                          Flexible(
                            child: Text(
                              'cart.egp_amount'.tr(
                                args: [formatPrice(priceBefore)],
                              ),
                              style: AppTextStyles.of(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11.sp,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else if (priceAfter == null && priceBefore != null)
                          Flexible(
                            child: Text(
                              'cart.egp_amount'.tr(
                                args: [formatPrice(priceBefore)],
                              ),
                              style: AppTextStyles.of(
                                color: const Color(0xFF1F6BC1),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 132.w,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3872B1),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                  icon: isLoading
                      ? SizedBox(
                          width: 17.r,
                          height: 17.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.add_rounded, size: 19.sp),
                  label: Text(
                    'common.add'.tr(),
                    style: AppTextStyles.of(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
