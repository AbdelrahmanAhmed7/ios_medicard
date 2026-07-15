import 'package:json_annotation/json_annotation.dart';

part 'add_cart_request_dto.g.dart';

@JsonSerializable()
class AddCartRequestDto {
  final int serviceId;
  final int categoryId;
  final int? providerId;
  final String? cardNumber;

  const AddCartRequestDto({
    required this.serviceId,
    required this.categoryId,
    this.providerId,
    this.cardNumber,
  });

  factory AddCartRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AddCartRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddCartRequestDtoToJson(this);
}
