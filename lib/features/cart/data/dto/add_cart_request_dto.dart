import 'package:json_annotation/json_annotation.dart';

part 'add_cart_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class AddCartRequestDto {
  final int serviceId;
  final int categoryId;
  final int? providerId;
  final String? cardNumber;
  final double? price;

  const AddCartRequestDto({
    required this.serviceId,
    required this.categoryId,
    this.providerId,
    this.cardNumber,
    this.price,
  });

  factory AddCartRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AddCartRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddCartRequestDtoToJson(this);
}
