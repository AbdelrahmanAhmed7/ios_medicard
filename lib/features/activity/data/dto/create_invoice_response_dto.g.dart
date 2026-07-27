// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invoice_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateInvoiceResponseDto _$CreateInvoiceResponseDtoFromJson(
  Map<String, dynamic> json,
) => CreateInvoiceResponseDto(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: json['errors'],
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$CreateInvoiceResponseDtoToJson(
  CreateInvoiceResponseDto instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
