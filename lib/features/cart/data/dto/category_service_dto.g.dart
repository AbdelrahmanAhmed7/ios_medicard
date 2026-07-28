// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_service_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryServiceDto _$CategoryServiceDtoFromJson(Map<String, dynamic> json) =>
    CategoryServiceDto(
      serviceId: (json['serviceId'] as num?)?.toInt(),
      serviceNameEn:
          json['serviceNameEn'] as String? ?? json['serviceName'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      isSelected: json['isSelected'] as bool?,
    );

Map<String, dynamic> _$CategoryServiceDtoToJson(CategoryServiceDto instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceNameEn': instance.serviceNameEn,
      'serviceNameAr': instance.serviceNameAr,
      'isSelected': instance.isSelected,
    };
