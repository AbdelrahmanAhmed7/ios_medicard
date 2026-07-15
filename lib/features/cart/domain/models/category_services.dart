import 'category_service.dart';

class CategoryServices {
  final List<CategoryService> items;

  /// Number of services in this category that are already in the cart.
  /// Sourced from `data.totalSelectedCount` in the API response.
  final int totalSelectedCount;

  const CategoryServices({required this.items, this.totalSelectedCount = 0});
}
