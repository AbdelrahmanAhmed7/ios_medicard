// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_data_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardDataResponseModel _$CardDataResponseModelFromJson(
  Map<String, dynamic> json,
) => CardDataResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CardData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardDataResponseModelToJson(
  CardDataResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

CardData _$CardDataFromJson(Map<String, dynamic> json) => CardData(
  cardNumber: json['cardNumber'] as String?,
  expireAt: json['expireAt'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  planType: json['planType'] as String?,
);

Map<String, dynamic> _$CardDataToJson(CardData instance) => <String, dynamic>{
  'cardNumber': instance.cardNumber,
  'expireAt': instance.expireAt,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'planType': instance.planType,
};
