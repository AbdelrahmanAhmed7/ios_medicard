// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_home_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestHomeResponseModel _$GuestHomeResponseModelFromJson(
  Map<String, dynamic> json,
) => GuestHomeResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : GuestHomeDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GuestHomeResponseModelToJson(
  GuestHomeResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

GuestHomeDataModel _$GuestHomeDataModelFromJson(Map<String, dynamic> json) =>
    GuestHomeDataModel(
      sliders: (json['sliders'] as List<dynamic>?)
          ?.map((e) => GuestSlider.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => GuestCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      nearestProviders: (json['nearestProviders'] as List<dynamic>?)
          ?.map((e) => GuestNearestProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      packages: (json['packages'] as List<dynamic>?)
          ?.map((e) => GuestPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GuestHomeDataModelToJson(GuestHomeDataModel instance) =>
    <String, dynamic>{
      'sliders': instance.sliders,
      'categories': instance.categories,
      'nearestProviders': instance.nearestProviders,
      'packages': instance.packages,
    };

GuestSlider _$GuestSliderFromJson(Map<String, dynamic> json) => GuestSlider(
  id: (json['id'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  providerId: (json['providerId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
);

Map<String, dynamic> _$GuestSliderToJson(GuestSlider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
    };

GuestCategory _$GuestCategoryFromJson(Map<String, dynamic> json) =>
    GuestCategory(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$GuestCategoryToJson(GuestCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

GuestNearestProvider _$GuestNearestProviderFromJson(
  Map<String, dynamic> json,
) => GuestNearestProvider(
  providerId: (json['providerId'] as num?)?.toInt(),
  providerBranchId: (json['providerBranchId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
  providerImageUrl: json['providerImageUrl'] as String?,
  branchName: json['branchName'] as String?,
  fullAddress: json['fullAddress'] as String?,
  mapUrl: json['mapUrl'] as String?,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$GuestNearestProviderToJson(
  GuestNearestProvider instance,
) => <String, dynamic>{
  'providerId': instance.providerId,
  'providerBranchId': instance.providerBranchId,
  'providerName': instance.providerName,
  'providerImageUrl': instance.providerImageUrl,
  'branchName': instance.branchName,
  'fullAddress': instance.fullAddress,
  'mapUrl': instance.mapUrl,
  'distanceKm': instance.distanceKm,
};

GuestPackage _$GuestPackageFromJson(Map<String, dynamic> json) => GuestPackage(
  packageId: (json['packageId'] as num?)?.toInt(),
  providerId: (json['providerId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
  name: json['name'] as String?,
  imageUrl: json['imageUrl'] as String?,
  description: json['description'] as String?,
  priceBefore: (json['priceBefore'] as num?)?.toDouble(),
  priceAfter: (json['priceAfter'] as num?)?.toDouble(),
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  servicesCount: (json['servicesCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$GuestPackageToJson(GuestPackage instance) =>
    <String, dynamic>{
      'packageId': instance.packageId,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'servicesCount': instance.servicesCount,
    };
