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
      succeeded: _readSucceeded(json, 'succeeded') as bool? ?? false,
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
      token: json['token'] as String?,
      expiresAt: AuthTokenDataModel._parseDateTimeOrNull(
        json['expiresAt'] as String?,
      ),
      refreshToken: json['refreshToken'] as String?,
      refreshTokenExpiresAt: AuthTokenDataModel._parseDateTimeOrNull(
        json['refreshTokenExpiresAt'] as String?,
      ),
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$AuthTokenDataModelToJson(
  AuthTokenDataModel instance,
) => <String, dynamic>{
  'token': instance.token,
  'expiresAt': AuthTokenDataModel._dateTimeToStringOrNull(instance.expiresAt),
  'refreshToken': instance.refreshToken,
  'refreshTokenExpiresAt': AuthTokenDataModel._dateTimeToStringOrNull(
    instance.refreshTokenExpiresAt,
  ),
  'success': instance.success,
  'message': instance.message,
};
