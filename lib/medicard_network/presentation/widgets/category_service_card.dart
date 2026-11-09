import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/theming/app_toast.dart';
import '../../../network/data/provider_services_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_shared_widgets.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Service card for the category-tab services list.
///
/// The item keeps the original dynamic access: the static model does not
/// declare `isSpecialOffer`, so behavior is preserved exactly as before.
/// Rebuilds only when this service's own pending/in-cart flags change.
class CategoryServiceCard extends StatelessWidget {
  final dynamic service;

  /// Category that owns [service]; forwarded to add-to-cart since the
  /// services-by-category payload carries no category id itself.
  final int? categoryId;

  const CategoryServiceCard({
    super.key,
    required this.service,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    // servicesByCategory items are ProviderService (uses `id`); legacy
    // dynamic items use `serviceId`. A `??` fallback can't be used here
    // because a missing getter on dynamic throws instead of yielding null.
    final dynamic raw = service;
    final int? serviceId = raw is ProviderService
        ? raw.id
        : (raw.serviceId as int? ?? raw.id as int?);
    if (serviceId == null) return const SizedBox.shrink();
    return BlocSelector<
      ProviderPageCubit,
      ProviderPageState,
      ({bool pending, bool inCart})
    >(
      selector: (state) => (
        pending: state.pendingCartActionIds.contains(serviceId),
        inCart: state.isServiceInCart(serviceId),
      ),
      builder: (context, flags) {
        final cubit = context.read<ProviderPageCubit>();
        final serviceName = service.serviceName as String? ?? '';
        final isSpecialOffer = service.isSpecialOffer == true;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteClr,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSpecialOffer
                  ? AppColors.exactFFDC2626.withValues(alpha: 0.45)
                  : flags.inCart
                  ? AppColors.brandBlueClr.withValues(alpha: 0.4)
                  : AppColors.lineClr,
            ),
          ),
          child: Row(
            children: [
              // ── Service info ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: AppTextStyles.of(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.exactFF0F172A,
                      ),
                    ),
                    if (((service as dynamic).instruction as String?)
                            ?.trim()
                            .isNotEmpty ==
                        true) ...[
                      SizedBox(height: 4.h),
                      Text(
                        (service as dynamic).instruction as String,
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          color: AppColors.exactFF6B7280,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isSpecialOffer) ...[
                      SizedBox(height: 6.h),
                      ServiceBadge(
                        label: 'provider_page.special_offer'.tr(),
                        color: AppColors.exactFFDC2626,
                        backgroundColor: AppColors.exactFFFEF2F2,
                        icon: Icons.local_offer_rounded,
                      ),
                    ],
                    if (_hasPrice(service)) ...[
                      SizedBox(height: 10.h),
                      _ServicePrice(service: service),
                    ],
                  ],
                ),
              ),
              // ── Action button ────────────────────────────────────────────
              if (flags.pending)
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandBlueClr,
                  ),
                )
              else
                CartActionButton(
                  inCart: flags.inCart,
                  onPressed: () async {
                    if (flags.inCart) {
                      cubit.removeFromCart(serviceId);
                      return;
                    }
                    if (await cubit.addToCart(
                          serviceId,
                          categoryId: categoryId,
                        ) &&
                        context.mounted) {
                      showLoginRequiredMessage(context);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

bool _hasPrice(dynamic service) =>
    (service as dynamic).priceBefore != null ||
    (service as dynamic).priceAfter != null;

/// Price row: before (struck) + after, hidden when the backend sent none.
class _ServicePrice extends StatelessWidget {
  final dynamic service;

  const _ServicePrice({required this.service});

  @override
  Widget build(BuildContext context) {
    final before = (service as dynamic).priceBefore as num?;
    final after = (service as dynamic).priceAfter as num?;
    if (before == null && after == null) return const SizedBox.shrink();
    final hasValidBefore =
        before != null && before > (after ?? 0) && before > 0;
    return Row(
      children: [
        if (hasValidBefore)
          Text(
            formatPrice(before, showFreeWhenZero: false),
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: AppColors.inkFaintClr,
              decoration: after != null ? TextDecoration.lineThrough : null,
            ),
          ),
        if (hasValidBefore && after != null) SizedBox(width: 6.w),
        if (after != null)
          Text(
            formatPrice(after),
            style: AppTextStyles.of(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.brandBlueClr,
            ),
          ),
      ],
    );
  }
}

