import 'package:json_annotation/json_annotation.dart';
import 'category_model.dart';

part 'category_response_model.g.dart';

@JsonSerializable()
class CategoryResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final List<CategoryModel>? data;

  const CategoryResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseModelToJson(this);
}
