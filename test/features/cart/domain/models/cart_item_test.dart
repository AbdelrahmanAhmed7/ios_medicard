import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/cart/data/dto/cart_item_dto.dart';
import 'package:medicard/features/cart/domain/models/cart_item.dart';

void main() {
  group('CartItem pricing', () {
    test('uses the server line total for a medicine quantity', () {
      final dto = CartItemDto.fromJson({
        'priceAfter': 55,
        'quantity': 4,
        'lineTotalAfter': 220,
      });

      final item = CartItem(
        cartItemId: 1,
        serviceId: 1,
        serviceName: 'Medicine',
        categoryId: 1,
        priceAfter: dto.priceAfter,
        lineTotalAfter: dto.lineTotalAfter,
        quantity: dto.quantity!,
      );

      expect(item.totalPriceAfter, 220);
    });

    test('calculates the line total when the API omits it', () {
      const item = CartItem(
        cartItemId: 1,
        serviceId: 1,
        serviceName: 'Medicine',
        categoryId: 1,
        priceAfter: 55,
        quantity: 4,
      );

      expect(item.totalPriceAfter, 220);
    });

    test('recalculates the line total when quantity changes locally', () {
      const item = CartItem(
        cartItemId: 1,
        serviceId: 1,
        serviceName: 'Medicine',
        categoryId: 1,
        priceAfter: 55,
        lineTotalAfter: 220,
        quantity: 4,
      );

      expect(item.copyWith(quantity: 5).totalPriceAfter, 275);
    });
  });
}
