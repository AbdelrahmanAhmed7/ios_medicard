// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activate_card_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivateCardResponseModel _$ActivateCardResponseModelFromJson(
  Map<String, dynamic> json,
) => ActivateCardResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num).toInt(),
  errors: json['errors'],
  succeeded: json['succeeded'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : ActivateCardData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivateCardResponseModelToJson(
  ActivateCardResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

ActivateCardData _$ActivateCardDataFromJson(Map<String, dynamic> json) =>
    ActivateCardData(
      token: json['token'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$ActivateCardDataToJson(ActivateCardData instance) =>
    <String, dynamic>{'token': instance.token, 'expiresAt': instance.expiresAt};
