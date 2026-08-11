// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

Map<String, dynamic> _$HomeSliderToJson(HomeSlider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
    };

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

Map<String, dynamic> _$HomePackageToJson(HomePackage instance) =>
    <String, dynamic>{
      'packageId': instance.packageId,
      'providerId': instance.providerId,
      'providerBranchId': instance.providerBranchId,
      'providerName': instance.providerName,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'servicesCount': instance.servicesCount,
    };
