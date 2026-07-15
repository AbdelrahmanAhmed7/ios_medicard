import 'package:json_annotation/json_annotation.dart';

part 'cart_item_dto.g.dart';

@JsonSerializable()
class CartItemDto {
  final int? serviceId;
  final String? serviceName;
  final int? categoryId;
  final String? categoryName;
  final int? providerId;
  final String? providerName;
  final double? priceAfter;
  final double? priceBefore;

  const CartItemDto({
    this.serviceId,
    this.serviceName,
    this.categoryId,
    this.categoryName,
    this.providerId,
    this.providerName,
    this.priceAfter,
    this.priceBefore,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDtoToJson(this);
}
