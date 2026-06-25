// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_family_members_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetFamilyMembersResponseModel _$GetFamilyMembersResponseModelFromJson(
  Map<String, dynamic> json,
) => GetFamilyMembersResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetFamilyMembersResponseModelToJson(
  GetFamilyMembersResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
