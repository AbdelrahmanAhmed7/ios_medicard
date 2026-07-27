import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  @JsonKey(readValue: _readSucceeded, defaultValue: false)
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

Object? _readSucceeded(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['success'] ?? false;
}

/// Matches the `data` field of both /Auth/login and /Auth/register responses.
///
/// The API returns ISO-8601 strings with a trailing "Z" (UTC).
/// We store them as [DateTime] (UTC) so expiry checks are timezone-safe.
@JsonSerializable()
class AuthTokenDataModel {
  final String? token;

  /// Access-token expiry returned by the login/register endpoint.
  /// Parsed as UTC because the API always sends "Z"-suffixed timestamps.
  @JsonKey(fromJson: _parseDateTimeOrNull, toJson: _dateTimeToStringOrNull)
  final DateTime? expiresAt;

  /// Opaque refresh-token string.
  final String? refreshToken;

  /// Refresh-token expiry. Same UTC parsing rules as [expiresAt].
  @JsonKey(fromJson: _parseDateTimeOrNull, toJson: _dateTimeToStringOrNull)
  final DateTime? refreshTokenExpiresAt;

  /// Whether the login/register call itself succeeded (inner `success` field).
  final bool? success;

  /// Human-readable message inside the data object (some endpoints include it).
  final String? message;

  const AuthTokenDataModel({
    this.token,
    this.expiresAt,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.success,
    this.message,
  });

  factory AuthTokenDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenDataModelToJson(this);

  // ── helpers for custom JSON converters ─────────────────────────────────────

  static DateTime? _parseDateTimeOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  static String? _dateTimeToStringOrNull(DateTime? dt) => dt?.toIso8601String();
}
