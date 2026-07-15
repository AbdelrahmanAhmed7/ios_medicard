// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoicesResponseDto _$InvoicesResponseDtoFromJson(Map<String, dynamic> json) =>
    InvoicesResponseDto(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: json['errors'],
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => InvoiceItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InvoicesResponseDtoToJson(
  InvoicesResponseDto instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};
