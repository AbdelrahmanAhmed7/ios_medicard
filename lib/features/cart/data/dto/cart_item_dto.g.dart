// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemDto _$CartItemDtoFromJson(Map<String, dynamic> json) => CartItemDto(
  cartItemId: (json['cartItemId'] as num?)?.toInt(),
  serviceId: (json['serviceId'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String?,
  providerId: (json['providerId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
  priceAfter: (json['priceAfter'] as num?)?.toDouble(),
  priceBefore: (json['priceBefore'] as num?)?.toDouble(),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CartItemDtoToJson(CartItemDto instance) =>
    <String, dynamic>{
      'cartItemId': instance.cartItemId,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'priceAfter': instance.priceAfter,
      'priceBefore': instance.priceBefore,
      'discountPercentage': instance.discountPercentage,
    };
