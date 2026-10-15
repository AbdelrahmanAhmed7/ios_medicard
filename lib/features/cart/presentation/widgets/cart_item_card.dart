import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../domain/models/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_summary_row.dart';

/// Borderless divider-separated row used inside provider group sections.
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool showDivider;

  const CartItemCard({super.key, required this.item, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, bool>(
      // This card re-renders only when its own pending flag flips; all other
      // cart emits leave it untouched.
      selector: (state) => state.pendingServiceIds.contains(item.serviceId),
      builder: (context, isPending) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.serviceName,
                          style: AppTextStyles.of(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 5.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (item.discountPercentage != null)
                              _Tag(
                                label: 'cart.discount_percent'.tr(
                                  args: [
                                    item.discountPercentage!.toStringAsFixed(0),
                                  ],
                                ),
                                bg: const Color(0xFFEFF6FF),
                                fg: const Color(0xFF2563EB),
                              ),
                            if (item.providerName == null)
                              _Tag(
                                label: 'cart.no_provider_selected'.tr(),
                                bg: const Color(0xFFFFFBEB),
                                fg: const Color(0xFFD97706),
                              ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        _PriceLine(item: item),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  if (isPending)
                    SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3872B1),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => context.read<CartCubit>().removeFromCart(
                        serviceId: item.serviceId,
                        categoryId: item.categoryId,
                      ),
                      child: Container(
                        width: 30.r,
                        height: 30.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          size: 16.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: const Divider(height: 1, color: Color(0xFFEEF1F5)),
              ),
          ],
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.of(
          fontSize: 11.sp,
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final CartItem item;

  const _PriceLine({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.priceBefore == null && item.priceAfter == null) {
      return Text(
        'cart.price_unavailable'.tr(),
        style: AppTextStyles.of(
          fontSize: 12.sp,
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.priceBefore != null)
          Text(
            'cart.egp_amount'.tr(args: [checkoutMoney(item.priceBefore!)]),
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: const Color(0xFF94A3B8),
              decoration: item.priceAfter != null
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        if (item.priceBefore != null && item.priceAfter != null)
          SizedBox(width: 6.w),
        if (item.priceAfter != null)
          Text(
            'cart.egp_amount'.tr(args: [checkoutMoney(item.priceAfter!)]),
            style: AppTextStyles.of(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3872B1),
            ),
          ),
      ],
    );
  }
}
