// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_language_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeLanguageResponseModel _$ChangeLanguageResponseModelFromJson(
  Map<String, dynamic> json,
) => ChangeLanguageResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$ChangeLanguageResponseModelToJson(
  ChangeLanguageResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
