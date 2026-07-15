import 'package:json_annotation/json_annotation.dart';

part 'category_service_dto.g.dart';

@JsonSerializable()
class CategoryServiceDto {
  final int? serviceId;
  final String? serviceName;
  final bool? isSelected;

  const CategoryServiceDto({
    this.serviceId,
    this.serviceName,
    this.isSelected,
  });

  factory CategoryServiceDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryServiceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServiceDtoToJson(this);
}
