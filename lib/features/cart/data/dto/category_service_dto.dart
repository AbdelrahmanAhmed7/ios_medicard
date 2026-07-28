import 'package:json_annotation/json_annotation.dart';

part 'category_service_dto.g.dart';

@JsonSerializable()
class CategoryServiceDto {
  final int? serviceId;
  final String? serviceNameEn;
  final String? serviceNameAr;
  final bool? isSelected;

  const CategoryServiceDto({
    this.serviceId,
    this.serviceNameEn,
    this.serviceNameAr,
    this.isSelected,
  });

  String? get serviceName {
    final names = [
      serviceNameAr?.trim(),
      serviceNameEn?.trim(),
    ].where((name) => name != null && name.isNotEmpty).cast<String>();

    if (names.isEmpty) return null;
    return names.join(' - ');
  }

  factory CategoryServiceDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryServiceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServiceDtoToJson(this);
}
