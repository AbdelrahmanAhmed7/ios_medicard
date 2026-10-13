// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartDto _$CartDtoFromJson(Map<String, dynamic> json) => CartDto(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CartDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CartDtoToJson(CartDto instance) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

CartDataDto _$CartDataDtoFromJson(Map<String, dynamic> json) => CartDataDto(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CartItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  categoryCounters: (json['categoryCounters'] as List<dynamic>?)
      ?.map((e) => CategoryCounterDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CartDataDtoToJson(CartDataDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'categoryCounters': instance.categoryCounters,
    };
