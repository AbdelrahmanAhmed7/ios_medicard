import 'package:easy_localization/easy_localization.dart';

/// Centralized utility for formatting prices and currency across the app.
class PriceFormatter {
  PriceFormatter._();

  /// Formats a numeric price into a clean string without trailing `.00`.
  /// e.g. `150.0` -> `'150'`, `150.5` -> `'150.50'`.
  static String formatAmount(num? price) {
    if (price == null) return '';
    return price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
  }

  /// Parses [raw] into a [num] safely if it is a String or num.
  static num? parseNumber(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw;
    if (raw is String) {
      final clean = raw.trim().replaceAll(',', '');
      return num.tryParse(clean);
    }
    return null;
  }

  /// Formats a price with currency symbol / name, or returns 'FREE' when price <= 0.
  ///
  /// When [showFreeWhenZero] is false (e.g. for strikethrough original prices),
  /// returns the formatted amount with currency instead of 'FREE'.
  static String formatPrice(Object? rawPrice, {bool showFreeWhenZero = true}) {
    final price = parseNumber(rawPrice);
    if (price == null) {
      if (rawPrice != null && rawPrice is String && rawPrice.trim().isNotEmpty) {
        return rawPrice.trim();
      }
      return '';
    }

    if (showFreeWhenZero && price <= 0) {
      return 'FREE';
    }

    final formatted = formatAmount(price);
    final localized = 'cart.egp_amount'.tr(args: [formatted]);
    if (localized == 'cart.egp_amount') {
      return '$formatted EGP';
    }
    return localized;
  }
}

/// Convenience top-level function.
String formatPrice(Object? price, {bool showFreeWhenZero = true}) =>
    PriceFormatter.formatPrice(price, showFreeWhenZero: showFreeWhenZero);

