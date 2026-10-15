// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_addresses_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUserAddressesResponseModel _$GetUserAddressesResponseModelFromJson(
  Map<String, dynamic> json,
) => GetUserAddressesResponseModel(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : UserAddressesPageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetUserAddressesResponseModelToJson(
  GetUserAddressesResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

UserAddressesPageData _$UserAddressesPageDataFromJson(
  Map<String, dynamic> json,
) => UserAddressesPageData(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => UserAddressModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserAddressesPageDataToJson(
  UserAddressesPageData instance,
) => <String, dynamic>{
  'items': instance.items,
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};
