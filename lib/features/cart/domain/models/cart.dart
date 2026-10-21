import 'cart_item.dart';
import 'category_counter.dart';
import 'provider_option.dart';

class Cart {
  final List<CartItem> items;
  final int totalCount;
  final List<CategoryCounter> categoryCounters;

  const Cart({
    required this.items,
    required this.totalCount,
    required this.categoryCounters,
  });

  const Cart.empty()
    : items = const [],
      totalCount = 0,
      categoryCounters = const [];

  Cart removeService(int serviceId) {
    final removedItems = items.where((item) => item.serviceId == serviceId);
    if (removedItems.isEmpty) return this;

    final removedCountByCategory = <int, int>{};
    for (final item in removedItems) {
      removedCountByCategory[item.categoryId] =
          (removedCountByCategory[item.categoryId] ?? 0) + 1;
    }

    final nextItems = items
        .where((item) => item.serviceId != serviceId)
        .toList();
    final nextCounters = categoryCounters
        .map((counter) {
          final removed = removedCountByCategory[counter.categoryId] ?? 0;
          return CategoryCounter(
            categoryId: counter.categoryId,
            categoryName: counter.categoryName,
            count: counter.count - removed,
          );
        })
        .where((counter) => counter.count > 0)
        .toList();

    return Cart(
      items: nextItems,
      totalCount: totalCount - removedItems.length,
      categoryCounters: nextCounters,
    );
  }

  Cart removeProvider(int providerId) {
    final removedItems = items.where((item) => item.providerId == providerId);
    if (removedItems.isEmpty) return this;

    final removedCountByCategory = <int, int>{};
    for (final item in removedItems) {
      removedCountByCategory[item.categoryId] =
          (removedCountByCategory[item.categoryId] ?? 0) + 1;
    }

    final nextItems = items
        .where((item) => item.providerId != providerId)
        .toList(growable: false);
    final nextCounters = categoryCounters
        .map((counter) {
          final removed = removedCountByCategory[counter.categoryId] ?? 0;
          return CategoryCounter(
            categoryId: counter.categoryId,
            categoryName: counter.categoryName,
            count: counter.count - removed,
          );
        })
        .where((counter) => counter.count > 0)
        .toList(growable: false);

    return Cart(
      items: nextItems,
      totalCount: totalCount - removedItems.length,
      categoryCounters: nextCounters,
    );
  }

  Cart assignProvider(ProviderOption provider) {
    final coveredByCartId = {
      for (final service in provider.coveredServices)
        service.cartItemId: service,
    };

    return Cart(
      items: items.map((item) {
        final covered = coveredByCartId[item.cartItemId];
        if (covered == null) return item;

        return item.copyWith(
          providerId: provider.providerId,
          providerName: provider.providerName,
          providerImageUrl: provider.providerImageUrl,
          priceBefore: covered.priceBefore,
          priceAfter: covered.priceAfter,
          discountPercentage: covered.discountPercentage,
        );
      }).toList(),
      totalCount: totalCount,
      categoryCounters: categoryCounters,
    );
  }
}
