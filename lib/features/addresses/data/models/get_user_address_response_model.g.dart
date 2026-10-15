// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_address_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUserAddressResponseModel _$GetUserAddressResponseModelFromJson(
  Map<String, dynamic> json,
) => GetUserAddressResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : UserAddressModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetUserAddressResponseModelToJson(
  GetUserAddressResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
