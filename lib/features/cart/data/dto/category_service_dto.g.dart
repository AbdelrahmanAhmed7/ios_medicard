// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryServiceDto _$CategoryServiceDtoFromJson(Map<String, dynamic> json) =>
    CategoryServiceDto(
      serviceId: (json['serviceId'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      isSelected: json['isSelected'] as bool?,
    );

Map<String, dynamic> _$CategoryServiceDtoToJson(CategoryServiceDto instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'isSelected': instance.isSelected,
    };
