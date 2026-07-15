import '../constants/constants.dart';
import '../helpers/shared_pref_helper.dart';
import 'auth_session.dart';
import 'jwt_helper.dart';
import 'package:flutter/foundation.dart';

/// Persists the auth session (tokens + expiry dates) using [FlutterSecureStorage]
/// via [SharedPrefHelper].
///
/// Security rules enforced here:
/// - Token values are NEVER printed / logged.
/// - Tokens are NEVER written to plain [SharedPreferences].
class AuthSessionStorage {
  const AuthSessionStorage();

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.accessToken,
        session.accessToken,
      ),
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.refreshToken,
        session.refreshToken,
      ),
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.accessTokenExpiresAt,
        session.accessTokenExpiresAt?.toUtc().toIso8601String() ?? '',
      ),
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.refreshTokenExpiresAt,
        session.refreshTokenExpiresAt?.toUtc().toIso8601String() ?? '',
      ),
      // Keep legacy key in sync so older code paths still work.
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.userToken,
        session.accessToken,
      ),
    ]);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime? accessTokenExpiresAt,
    required DateTime? refreshTokenExpiresAt,
  }) async {
    await saveSession(
      AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
        refreshTokenExpiresAt: refreshTokenExpiresAt,
      ),
    );
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<AuthSession?> getSession() async {
    if (kDebugMode)
      debugPrint('[AuthSessionStorage] reading authentication session');
    final accessToken = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.accessToken,
    );

    // No session stored yet.
    if (accessToken.isEmpty) {
      // Try legacy key for backwards-compatibility (users who logged in before
      // the new session storage was added).
      final legacy = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      if (legacy.isEmpty) {
        if (kDebugMode)
          debugPrint('[AuthSessionStorage] no access token found');
        return null;
      }

      final refreshToken = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.refreshToken,
      );
      if (refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[AuthSessionStorage] legacy access token found; refresh token missing',
          );
        }
        return AuthSession(
          accessToken: legacy,
          refreshToken: '',
          accessTokenExpiresAt: getJwtExpiryDate(legacy),
          refreshTokenExpiresAt: null,
        );
      }

      if (kDebugMode)
        debugPrint(
          '[AuthSessionStorage] legacy authentication session available',
        );
      return AuthSession(
        accessToken: legacy,
        refreshToken: refreshToken,
        accessTokenExpiresAt: null,
        refreshTokenExpiresAt: null,
      );
    }

    final refreshToken = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.refreshToken,
    );
    final expiresAtRaw = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.accessTokenExpiresAt,
    );
    final refreshExpiresAtRaw = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.refreshTokenExpiresAt,
    );

    if (kDebugMode) {
      debugPrint(
        refreshToken.isEmpty
            ? '[AuthSessionStorage] access-only authentication session available'
            : '[AuthSessionStorage] authentication session available',
      );
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: expiresAtRaw.isNotEmpty
          ? DateTime.tryParse(expiresAtRaw)?.toUtc()
          : getJwtExpiryDate(accessToken),
      refreshTokenExpiresAt: refreshExpiresAtRaw.isNotEmpty
          ? DateTime.tryParse(refreshExpiresAtRaw)?.toUtc()
          : null,
    );
  }

  Future<String?> getAccessToken() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.accessToken,
    );
    if (token.isNotEmpty) return token;

    // Fallback to legacy key.
    final legacy = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    return legacy.isNotEmpty ? legacy : null;
  }

  Future<String?> getRefreshToken() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.refreshToken,
    );
    return token.isNotEmpty ? token : null;
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    await Future.wait([
      SharedPrefHelper.setSecuredString(SharedPrefKeys.accessToken, ''),
      SharedPrefHelper.setSecuredString(SharedPrefKeys.refreshToken, ''),
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.accessTokenExpiresAt,
        '',
      ),
      SharedPrefHelper.setSecuredString(
        SharedPrefKeys.refreshTokenExpiresAt,
        '',
      ),
      SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, ''),
    ]);
  }
}
