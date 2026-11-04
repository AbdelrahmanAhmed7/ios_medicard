import 'provider_covered_service.dart';
import 'cart_item.dart';

/// One provider row in the "choose providers" screen.
class ProviderOption {
  final int providerId;
  final String providerName;
  final String? providerImageUrl;

  /// Number of cart items this provider can cover.
  final int coveredCount;

  /// Number of cart items NOT available at this provider.
  final int uncoveredCount;

  /// Total items in the cart for the selected category.
  final int totalCount;

  final double totalPriceBefore;
  final double totalPriceAfter;

  final List<ProviderCoveredService> coveredServices;
  final List<ProviderCoveredService> uncoveredServices;

  const ProviderOption({
    required this.providerId,
    required this.providerName,
    this.providerImageUrl,
    required this.coveredCount,
    required this.uncoveredCount,
    required this.totalCount,
    required this.totalPriceBefore,
    required this.totalPriceAfter,
    required this.coveredServices,
    required this.uncoveredServices,
  });

  bool get coversAll => uncoveredCount == 0;

  bool get hasMissingPrices => coveredServices.any(
    (service) => service.priceAfter == null && service.priceBefore == null,
  );

  /// Restrict availability and prices to the services being prepared now.
  /// The API may include services already assigned to another order.
  ProviderOption forItems(Iterable<CartItem> items) {
    final requested = items.toList(growable: false);
    if (coveredServices.isEmpty && requested.isNotEmpty) {
      return ProviderOption(
        providerId: providerId,
        providerName: providerName,
        providerImageUrl: providerImageUrl,
        coveredCount: requested.length,
        uncoveredCount: 0,
        totalCount: requested.length,
        totalPriceBefore: totalPriceBefore,
        totalPriceAfter: totalPriceAfter,
        coveredServices: const [],
        uncoveredServices: const [],
      );
    }
    final available = {
      for (final service in coveredServices) service.cartItemId: service,
    };
    final covered = <ProviderCoveredService>[];
    final uncovered = <ProviderCoveredService>[];
    for (final item in requested) {
      final service = available[item.cartItemId];
      if (service != null) {
        covered.add(service);
      } else {
        uncovered.add(
          ProviderCoveredService(
            cartItemId: item.cartItemId,
            serviceId: item.serviceId,
            serviceName: item.serviceName,
          ),
        );
      }
    }
    return ProviderOption(
      providerId: providerId,
      providerName: providerName,
      providerImageUrl: providerImageUrl,
      coveredCount: covered.length,
      uncoveredCount: uncovered.length,
      totalCount: requested.length,
      totalPriceBefore: covered.fold(
        0.0,
        (sum, s) => sum + (s.priceBefore ?? s.priceAfter ?? 0),
      ),
      totalPriceAfter: covered.fold(
        0.0,
        (sum, s) => sum + (s.priceAfter ?? s.priceBefore ?? 0),
      ),
      coveredServices: covered,
      uncoveredServices: uncovered,
    );
  }
}
