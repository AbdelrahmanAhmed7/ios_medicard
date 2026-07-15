/// A single service inside a provider option — covered or uncovered.
class ProviderCoveredService {
  final int cartItemId;
  final int serviceId;
  final String serviceName;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;

  const ProviderCoveredService({
    required this.cartItemId,
    required this.serviceId,
    required this.serviceName,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
  });
}
