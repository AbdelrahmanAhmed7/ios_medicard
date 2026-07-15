import 'package:json_annotation/json_annotation.dart';
import 'invoice_item_dto.dart';

part 'invoices_response_dto.g.dart';

@JsonSerializable()
class InvoicesResponseDto {
  final int? httpStatusCode;
  final dynamic errors;
  final bool? succeeded;
  final String? message;
  final List<InvoiceItemDto>? data;

  const InvoicesResponseDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory InvoicesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InvoicesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InvoicesResponseDtoToJson(this);
}
