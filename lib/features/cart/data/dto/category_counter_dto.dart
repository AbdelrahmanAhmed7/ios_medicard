import 'package:json_annotation/json_annotation.dart';

part 'category_counter_dto.g.dart';

@JsonSerializable()
class CategoryCounterDto {
  final int? categoryId;
  final String? categoryName;
  final int? count;

  const CategoryCounterDto({
    this.categoryId,
    this.categoryName,
    this.count,
  });

  factory CategoryCounterDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryCounterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryCounterDtoToJson(this);
}
