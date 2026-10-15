// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_user_address_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveUserAddressRequestModel _$SaveUserAddressRequestModelFromJson(
  Map<String, dynamic> json,
) => SaveUserAddressRequestModel(
  governorateId: (json['governorateId'] as num?)?.toInt(),
  cityId: (json['cityId'] as num?)?.toInt(),
  floor: (json['floor'] as num?)?.toInt(),
  buildingNumber: (json['buildingNumber'] as num?)?.toInt(),
  apartmentNumber: (json['apartmentNumber'] as num?)?.toInt(),
  lat: (json['lat'] as num?)?.toDouble(),
  long: (json['long'] as num?)?.toDouble(),
  mainAddress: (json['mainAddress'] as num?)?.toInt(),
  isDefault: json['isDefault'] as bool?,
);

Map<String, dynamic> _$SaveUserAddressRequestModelToJson(
  SaveUserAddressRequestModel instance,
) => <String, dynamic>{
  'governorateId': instance.governorateId,
  'cityId': instance.cityId,
  'floor': instance.floor,
  'buildingNumber': instance.buildingNumber,
  'apartmentNumber': instance.apartmentNumber,
  'lat': instance.lat,
  'long': instance.long,
  'mainAddress': instance.mainAddress,
  'isDefault': instance.isDefault,
};
