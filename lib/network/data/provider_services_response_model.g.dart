// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_services_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderServicesResponse _$ProviderServicesResponseFromJson(
  Map<String, dynamic> json,
) => ProviderServicesResponse(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : ProviderServicesData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderServicesResponseToJson(
  ProviderServicesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderServicesData _$ProviderServicesDataFromJson(
  Map<String, dynamic> json,
) => ProviderServicesData(
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderServicesDataToJson(
  ProviderServicesData instance,
) => <String, dynamic>{
  'services': instance.services?.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination?.toJson(),
};

ProviderService _$ProviderServiceFromJson(Map<String, dynamic> json) =>
    ProviderService(
      serviceId: (json['serviceId'] as num).toInt(),
      serviceName: json['serviceName'] as String,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      hasSpecialOffer: json['hasSpecialOffer'] as bool?,
    );

Map<String, dynamic> _$ProviderServiceToJson(ProviderService instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'hasSpecialOffer': instance.hasSpecialOffer,
    };
