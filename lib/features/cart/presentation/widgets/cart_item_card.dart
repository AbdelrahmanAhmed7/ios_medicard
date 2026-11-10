import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/models/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

import 'package:medicard/core/theming/app_colors.dart';

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
                            color: AppColors.inkClr,
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
                            if ((item.discountPercentage ?? 0) > 0)
                              _Tag(
                                label: 'cart.discount_percent'.tr(
                                  args: [
                                    item.discountPercentage!.toStringAsFixed(0),
                                  ],
                                ),
                                bg: AppColors.exactFFEFF6FF,
                                fg: AppColors.exactFF2563EB,
                              ),
                            if (item.providerName == null)
                              _Tag(
                                label: 'cart.no_provider_selected'.tr(),
                                bg: AppColors.exactFFFFFBEB,
                                fg: AppColors.exactFFD97706,
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
                        color: AppColors.brandBlueClr,
                      ),
                    )
                  else if (item.categoryId == 1)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: item.quantity <= 1
                              ? Icons.delete_outline_rounded
                              : Icons.remove,
                          onTap: () {
                            final cartCubit = context.read<CartCubit>();
                            if (item.quantity <= 1) {
                              cartCubit.removeFromCart(
                                serviceId: item.serviceId,
                                categoryId: item.categoryId,
                              );
                            } else {
                              cartCubit.updateMedicineQuantity(
                                serviceId: item.serviceId,
                                quantity: item.quantity - 1,
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Text(
                            '${item.quantity}',
                            style: AppTextStyles.of(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add,
                          onTap: () =>
                              context.read<CartCubit>().updateMedicineQuantity(
                                serviceId: item.serviceId,
                                quantity: item.quantity + 1,
                              ),
                        ),
                      ],
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
                          color: AppColors.exactFFFEE2E2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.exactFFDC2626,
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
                child: const Divider(height: 1, color: AppColors.exactFFEEF1F5),
              ),
          ],
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onTap == null
            ? AppColors.exactFFF1F5F9
            : AppColors.exactFFEFF6FF,
        border: Border.all(color: AppColors.brandBlueClr),
      ),
      child: Icon(icon, size: 16.sp, color: AppColors.brandBlueClr),
    ),
  );
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
    final totalPriceBefore = item.totalPriceBefore;
    final totalPriceAfter = item.totalPriceAfter;
    if (totalPriceBefore == null && totalPriceAfter == null) {
      return Text(
        'cart.price_unavailable'.tr(),
        style: AppTextStyles.of(
          fontSize: 12.sp,
          color: AppColors.inkFaintClr,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    final hasValidBefore =
        totalPriceBefore != null &&
        totalPriceBefore > (totalPriceAfter ?? 0) &&
        totalPriceBefore > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasValidBefore)
          Text(
            formatPrice(totalPriceBefore, showFreeWhenZero: false),
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: AppColors.inkFaintClr,
              decoration: totalPriceAfter != null
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        if (hasValidBefore && totalPriceAfter != null) SizedBox(width: 6.w),
        if (totalPriceAfter != null)
          Text(
            formatPrice(totalPriceAfter),
            style: AppTextStyles.of(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.brandBlueClr,
            ),
          ),
      ],
    );
  }
}
