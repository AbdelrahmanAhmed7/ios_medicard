import 'package:json_annotation/json_annotation.dart';

part 'otp_response_model.g.dart';

/// Shared response for the forgot-password flow endpoints.
/// `data` carries different payloads per step:
/// - send-otp  → the generated OTP (String)
/// - verify-otp → the verification token (String)
/// - reset     → empty String on success
@JsonSerializable()
class OtpResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  @JsonKey(readValue: _readSucceeded, defaultValue: false)
  final bool succeeded;
  final String? message;
  final String? data;

  const OtpResponseModel({
    this.httpStatusCode,
    this.errors,
    required this.succeeded,
    this.message,
    this.data,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResponseModelToJson(this);
}

Object? _readSucceeded(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['success'] ?? false;
}
