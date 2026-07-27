// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_cart_invoice_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCartInvoiceRequestDto _$CreateCartInvoiceRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateCartInvoiceRequestDto(
  cardNumber: json['cardNumber'] as String?,
  isCash: json['isCash'] as bool,
  providerId: (json['providerId'] as num).toInt(),
  providerBranchId: (json['providerBranchId'] as num).toInt(),
  familyId: (json['familyId'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateCartInvoiceRequestDtoToJson(
  CreateCartInvoiceRequestDto instance,
) => <String, dynamic>{
  'cardNumber': ?instance.cardNumber,
  'isCash': instance.isCash,
  'providerId': instance.providerId,
  'providerBranchId': instance.providerBranchId,
  'familyId': ?instance.familyId,
};
