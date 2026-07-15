// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choose_providers_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChooseProvidersDto _$ChooseProvidersDtoFromJson(
  Map<String, dynamic> json,
) => ChooseProvidersDto(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ChooseProvidersDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChooseProvidersDtoToJson(ChooseProvidersDto instance) =>
    <String, dynamic>{
      'httpStatusCode': instance.httpStatusCode,
      'errors': instance.errors,
      'succeeded': instance.succeeded,
      'message': instance.message,
      'data': instance.data,
    };

ChooseProvidersDataDto _$ChooseProvidersDataDtoFromJson(
  Map<String, dynamic> json,
) => ChooseProvidersDataDto(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProviderOptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChooseProvidersDataDtoToJson(
  ChooseProvidersDataDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

ProviderOptionDto _$ProviderOptionDtoFromJson(Map<String, dynamic> json) =>
    ProviderOptionDto(
      providerId: (json['providerId'] as num?)?.toInt(),
      providerName: json['providerName'] as String?,
      providerImageUrl: json['providerImageUrl'] as String?,
      coveredCount: (json['coveredCount'] as num?)?.toInt(),
      uncoveredCount: (json['uncoveredCount'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPriceBefore: (json['totalPriceBefore'] as num?)?.toDouble(),
      totalPriceAfter: (json['totalPriceAfter'] as num?)?.toDouble(),
      coveredServices: (json['coveredServices'] as List<dynamic>?)
          ?.map(
            (e) =>
                ProviderCoveredServiceDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      uncoveredServices: (json['uncoveredServices'] as List<dynamic>?)
          ?.map(
            (e) =>
                ProviderCoveredServiceDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$ProviderOptionDtoToJson(ProviderOptionDto instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'providerImageUrl': instance.providerImageUrl,
      'coveredCount': instance.coveredCount,
      'uncoveredCount': instance.uncoveredCount,
      'totalCount': instance.totalCount,
      'totalPriceBefore': instance.totalPriceBefore,
      'totalPriceAfter': instance.totalPriceAfter,
      'coveredServices': instance.coveredServices,
      'uncoveredServices': instance.uncoveredServices,
    };

ProviderCoveredServiceDto _$ProviderCoveredServiceDtoFromJson(
  Map<String, dynamic> json,
) => ProviderCoveredServiceDto(
  cartItemId: (json['cartItemId'] as num?)?.toInt(),
  serviceId: (json['serviceId'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  priceBefore: (json['priceBefore'] as num?)?.toDouble(),
  priceAfter: (json['priceAfter'] as num?)?.toDouble(),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProviderCoveredServiceDtoToJson(
  ProviderCoveredServiceDto instance,
) => <String, dynamic>{
  'cartItemId': instance.cartItemId,
  'serviceId': instance.serviceId,
  'serviceName': instance.serviceName,
  'priceBefore': instance.priceBefore,
  'priceAfter': instance.priceAfter,
  'discountPercentage': instance.discountPercentage,
};
