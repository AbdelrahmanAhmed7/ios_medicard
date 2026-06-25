import 'package:json_annotation/json_annotation.dart';

part 'content_response_model.g.dart';

@JsonSerializable()
class ContentResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ContentData? data;

  const ContentResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ContentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ContentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContentResponseModelToJson(this);
}

@JsonSerializable()
class ContentData {
  final int? id;
  final String? description;

  const ContentData({
    this.id,
    this.description,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) =>
      _$ContentDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContentDataToJson(this);
}
