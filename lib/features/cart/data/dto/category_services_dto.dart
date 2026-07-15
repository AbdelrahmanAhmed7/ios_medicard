import 'package:json_annotation/json_annotation.dart';
import 'category_service_dto.dart';

part 'category_services_dto.g.dart';

/// Outer API envelope for GET /Cart/category/{id}/services
@JsonSerializable()
class CategoryServicesDto {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final CategoryServicesDataDto? data;

  const CategoryServicesDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CategoryServicesDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryServicesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServicesDtoToJson(this);
}

/// The `data` object inside the response:
///
/// ```json
/// {
///   "categoryId": 2,
///   "categoryName": "Medical Analysis",
///   "services": { "items": [...] },
///   "totalSelectedCount": 3
/// }
/// ```
@JsonSerializable()
class CategoryServicesDataDto {
  final int? categoryId;
  final String? categoryName;

  /// The nested `services` object — contains the paged items list.
  final CategoryServicesItemsWrapperDto? services;

  /// Number of services already selected (in cart) for this category.
  final int? totalSelectedCount;

  const CategoryServicesDataDto({
    this.categoryId,
    this.categoryName,
    this.services,
    this.totalSelectedCount,
  });

  /// Convenience getter so call-sites can use `data.items` directly.
  List<CategoryServiceDto> get items => services?.items ?? [];

  factory CategoryServicesDataDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryServicesDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServicesDataDtoToJson(this);
}

/// The nested `services` wrapper that holds the paged items list.
@JsonSerializable()
class CategoryServicesItemsWrapperDto {
  final List<CategoryServiceDto>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const CategoryServicesItemsWrapperDto({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory CategoryServicesItemsWrapperDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryServicesItemsWrapperDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CategoryServicesItemsWrapperDtoToJson(this);
}
