// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddressModel _$UserAddressModelFromJson(Map<String, dynamic> json) =>
    UserAddressModel(
      id: (json['id'] as num?)?.toInt(),
      governorateId: (json['governorateId'] as num?)?.toInt(),
      governorateNameAr: json['governorateNameAr'] as String?,
      governorateNameEn: json['governorateNameEn'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      cityNameAr: json['cityNameAr'] as String?,
      cityNameEn: json['cityNameEn'] as String?,
      floor: (json['floor'] as num?)?.toInt(),
      buildingNumber: (json['buildingNumber'] as num?)?.toInt(),
      apartmentNumber: (json['apartmentNumber'] as num?)?.toInt(),
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      mainAddress: (json['mainAddress'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$UserAddressModelToJson(UserAddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'governorateId': instance.governorateId,
      'governorateNameAr': instance.governorateNameAr,
      'governorateNameEn': instance.governorateNameEn,
      'cityId': instance.cityId,
      'cityNameAr': instance.cityNameAr,
      'cityNameEn': instance.cityNameEn,
      'floor': instance.floor,
      'buildingNumber': instance.buildingNumber,
      'apartmentNumber': instance.apartmentNumber,
      'lat': instance.lat,
      'long': instance.long,
      'mainAddress': instance.mainAddress,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt,
    };
