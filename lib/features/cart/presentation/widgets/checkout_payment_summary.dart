import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../cubit/cart_state.dart';
import 'checkout_summary_row.dart';

class CheckoutPaymentSummary extends StatelessWidget {
  final CartState state;

  const CheckoutPaymentSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final provider = state.checkoutProvider;
    final isPackageCheckout = state.checkoutPackageId != null;
    final subtotal = isPackageCheckout
        ? state.checkoutPackagePriceBefore ??
              state.checkoutPackagePriceAfter ??
              0
        : provider?.totalPriceBefore ?? 0.0;
    final total = isPackageCheckout
        ? state.checkoutPackagePriceAfter ??
              state.checkoutPackagePriceBefore ??
              0
        : provider?.totalPriceAfter ?? 0.0;
    final discount = math.max<double>(0.0, subtotal - total);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E9F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CheckoutSummaryRow(
            label: 'cart.provider'.tr(),
            value: provider?.providerName ?? '-',
          ),
          if (isPackageCheckout)
            CheckoutSummaryRow(
              label: 'cart.package'.tr(),
              value: state.checkoutPackageName ?? '-',
            ),
          if (!isPackageCheckout &&
              provider != null &&
              provider.coveredServices.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Divider(height: 18.h, color: const Color(0xFFEEF1F5)),
            ),
            ...provider.coveredServices.map(
              (service) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                child: Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3872B1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: AppTextStyles.of(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'cart.egp_amount'.tr(
                        args: [
                          checkoutMoney(
                            service.priceAfter ?? service.priceBefore ?? 0,
                          ),
                        ],
                      ),
                      style: AppTextStyles.of(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(height: 18.h, color: const Color(0xFFEEF1F5)),
          ),
          CheckoutSummaryRow(
            label: 'cart.subtotal'.tr(),
            value: 'cart.egp_amount'.tr(args: [checkoutMoney(subtotal)]),
          ),
          if (discount > 0)
            CheckoutSummaryRow(
              label: 'cart.discount'.tr(),
              value:
                  'cart.negative_egp_amount'.tr(args: [checkoutMoney(discount)]),
              valueColor: const Color(0xFF059669),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(height: 18.h, color: const Color(0xFFEEF1F5)),
          ),
          CheckoutSummaryRow(
            label: 'cart.total_amount'.tr(),
            value: 'cart.egp_amount'.tr(args: [checkoutMoney(total)]),
            isBold: true,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
