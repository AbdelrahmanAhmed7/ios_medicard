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
/// Service card for the uncategorized services list.
///
/// Rebuilds only when this service's own pending/in-cart flags change —
/// sibling cart actions must not rebuild it.
class ProviderServiceCard extends StatelessWidget {
  final ProviderService service;

  const ProviderServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ProviderPageCubit,
      ProviderPageState,
      ({bool pending, bool inCart})
    >(
      selector: (state) {
        final id = service.id;
        return (
          pending: id != null && state.pendingCartActionIds.contains(id),
          inCart: id != null && state.isServiceInCart(id),
        );
      },
      builder: (context, flags) {
        final cubit = context.read<ProviderPageCubit>();
        final serviceId = service.id;
        final instruction = service.instruction?.trim() ?? '';
        final hasSpecialOffer = service.isSpecialOffer == true;
        final hasDiscount =
            service.discountPercentage != null &&
            service.discountPercentage! > 0;
        final hasPrice =
            service.priceBefore != null || service.priceAfter != null;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.whiteClr,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: flags.inCart
                  ? AppColors.brandBlueClr.withValues(alpha: 0.4)
                  : AppColors.exactFFE5E9F0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName ?? '',
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.materialBlack,
                        height: 1.35,
                      ),
                    ),
                    if (instruction.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        instruction,
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          color: AppColors.exactFF6B7280,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (hasSpecialOffer || hasDiscount) ...[
                      SizedBox(height: 7.h),
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          if (hasSpecialOffer)
                            ServiceBadge(
                              label: 'provider_page.special_offer'.tr(),
                              color: AppColors.exactFFDC2626,
                              backgroundColor: AppColors.exactFFFEF2F2,
                              icon: Icons.local_offer_rounded,
                            ),
                          if (hasDiscount)
                            ServiceBadge(
                              label: 'cart.discount_percent'.tr(
                                args: [
                                  service.discountPercentage!.toStringAsFixed(
                                    0,
                                  ),
                                ],
                              ),
                              color: AppColors.brandBlueClr,
                              backgroundColor: AppColors.exactFFEFF6FF,
                            ),
                        ],
                      ),
                    ],
                    if (hasPrice) ...[
                      SizedBox(height: 13.h),
                      Row(
                        children: [
                          if (service.priceBefore != null &&
                              service.priceBefore! >
                                  (service.priceAfter ?? 0) &&
                              service.priceBefore! > 0) ...[
                            Text(
                              formatPrice(
                                service.priceBefore,
                                showFreeWhenZero: false,
                              ),
                              style: AppTextStyles.of(
                                fontSize: 12.sp,
                                color: AppColors.inkFaintClr,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 12.w),
                          ],
                          if (service.priceAfter != null)
                            Text(
                              formatPrice(service.priceAfter),
                              style: AppTextStyles.of(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.exactFF1F6BC1,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              if (flags.pending)
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandBlueClr,
                  ),
                )
              else
                CartActionButton(
                  inCart: flags.inCart,
                  onPressed: () async {
                    if (serviceId == null) return;
                    if (flags.inCart) {
                      cubit.removeFromCart(serviceId);
                      return;
                    }
                    if (await cubit.addToCart(
                          serviceId,
                          categoryId: service.categoryId,
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

