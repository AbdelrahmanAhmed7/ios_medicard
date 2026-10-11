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

/// Service card for the uncategorized services list.
///
/// Rebuilds only when this service's own pending/in-cart flags change —
/// sibling cart actions must not rebuild it.
class ProviderServiceCard extends StatelessWidget {
  final ProviderService service;

  const ProviderServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProviderPageCubit, ProviderPageState,
        ({bool pending, bool inCart})>(
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

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: flags.inCart
                  ? const Color(0xFF3872B1).withValues(alpha: 0.4)
                  : const Color(0xFFD1D5DB),
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
                        color: Colors.black,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: [
                        if (service.isSpecialOffer == true)
                          ServiceBadge(
                            label: 'provider_page.special_offer'.tr(),
                            color: const Color(0xFFF97316),
                            backgroundColor: const Color(0xFFFFF4E6),
                            icon: Icons.local_offer_rounded,
                          ),
                        if (service.discountPercentage != null &&
                            service.discountPercentage! > 0)
                          ServiceBadge(
                            label: 'cart.discount_percent'.tr(
                              args: [
                                service.discountPercentage!
                                    .toStringAsFixed(0),
                              ],
                            ),
                            color: const Color(0xFF3872B1),
                            backgroundColor: const Color(0xFFEFF6FF),
                          ),
                      ],
                    ),
                    SizedBox(height: 13.h),
                    Row(
                      children: [
                        if (service.priceBefore != null) ...[
                          Text(
                            '${formatPrice(service.priceBefore)} EGP',
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              color: Colors.black,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        if (service.priceAfter != null)
                          Text(
                            '${formatPrice(service.priceAfter)} EGP',
                            style: AppTextStyles.of(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F6BC1),
                            ),
                          ),
                      ],
                    ),
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
                    color: Color(0xFF3872B1),
                  ),
                )
              else if (flags.inCart && serviceId != null)
                GestureDetector(
                  onTap: () => cubit.removeFromCart(serviceId),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF3872B1),
                    size: 26.sp,
                  ),
                )
              else
                GestureDetector(
                  onTap: serviceId == null
                      ? null
                      : () async {
                          if (await cubit.addToCart(
                                serviceId,
                                categoryId: service.categoryId,
                              ) &&
                              context.mounted) {
                            showLoginRequiredMessage(context);
                          }
                        },
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3872B1),
                        width: 1.4,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Color(0xFF3872B1),
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
