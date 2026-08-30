import 'package:json_annotation/json_annotation.dart';

import 'category_services_response_model.dart';

part 'guest_category_services_response_model.g.dart';

@JsonSerializable()
class GuestCategoryServicesResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final GuestPagedServicesDataModel? data;

  const GuestCategoryServicesResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GuestCategoryServicesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$GuestCategoryServicesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestCategoryServicesResponseModelToJson(
    this,
  );
}

@JsonSerializable()
class GuestPagedServicesDataModel {
  final List<GuestServiceItemModel>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const GuestPagedServicesDataModel({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory GuestPagedServicesDataModel.fromJson(Map<String, dynamic> json) =>
      _$GuestPagedServicesDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestPagedServicesDataModelToJson(this);

  /// Maps the guest response into the shared [CategoryServicesDataModel] used
  /// by the services tab, so the existing list/pagination UI stays the same.
  CategoryServicesDataModel toCategoryServicesDataModel(int categoryId) {
    return CategoryServicesDataModel(
      categoryId: categoryId,
      totalSelectedCount: 0,
      services: PagedServicesModel(
        items: (items ?? const [])
            .map(
              (item) => ServiceItemModel(
                serviceId: item.id,
                serviceNameEn: item.serviceNameEn,
                serviceNameAr: item.serviceNameAr,
                isSelected: false,
              ),
            )
            .toList(),
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalCount: totalCount,
        totalPages: totalPages,
      ),
    );
  }
}

@JsonSerializable()
class GuestServiceItemModel {
  final int? id;
  final String? serviceName;
  final String? serviceNameAr;
  final String? serviceNameEn;

  const GuestServiceItemModel({
    this.id,
    this.serviceName,
    this.serviceNameAr,
    this.serviceNameEn,
  });

  factory GuestServiceItemModel.fromJson(Map<String, dynamic> json) =>
      _$GuestServiceItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestServiceItemModelToJson(this);
}