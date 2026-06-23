// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseModel _$ProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileResponseModelToJson(
  ProfileResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  nationalId: json['nationalId'] as String?,
  passportNumber: json['passportNumber'] as String?,
  isMale: json['isMale'] as bool?,
  birthDate: json['birthDate'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phoneNumber': instance.phoneNumber,
      'nationalId': instance.nationalId,
      'passportNumber': instance.passportNumber,
      'isMale': instance.isMale,
      'birthDate': instance.birthDate,
      'imageUrl': instance.imageUrl,
    };
