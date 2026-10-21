class CartItem {
  final int cartItemId;
  final int serviceId;
  final String serviceName;
  final int categoryId;
  final String categoryName;
  final int? providerId;
  final String? providerName;
  final String? providerImageUrl;
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
    this.providerImageUrl,
    this.priceAfter,
    this.priceBefore,
    this.discountPercentage,
  });

  CartItem copyWith({
    int? providerId,
    String? providerName,
    String? providerImageUrl,
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
      providerImageUrl: providerImageUrl ?? this.providerImageUrl,
      priceAfter: priceAfter ?? this.priceAfter,
      priceBefore: priceBefore ?? this.priceBefore,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}
