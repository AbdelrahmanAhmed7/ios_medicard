import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
