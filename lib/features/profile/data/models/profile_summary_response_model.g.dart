// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_summary_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSummaryResponseModel _$ProfileSummaryResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileSummaryResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProfileSummaryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileSummaryResponseModelToJson(
  ProfileSummaryResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

ProfileSummaryData _$ProfileSummaryDataFromJson(Map<String, dynamic> json) =>
    ProfileSummaryData(
      familyMembersCount: (json['familyMembersCount'] as num?)?.toInt(),
      rewardPoints: (json['rewardPoints'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProfileSummaryDataToJson(ProfileSummaryData instance) =>
    <String, dynamic>{
      'familyMembersCount': instance.familyMembersCount,
      'rewardPoints': instance.rewardPoints,
    };
