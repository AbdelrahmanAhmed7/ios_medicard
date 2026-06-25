// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_family_member_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetFamilyMemberResponseModel _$GetFamilyMemberResponseModelFromJson(
  Map<String, dynamic> json,
) => GetFamilyMemberResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : FamilyMemberModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetFamilyMemberResponseModelToJson(
  GetFamilyMemberResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
