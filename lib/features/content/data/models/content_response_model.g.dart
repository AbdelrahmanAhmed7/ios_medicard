// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentResponseModel _$ContentResponseModelFromJson(
  Map<String, dynamic> json,
) => ContentResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ContentData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContentResponseModelToJson(
  ContentResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

ContentData _$ContentDataFromJson(Map<String, dynamic> json) => ContentData(
  id: (json['id'] as num?)?.toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ContentDataToJson(ContentData instance) =>
    <String, dynamic>{'id': instance.id, 'description': instance.description};
