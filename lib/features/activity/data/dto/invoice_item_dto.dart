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
  final bool? isReviewed;
  final int? points;
  final bool? isFromPackage;
  final double? priceAfter;
  final double? priceBefore;
  final double? discountPercentage;
  final bool? isMedicineInvoice;
  final int? itemsCount;
  final int? totalQuantity;
  final int? familyId;
  final String? familyFirstName;
  final String? familyLastName;

  const InvoiceItemDto({
    this.invoiceId,
    this.providerName,
    this.branchName,
    this.status,
    this.date,
    this.providerImageUrl,
    this.isReviewed,
    this.points,
    this.isFromPackage,
    this.priceAfter,
    this.priceBefore,
    this.discountPercentage,
    this.isMedicineInvoice,
    this.itemsCount,
    this.totalQuantity,
    this.familyId,
    this.familyFirstName,
    this.familyLastName,
  });

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemDtoToJson(this);
}
