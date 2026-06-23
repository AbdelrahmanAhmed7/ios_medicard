// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseModel _$SearchResponseModelFromJson(Map<String, dynamic> json) =>
    SearchResponseModel(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : SearchResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseModelToJson(
  SearchResponseModel instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data,
};

SearchResponseData _$SearchResponseDataFromJson(Map<String, dynamic> json) =>
    SearchResponseData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => SearchProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseDataToJson(SearchResponseData instance) =>
    <String, dynamic>{'items': instance.items};
