import 'package:json_annotation/json_annotation.dart';
import 'search_provider_model.dart';

part 'search_response_model.g.dart';

@JsonSerializable()
class SearchResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final SearchResponseData? data;

  const SearchResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);
}

@JsonSerializable()
class SearchResponseData {
  final List<SearchProviderModel>? items;

  const SearchResponseData({this.items});

  factory SearchResponseData.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseDataToJson(this);
}
