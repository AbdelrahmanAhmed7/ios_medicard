import 'package:json_annotation/json_annotation.dart';

part 'cart_item_dto.g.dart';

@JsonSerializable()
class CartItemDto {
  final int? cartItemId;
  final int? serviceId;
  final String? serviceName;
  final int? categoryId;
  final String? categoryName;
  final int? providerId;
  final String? providerName;
  final String? providerImageUrl;
  final double? priceAfter;
  final double? priceBefore;
  final double? lineTotalAfter;
  final double? lineTotalBefore;
  final double? discountPercentage;
  final int? quantity;

  const CartItemDto({
    this.cartItemId,
    this.serviceId,
    this.serviceName,
    this.categoryId,
    this.categoryName,
    this.providerId,
    this.providerName,
    this.providerImageUrl,
    this.priceAfter,
    this.priceBefore,
    this.lineTotalAfter,
    this.lineTotalBefore,
    this.discountPercentage,
    this.quantity,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDtoToJson(this);
}
