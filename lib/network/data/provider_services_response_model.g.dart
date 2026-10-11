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
  groups: (json['groups'] as List<dynamic>?)
      ?.map((e) => ProviderServicesGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
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
  'groups': instance.groups?.map((e) => e.toJson()).toList(),
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

ProviderServicesGroup _$ProviderServicesGroupFromJson(
  Map<String, dynamic> json,
) => ProviderServicesGroup(
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String?,
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProviderServicesGroupToJson(
  ProviderServicesGroup instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'services': instance.services?.map((e) => e.toJson()).toList(),
};

ProviderService _$ProviderServiceFromJson(Map<String, dynamic> json) =>
    ProviderService(
      id: (json['id'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      instruction: json['instruction'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      isSpecialOffer: json['isSpecialOffer'] as bool?,
      isSelected: json['isSelected'] as bool?,
      categoryId: (json['categoryId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviderServiceToJson(ProviderService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceName': instance.serviceName,
      'instruction': instance.instruction,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'isSpecialOffer': instance.isSpecialOffer,
      'isSelected': instance.isSelected,
      'categoryId': instance.categoryId,
    };
