class CartItem {
  final int cartItemId;
  final int serviceId;
  final String serviceName;
  final int categoryId;
  final String categoryName;
  final int? providerId;
  final String? providerName;
  final double? priceAfter;
  final double? priceBefore;
  final double? discountPercentage;

  const CartItem({
    required this.cartItemId,
    required this.serviceId,
    required this.serviceName,
    required this.categoryId,
    this.categoryName = '',
    this.providerId,
    this.providerName,
    this.priceAfter,
    this.priceBefore,
    this.discountPercentage,
  });

  CartItem copyWith({
    int? providerId,
    String? providerName,
    double? priceAfter,
    double? priceBefore,
    double? discountPercentage,
  }) {
    return CartItem(
      cartItemId: cartItemId,
      serviceId: serviceId,
      serviceName: serviceName,
      categoryId: categoryId,
      categoryName: categoryName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      priceAfter: priceAfter ?? this.priceAfter,
      priceBefore: priceBefore ?? this.priceBefore,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}
