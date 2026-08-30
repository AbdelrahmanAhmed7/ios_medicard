// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_category_services_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuestCategoryServicesResponseModel _$GuestCategoryServicesResponseModelFromJson(
  Map<String, dynamic> json,
) => GuestCategoryServicesResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : GuestPagedServicesDataModel.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GuestCategoryServicesResponseModelToJson(
  GuestCategoryServicesResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

GuestPagedServicesDataModel _$GuestPagedServicesDataModelFromJson(
  Map<String, dynamic> json,
) => GuestPagedServicesDataModel(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GuestServiceItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$GuestPagedServicesDataModelToJson(
  GuestPagedServicesDataModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

GuestServiceItemModel _$GuestServiceItemModelFromJson(
  Map<String, dynamic> json,
) => GuestServiceItemModel(
  id: (json['id'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  serviceNameAr: json['serviceNameAr'] as String?,
  serviceNameEn: json['serviceNameEn'] as String?,
);

Map<String, dynamic> _$GuestServiceItemModelToJson(
  GuestServiceItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'serviceName': instance.serviceName,
  'serviceNameAr': instance.serviceNameAr,
  'serviceNameEn': instance.serviceNameEn,
};
