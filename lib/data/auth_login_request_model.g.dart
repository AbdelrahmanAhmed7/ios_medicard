// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthLoginRequestModel _$AuthLoginRequestModelFromJson(
  Map<String, dynamic> json,
) => AuthLoginRequestModel(
  cardNumber: json['cardNumber'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  password: json['password'] as String,
);

Map<String, dynamic> _$AuthLoginRequestModelToJson(
  AuthLoginRequestModel instance,
) => <String, dynamic>{
  'cardNumber': ?instance.cardNumber,
  'phoneNumber': ?instance.phoneNumber,
  'password': instance.password,
};
