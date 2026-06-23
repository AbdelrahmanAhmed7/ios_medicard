// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordResponseModel _$ChangePasswordResponseModelFromJson(
  Map<String, dynamic> json,
) => ChangePasswordResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  success: json['success'] as bool?,
  message: json['message'] as String?,
  token: json['token'] as String?,
  expiresAt: json['expiresAt'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$ChangePasswordResponseModelToJson(
  ChangePasswordResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'success': instance.success,
  'message': instance.message,
  'token': instance.token,
  'expiresAt': instance.expiresAt,
  'data': instance.data,
};
