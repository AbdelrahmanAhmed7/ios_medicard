// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderPageResponse _$ProviderPageResponseFromJson(
  Map<String, dynamic> json,
) => ProviderPageResponse(
  success: json['success'] as bool,
  timestamp: json['timestamp'] as String,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : ProviderPageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderPageResponseToJson(
  ProviderPageResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'timestamp': instance.timestamp,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderPageData _$ProviderPageDataFromJson(Map<String, dynamic> json) =>
    ProviderPageData(
      providerId: (json['providerId'] as num).toInt(),
      providerName: json['providerName'] as String,
      providerLogo: json['providerLogo'] as String,
      categoryName: json['categoryName'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
      phones: (json['phones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      branches: (json['branches'] as List<dynamic>?)
          ?.map((e) => ProviderBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
      servicesCount: (json['servicesCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviderPageDataToJson(ProviderPageData instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'providerLogo': instance.providerLogo,
      'categoryName': instance.categoryName,
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'phones': instance.phones,
      'branches': instance.branches?.map((e) => e.toJson()).toList(),
      'servicesCount': instance.servicesCount,
    };

ProviderBranch _$ProviderBranchFromJson(Map<String, dynamic> json) =>
    ProviderBranch(
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      phone: json['phone'] as String?,
      fullAddress: json['fullAddress'] as String?,
      mapsUrl: json['mapsUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProviderBranchToJson(ProviderBranch instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'phone': instance.phone,
      'fullAddress': instance.fullAddress,
      'mapsUrl': instance.mapsUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
