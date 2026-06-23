// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeResponseModel _$HomeResponseModelFromJson(Map<String, dynamic> json) =>
    HomeResponseModel(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : HomeDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeResponseModelToJson(HomeResponseModel instance) =>
    <String, dynamic>{
      'httpStatusCode': instance.httpStatusCode,
      'errors': instance.errors,
      'succeeded': instance.succeeded,
      'message': instance.message,
      'data': instance.data,
    };

HomeDataModel _$HomeDataModelFromJson(Map<String, dynamic> json) =>
    HomeDataModel(
      sliders: (json['sliders'] as List<dynamic>?)
          ?.map((e) => HomeSlider.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingAppointments: (json['pendingAppointments'] as List<dynamic>?)
          ?.map(
            (e) => HomePendingAppointment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      nearestProviders: (json['nearestProviders'] as List<dynamic>?)
          ?.map((e) => HomeNearestProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      packages: (json['packages'] as List<dynamic>?)
          ?.map((e) => HomePackage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeDataModelToJson(HomeDataModel instance) =>
    <String, dynamic>{
      'sliders': instance.sliders,
      'pendingAppointments': instance.pendingAppointments,
      'nearestProviders': instance.nearestProviders,
      'packages': instance.packages,
    };

HomeSlider _$HomeSliderFromJson(Map<String, dynamic> json) => HomeSlider(
  id: (json['id'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  providerId: (json['providerId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
);

Map<String, dynamic> _$HomeSliderToJson(HomeSlider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
    };

HomePendingAppointment _$HomePendingAppointmentFromJson(
  Map<String, dynamic> json,
) => HomePendingAppointment(
  providerId: (json['providerId'] as num?)?.toInt(),
  providerBranchId: (json['providerBranchId'] as num?)?.toInt(),
  providerName: json['providerName'] as String?,
  providerImageUrl: json['providerImageUrl'] as String?,
  branchName: json['branchName'] as String?,
  service: json['service'] as String?,
  status: json['status'] as String?,
  date: json['date'] as String?,
);

Map<String, dynamic> _$HomePendingAppointmentToJson(
  HomePendingAppointment instance,
) => <String, dynamic>{
  'providerId': instance.providerId,
  'providerBranchId': instance.providerBranchId,
  'providerName': instance.providerName,
  'providerImageUrl': instance.providerImageUrl,
  'branchName': instance.branchName,
  'service': instance.service,
  'status': instance.status,
  'date': instance.date,
};

HomeNearestProvider _$HomeNearestProviderFromJson(Map<String, dynamic> json) =>
    HomeNearestProvider(
      providerId: (json['providerId'] as num?)?.toInt(),
      providerBranchId: (json['providerBranchId'] as num?)?.toInt(),
      providerName: json['providerName'] as String?,
      providerImageUrl: json['providerImageUrl'] as String?,
      branchName: json['branchName'] as String?,
      fullAddress: json['fullAddress'] as String?,
      mapUrl: json['mapUrl'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HomeNearestProviderToJson(
  HomeNearestProvider instance,
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

HomePackage _$HomePackageFromJson(Map<String, dynamic> json) => HomePackage(
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

Map<String, dynamic> _$HomePackageToJson(HomePackage instance) =>
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
