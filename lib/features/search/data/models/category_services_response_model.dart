import 'package:json_annotation/json_annotation.dart';

part 'category_services_response_model.g.dart';

@JsonSerializable()
class CategoryServicesResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final CategoryServicesDataModel? data;

  const CategoryServicesResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CategoryServicesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryServicesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServicesResponseModelToJson(this);
}

@JsonSerializable()
class CategoryServicesDataModel {
  final int? categoryId;
  final String? categoryName;
  final PagedServicesModel? services;
  final int? totalSelectedCount;

  const CategoryServicesDataModel({
    this.categoryId,
    this.categoryName,
    this.services,
    this.totalSelectedCount,
  });

  factory CategoryServicesDataModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryServicesDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServicesDataModelToJson(this);
}

@JsonSerializable()
class PagedServicesModel {
  final List<ServiceItemModel>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const PagedServicesModel({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory PagedServicesModel.fromJson(Map<String, dynamic> json) =>
      _$PagedServicesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PagedServicesModelToJson(this);
}

@JsonSerializable()
class ServiceItemModel {
  final int? serviceId;
  final String? serviceName;
  final bool? isSelected;

  const ServiceItemModel({
    this.serviceId,
    this.serviceName,
    this.isSelected,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceItemModelToJson(this);
}
