enum CartOrderKind { services, medicines }

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
  final double? lineTotalAfter;
  final double? lineTotalBefore;
  final double? discountPercentage;
  final int quantity;

  double? get totalPriceAfter =>
      lineTotalAfter ?? (priceAfter == null ? null : priceAfter! * quantity);
  double? get totalPriceBefore =>
      lineTotalBefore ?? (priceBefore == null ? null : priceBefore! * quantity);
  CartOrderKind get orderKind =>
      categoryId == 1 ? CartOrderKind.medicines : CartOrderKind.services;

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
    this.lineTotalAfter,
    this.lineTotalBefore,
    this.discountPercentage,
    this.quantity = 1,
  });

  CartItem copyWith({
    int? providerId,
    String? providerName,
    String? providerImageUrl,
    double? priceAfter,
    double? priceBefore,
    double? lineTotalAfter,
    double? lineTotalBefore,
    double? discountPercentage,
    int? quantity,
  }) {
    final quantityChanged = quantity != null && quantity != this.quantity;
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
      lineTotalAfter:
          lineTotalAfter ?? (quantityChanged ? null : this.lineTotalAfter),
      lineTotalBefore:
          lineTotalBefore ?? (quantityChanged ? null : this.lineTotalBefore),
      discountPercentage: discountPercentage ?? this.discountPercentage,
      quantity: quantity ?? this.quantity,
    );
  }
}
