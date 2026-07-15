// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_services_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryServicesDto _$CategoryServicesDtoFromJson(
  Map<String, dynamic> json,
) => CategoryServicesDto(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CategoryServicesDataDto.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategoryServicesDtoToJson(
  CategoryServicesDto instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

CategoryServicesDataDto _$CategoryServicesDataDtoFromJson(
  Map<String, dynamic> json,
) => CategoryServicesDataDto(
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String?,
  services: json['services'] == null
      ? null
      : CategoryServicesItemsWrapperDto.fromJson(
          json['services'] as Map<String, dynamic>,
        ),
  totalSelectedCount: (json['totalSelectedCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$CategoryServicesDataDtoToJson(
  CategoryServicesDataDto instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'services': instance.services,
  'totalSelectedCount': instance.totalSelectedCount,
};

CategoryServicesItemsWrapperDto _$CategoryServicesItemsWrapperDtoFromJson(
  Map<String, dynamic> json,
) => CategoryServicesItemsWrapperDto(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CategoryServiceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$CategoryServicesItemsWrapperDtoToJson(
  CategoryServicesItemsWrapperDto instance,
) => <String, dynamic>{
  'items': instance.items,
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};
