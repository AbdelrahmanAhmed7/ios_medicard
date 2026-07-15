import 'cart_item.dart';
import 'category_counter.dart';

class Cart {
  final List<CartItem> items;
  final int totalCount;
  final List<CategoryCounter> categoryCounters;

  const Cart({
    required this.items,
    required this.totalCount,
    required this.categoryCounters,
  });
}
