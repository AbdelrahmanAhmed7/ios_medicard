import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/utils/price_formatter.dart';

void main() {
  group('PriceFormatter', () {
    test('returns empty string for null', () {
      expect(formatPrice(null), '');
    });

    test('returns FREE for zero price', () {
      expect(formatPrice(0), 'FREE');
      expect(formatPrice(0.0), 'FREE');
      expect(formatPrice('0'), 'FREE');
      expect(formatPrice('0.00'), 'FREE');
      expect(formatPrice(-5), 'FREE');
    });

    test('respects showFreeWhenZero=false', () {
      expect(formatPrice(0, showFreeWhenZero: false), '0 EGP');
      expect(formatPrice(0.0, showFreeWhenZero: false), '0 EGP');
    });

    test('formats positive whole numbers without decimals', () {
      expect(formatPrice(150), '150 EGP');
      expect(formatPrice(150.0), '150 EGP');
      expect(formatPrice('250'), '250 EGP');
    });

    test('formats numbers with fractions', () {
      expect(formatPrice(99.5), '99.50 EGP');
      expect(formatPrice('99.75'), '99.75 EGP');
    });

    test('formatAmount helper behaves as expected', () {
      expect(PriceFormatter.formatAmount(null), '');
      expect(PriceFormatter.formatAmount(0), '0');
      expect(PriceFormatter.formatAmount(100), '100');
      expect(PriceFormatter.formatAmount(100.5), '100.50');
    });
  });
}
