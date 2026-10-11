import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../domain/models/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, bool>(
      // This card re-renders only when its own pending flag flips; all other
      // cart emits leave it untouched.
      selector: (state) => state.pendingServiceIds.contains(item.serviceId),
      builder: (context, isPending) {

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE5E9F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Remove Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.serviceName,
                      style: AppTextStyles.of(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // ليتناسب مع الصورة
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (isPending)
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
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
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          size: 17.sp,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Bottom Row: Tags (Provider/Category/Discount) & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tags Row
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Yellowish Tag (Used for Provider Name or Category to match UI)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB), // لون أصفر فاتح
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(
                                0xFFFBBF24,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.providerName != null
                                    ? Icons.storefront_outlined
                                    : Icons.warning_amber_rounded,
                                size: 12.sp,
                                color: const Color(0xFFD97706),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.providerName ??
                                    'cart.no_provider_selected'.tr(),
                                style: AppTextStyles.of(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFD97706),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Discount Tag (Blue)
                        if (item.discountPercentage != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(
                                  0xFF3872B1,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'cart.discount_percent'.tr(
                                args: [
                                  item.discountPercentage!.toStringAsFixed(0),
                                ],
                              ),
                              style: AppTextStyles.of(
                                color: const Color(0xFF3872B1),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price Section
                  if (item.priceBefore != null || item.priceAfter != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.priceBefore != null)
                          Text(
                            'cart.egp_amount'.tr(
                              args: [item.priceBefore!.toStringAsFixed(0)],
                            ),
                            style: AppTextStyles.of(
                              fontSize: 11.sp,
                              color: Colors.black, // نفس اللون في الصورة
                              decoration: item.priceAfter != null
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        if (item.priceBefore != null && item.priceAfter != null)
                          SizedBox(width: 6.w),
                        if (item.priceAfter != null)
                          Text(
                            'cart.egp_amount'.tr(
                              args: [item.priceAfter!.toStringAsFixed(0)],
                            ),
                            style: AppTextStyles.of(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(
                                0xFF3872B1,
                              ), // الأزرق في الصورة
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      'cart.price_unavailable'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
