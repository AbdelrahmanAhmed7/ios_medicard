import 'package:json_annotation/json_annotation.dart';
import 'lookup_model.dart';

part 'lookup_response_model.g.dart';

@JsonSerializable()
class LookupResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final List<LookupModel>? data;

  const LookupResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory LookupResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LookupResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LookupResponseModelToJson(this);
}
