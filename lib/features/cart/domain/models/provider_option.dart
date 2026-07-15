import 'provider_covered_service.dart';

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
}
