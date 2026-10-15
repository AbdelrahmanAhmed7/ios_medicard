import 'dart:math' as math;

import '../cubit/cart_state.dart';

class CheckoutPricing {
  final double subtotal;
  final double total;

  const CheckoutPricing({required this.subtotal, required this.total});

  factory CheckoutPricing.fromState(CartState state) {
    final provider = state.checkoutProvider;
    final isPackageCheckout = state.checkoutPackageId != null;
    final subtotal = isPackageCheckout
        ? state.checkoutPackagePriceBefore ??
              state.checkoutPackagePriceAfter ??
              0
        : provider?.totalPriceBefore ?? 0;
    final total = isPackageCheckout
        ? state.checkoutPackagePriceAfter ??
              state.checkoutPackagePriceBefore ??
              0
        : provider?.totalPriceAfter ?? 0;
    return CheckoutPricing(subtotal: subtotal, total: total);
  }

  double get discount => math.max<double>(0, subtotal - total);

  int get discountPercentage =>
      subtotal <= 0 ? 0 : ((discount / subtotal) * 100).round().clamp(0, 100);
}
