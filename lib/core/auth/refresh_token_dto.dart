/// Request body sent to POST /api/Auth/refresh-token.
class RefreshTokenRequestDto {
  final String refreshToken;

  const RefreshTokenRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

/// Inner `data` object from the refresh-token response.
///
/// The API currently does NOT return `expiresAt` for the new access token.
/// When that field is absent we decode the `exp` claim from the JWT itself.
class RefreshTokenResponseDto {
  /// New access token.
  final String? token;

  /// New (rotated) refresh token — must replace the old one immediately.
  final String? refreshToken;

  /// New refresh-token expiry (UTC).
  final DateTime? refreshTokenExpiresAt;

  /// New access-token expiry (UTC).
  /// Currently not returned by the API — will be decoded from JWT if null.
  final DateTime? expiresAt;

  const RefreshTokenResponseDto({
    this.token,
    this.refreshToken,
    this.refreshTokenExpiresAt,
    this.expiresAt,
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseDto(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      refreshTokenExpiresAt: _parseDate(json['refreshTokenExpiresAt']),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toUtc();
  }
}

/// Outer envelope from the refresh-token endpoint:
///
/// ```json
/// {
///   "httpStatusCode": 200,
///   "succeeded": true,
///   "message": "TokenRefreshedSuccessfully",
///   "data": { "token": "...", "refreshToken": "...", "refreshTokenExpiresAt": "..." }
/// }
/// ```
class RefreshTokenEnvelopeDto {
  final int? httpStatusCode;
  final bool? succeeded;
  final String? message;
  final RefreshTokenResponseDto? data;

  const RefreshTokenEnvelopeDto({
    this.httpStatusCode,
    this.succeeded,
    this.message,
    this.data,
  });

  factory RefreshTokenEnvelopeDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenEnvelopeDto(
      httpStatusCode: json['httpStatusCode'] as int?,
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? RefreshTokenResponseDto.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
