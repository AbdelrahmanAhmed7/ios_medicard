// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_counter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryCounterDto _$CategoryCounterDtoFromJson(Map<String, dynamic> json) =>
    CategoryCounterDto(
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryCounterDtoToJson(CategoryCounterDto instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'count': instance.count,
    };
