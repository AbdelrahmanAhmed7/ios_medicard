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
      data: json['data'] == null
          ? null
          : InvoicesPageDto.fromJson(json['data'] as Map<String, dynamic>),
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

InvoicesPageDto _$InvoicesPageDtoFromJson(Map<String, dynamic> json) =>
    InvoicesPageDto(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => InvoiceItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InvoicesPageDtoToJson(InvoicesPageDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
    };
