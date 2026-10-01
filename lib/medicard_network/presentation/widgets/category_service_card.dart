import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/theming/app_toast.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_shared_widgets.dart';

/// Service card for the category-tab services list.
///
/// The item keeps the original dynamic access: the static model does not
/// declare `isSpecialOffer`, so behavior is preserved exactly as before.
/// Rebuilds only when this service's own pending/in-cart flags change.
class CategoryServiceCard extends StatelessWidget {
  final dynamic service;

  const CategoryServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final serviceId = (service as dynamic).serviceId as int;
    return BlocSelector<ProviderPageCubit, ProviderPageState,
        ({bool pending, bool inCart})>(
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSpecialOffer
                  ? const Color(0xFFF97316).withValues(alpha: 0.45)
                  : flags.inCart
                  ? const Color(0xFF3872B1).withValues(alpha: 0.4)
                  : const Color(0xFFE2E8F0),
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
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (isSpecialOffer) ...[
                      SizedBox(height: 6.h),
                      ServiceBadge(
                        label: 'provider_page.special_offer'.tr(),
                        color: const Color(0xFFF97316),
                        backgroundColor: const Color(0xFFFFF4E6),
                        icon: Icons.local_offer_rounded,
                      ),
                    ],
                    if (flags.inCart) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14.sp,
                            color: const Color(0xFF3872B1),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Added to cart',
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              color: const Color(0xFF3872B1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                    color: Color(0xFF3872B1),
                  ),
                )
              else if (flags.inCart)
                GestureDetector(
                  onTap: () => cubit.removeFromCart(serviceId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Remove',
                      style: AppTextStyles.of(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    if (await cubit.addToCart(serviceId) &&
                        context.mounted) {
                      showLoginRequiredMessage(context);
                    }
                  },
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3872B1),
                        width: 1.2,
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
