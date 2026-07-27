import 'package:json_annotation/json_annotation.dart';
import 'cart_item_dto.dart';
import 'category_counter_dto.dart';

part 'cart_dto.g.dart';

@JsonSerializable()
class CartDto {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final CartDataDto? data;

  const CartDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CartDto(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: _stringList(json['errors']),
      succeeded: json['succeeded'] as bool?,
      message: json['message']?.toString(),
      data: data is Map<String, dynamic> ? CartDataDto.fromJson(data) : null,
    );
  }

  Map<String, dynamic> toJson() => _$CartDtoToJson(this);
}

List<String>? _stringList(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.map((e) => e.toString()).toList();
  return [value.toString()];
}

@JsonSerializable()
class CartDataDto {
  final List<CartItemDto>? items;
  final int? totalCount;
  final List<CategoryCounterDto>? categoryCounters;

  const CartDataDto({this.items, this.totalCount, this.categoryCounters});

  factory CartDataDto.fromJson(Map<String, dynamic> json) =>
      _$CartDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CartDataDtoToJson(this);
}
