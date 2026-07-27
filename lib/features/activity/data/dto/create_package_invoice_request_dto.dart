import 'package:json_annotation/json_annotation.dart';

part 'create_package_invoice_request_dto.g.dart';

@JsonSerializable()
class CreatePackageInvoiceRequestDto {
  final int packageId;
  final int providerBranchId;
  final bool isCash;
  final String? cardNumber;

  const CreatePackageInvoiceRequestDto({
    required this.packageId,
    required this.providerBranchId,
    required this.isCash,
    this.cardNumber,
  });

  factory CreatePackageInvoiceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePackageInvoiceRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePackageInvoiceRequestDtoToJson(this);
}
