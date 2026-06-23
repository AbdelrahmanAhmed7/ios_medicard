import 'package:json_annotation/json_annotation.dart';

part 'change_language_response_model.g.dart';

@JsonSerializable()
class ChangeLanguageResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final dynamic data;

  const ChangeLanguageResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ChangeLanguageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChangeLanguageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeLanguageResponseModelToJson(this);
}
