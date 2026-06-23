import 'package:json_annotation/json_annotation.dart';

part 'change_password_response_model.g.dart';

@JsonSerializable()
class ChangePasswordResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final bool? success;
  final String? message;
  final String? token;
  final String? expiresAt;
  final dynamic data;

  const ChangePasswordResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.success,
    this.message,
    this.token,
    this.expiresAt,
    this.data,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordResponseModelToJson(this);
}
