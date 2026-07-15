// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItemDto _$InvoiceItemDtoFromJson(Map<String, dynamic> json) =>
    InvoiceItemDto(
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      providerName: json['providerName'] as String?,
      branchName: json['branchName'] as String?,
      status: json['status'] as String?,
      date: json['date'] as String?,
      providerImageUrl: json['providerImageUrl'] as String?,
    );

Map<String, dynamic> _$InvoiceItemDtoToJson(InvoiceItemDto instance) =>
    <String, dynamic>{
      'invoiceId': instance.invoiceId,
      'providerName': instance.providerName,
      'branchName': instance.branchName,
      'status': instance.status,
      'date': instance.date,
      'providerImageUrl': instance.providerImageUrl,
    };
