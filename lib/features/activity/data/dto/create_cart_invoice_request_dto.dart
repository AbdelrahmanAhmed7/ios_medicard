import 'package:json_annotation/json_annotation.dart';

part 'create_cart_invoice_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateCartInvoiceRequestDto {
  final String? cardNumber;
  final bool isCash;
  final int providerId;
  final int providerBranchId;
  final int? familyId;

  const CreateCartInvoiceRequestDto({
    this.cardNumber,
    required this.isCash,
    required this.providerId,
    required this.providerBranchId,
    this.familyId,
  });

  factory CreateCartInvoiceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCartInvoiceRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCartInvoiceRequestDtoToJson(this);
}
