// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_card_activation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberCardActivationResponseModel _$MemberCardActivationResponseModelFromJson(
  Map<String, dynamic> json,
) => MemberCardActivationResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] as String?,
);

Map<String, dynamic> _$MemberCardActivationResponseModelToJson(
  MemberCardActivationResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
