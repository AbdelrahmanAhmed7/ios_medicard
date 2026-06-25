// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_family_member_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateFamilyMemberRequestModel _$CreateFamilyMemberRequestModelFromJson(
  Map<String, dynamic> json,
) => CreateFamilyMemberRequestModel(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  relation: (json['relation'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CreateFamilyMemberRequestModelToJson(
  CreateFamilyMemberRequestModel instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'relation': instance.relation,
  'imageUrl': instance.imageUrl,
};
