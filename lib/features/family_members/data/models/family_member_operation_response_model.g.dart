// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_operation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyMemberOperationResponseModel _$FamilyMemberOperationResponseModelFromJson(
  Map<String, dynamic> json,
) => FamilyMemberOperationResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$FamilyMemberOperationResponseModelToJson(
  FamilyMemberOperationResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
