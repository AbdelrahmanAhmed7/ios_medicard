import 'package:json_annotation/json_annotation.dart';

part 'create_invoice_response_dto.g.dart';

@JsonSerializable()
class CreateInvoiceResponseDto {
  final int? httpStatusCode;
  final dynamic errors;
  final bool? succeeded;
  final String? message;
  final dynamic data;

  const CreateInvoiceResponseDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CreateInvoiceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInvoiceResponseDtoToJson(this);
}
