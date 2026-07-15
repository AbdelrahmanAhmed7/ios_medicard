// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_services_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryServicesResponseModel _$CategoryServicesResponseModelFromJson(
  Map<String, dynamic> json,
) => CategoryServicesResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CategoryServicesDataModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CategoryServicesResponseModelToJson(
  CategoryServicesResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

CategoryServicesDataModel _$CategoryServicesDataModelFromJson(
  Map<String, dynamic> json,
) => CategoryServicesDataModel(
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String?,
  services: json['services'] == null
      ? null
      : PagedServicesModel.fromJson(json['services'] as Map<String, dynamic>),
  totalSelectedCount: (json['totalSelectedCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CategoryServicesDataModelToJson(
  CategoryServicesDataModel instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'services': instance.services,
  'totalSelectedCount': instance.totalSelectedCount,
};

PagedServicesModel _$PagedServicesModelFromJson(Map<String, dynamic> json) =>
    PagedServicesModel(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PagedServicesModelToJson(PagedServicesModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
    };

ServiceItemModel _$ServiceItemModelFromJson(Map<String, dynamic> json) =>
    ServiceItemModel(
      serviceId: (json['serviceId'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      isSelected: json['isSelected'] as bool?,
    );

Map<String, dynamic> _$ServiceItemModelToJson(ServiceItemModel instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'isSelected': instance.isSelected,
    };
