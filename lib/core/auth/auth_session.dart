/// Represents the currently authenticated user's token pair.
///
/// All [DateTime] values are stored and compared as UTC so timezone
/// differences never cause incorrect expiry decisions.
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
  });

  // ── Validity helpers ────────────────────────────────────────────────────────

  bool get hasAccessToken => accessToken.trim().isNotEmpty;
  bool get hasRefreshToken => refreshToken.trim().isNotEmpty;

  /// Returns true when the refresh token is missing or already past expiry.
  ///
  /// Some API responses provide a refresh token without an expiry timestamp.
  /// In that case we keep the session and let the refresh endpoint be the
  /// source of truth instead of logging the user out on every app restart.
  bool get isRefreshTokenExpired {
    if (!hasRefreshToken) return true;
    if (refreshTokenExpiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(refreshTokenExpiresAt!.toUtc());
  }

  /// Returns true when the access token is expired or within 2 minutes of
  /// expiring — giving the interceptor time to refresh proactively.
  bool get isAccessTokenExpiredOrAboutToExpire {
    if (accessTokenExpiresAt == null) return true;
    final now = DateTime.now().toUtc();
    final safeRefreshTime = accessTokenExpiresAt!.toUtc().subtract(
      const Duration(minutes: 2),
    );
    return now.isAfter(safeRefreshTime);
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt:
          refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
    );
  }
}
