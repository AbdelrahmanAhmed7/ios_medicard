// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_package_invoice_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePackageInvoiceRequestDto _$CreatePackageInvoiceRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreatePackageInvoiceRequestDto(
  packageId: (json['packageId'] as num).toInt(),
  providerBranchId: (json['providerBranchId'] as num).toInt(),
  isCash: json['isCash'] as bool,
  cardNumber: json['cardNumber'] as String?,
);

Map<String, dynamic> _$CreatePackageInvoiceRequestDtoToJson(
  CreatePackageInvoiceRequestDto instance,
) => <String, dynamic>{
  'packageId': instance.packageId,
  'providerBranchId': instance.providerBranchId,
  'isCash': instance.isCash,
  'cardNumber': instance.cardNumber,
};
