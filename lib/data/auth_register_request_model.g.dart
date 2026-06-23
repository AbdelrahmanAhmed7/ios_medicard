// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthRegisterRequestModel _$AuthRegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => AuthRegisterRequestModel(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  isMale: json['isMale'] as bool,
  birthDate: json['birthDate'] as String,
  password: json['password'] as String,
  confirmPassword: json['confirmPassword'] as String,
  nationalId: json['nationalId'] as String?,
  passportNumber: json['passportNumber'] as String?,
);

Map<String, dynamic> _$AuthRegisterRequestModelToJson(
  AuthRegisterRequestModel instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'isMale': instance.isMale,
  'birthDate': instance.birthDate,
  'password': instance.password,
  'confirmPassword': instance.confirmPassword,
  'nationalId': instance.nationalId,
  'passportNumber': instance.passportNumber,
};
