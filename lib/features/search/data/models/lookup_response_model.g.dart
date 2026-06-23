// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LookupResponseModel _$LookupResponseModelFromJson(Map<String, dynamic> json) =>
    LookupResponseModel(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LookupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LookupResponseModelToJson(
  LookupResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
