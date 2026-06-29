// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_services_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderServicesResponse _$ProviderServicesResponseFromJson(
  Map<String, dynamic> json,
) => ProviderServicesResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProviderServicesData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderServicesResponseToJson(
  ProviderServicesResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderServicesData _$ProviderServicesDataFromJson(
  Map<String, dynamic> json,
) => ProviderServicesData(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProviderServicesDataToJson(
  ProviderServicesData instance,
) => <String, dynamic>{
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

ProviderService _$ProviderServiceFromJson(Map<String, dynamic> json) =>
    ProviderService(
      id: (json['id'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      isSpecialOffer: json['isSpecialOffer'] as bool?,
    );

Map<String, dynamic> _$ProviderServiceToJson(ProviderService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'isSpecialOffer': instance.isSpecialOffer,
    };
