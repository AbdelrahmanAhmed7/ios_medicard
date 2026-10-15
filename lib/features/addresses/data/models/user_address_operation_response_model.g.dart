// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_address_operation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAddressOperationResponseModel _$UserAddressOperationResponseModelFromJson(
  Map<String, dynamic> json,
) => UserAddressOperationResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$UserAddressOperationResponseModelToJson(
  UserAddressOperationResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
