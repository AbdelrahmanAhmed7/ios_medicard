class CartItem {
  final int serviceId;
  final String serviceName;
  final int categoryId;
  final String categoryName;
  final int? providerId;
  final String? providerName;
  final double? priceAfter;
  final double? priceBefore;

  const CartItem({
    required this.serviceId,
    required this.serviceName,
    required this.categoryId,
    this.categoryName = '',
    this.providerId,
    this.providerName,
    this.priceAfter,
    this.priceBefore,
  });
}
