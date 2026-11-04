// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_cart_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCartRequestDto _$AddCartRequestDtoFromJson(Map<String, dynamic> json) =>
    AddCartRequestDto(
      serviceId: (json['serviceId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      providerId: (json['providerId'] as num?)?.toInt(),
      cardNumber: json['cardNumber'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AddCartRequestDtoToJson(AddCartRequestDto instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'categoryId': instance.categoryId,
      'providerId': ?instance.providerId,
      'cardNumber': ?instance.cardNumber,
      'price': ?instance.price,
      'quantity': ?instance.quantity,
    };
