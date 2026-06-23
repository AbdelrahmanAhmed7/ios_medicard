import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool succeeded;
  final String? message;
  final AuthTokenDataModel? data;

  const AuthResponseModel({
    this.httpStatusCode,
    this.errors,
    required this.succeeded,
    this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@JsonSerializable()
class AuthTokenDataModel {
  final String token;
  final String? expiresAt;

  const AuthTokenDataModel({
    required this.token,
    this.expiresAt,
  });

  factory AuthTokenDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenDataModelToJson(this);
}
