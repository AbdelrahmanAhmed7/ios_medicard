// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyMemberModel _$FamilyMemberModelFromJson(Map<String, dynamic> json) =>
    FamilyMemberModel(
      id: (json['id'] as num?)?.toInt(),
      fullName: json['fullName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      relation: (json['relation'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$FamilyMemberModelToJson(FamilyMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'relation': instance.relation,
      'imageUrl': instance.imageUrl,
    };
