import 'package:json_annotation/json_annotation.dart';

part 'invoice_item_dto.g.dart';

@JsonSerializable()
class InvoiceItemDto {
  final int? invoiceId;
  final String? providerName;
  final String? branchName;
  final String? status;
  final String? date;
  final String? providerImageUrl;

  const InvoiceItemDto({
    this.invoiceId,
    this.providerName,
    this.branchName,
    this.status,
    this.date,
    this.providerImageUrl,
  });

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemDtoToJson(this);
}
