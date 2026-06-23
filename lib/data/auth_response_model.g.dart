// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      succeeded: json['succeeded'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : AuthTokenDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'httpStatusCode': instance.httpStatusCode,
      'errors': instance.errors,
      'succeeded': instance.succeeded,
      'message': instance.message,
      'data': instance.data,
    };

AuthTokenDataModel _$AuthTokenDataModelFromJson(Map<String, dynamic> json) =>
    AuthTokenDataModel(
      token: json['token'] as String,
      expiresAt: json['expiresAt'] as String?,
    );

Map<String, dynamic> _$AuthTokenDataModelToJson(AuthTokenDataModel instance) =>
    <String, dynamic>{'token': instance.token, 'expiresAt': instance.expiresAt};
