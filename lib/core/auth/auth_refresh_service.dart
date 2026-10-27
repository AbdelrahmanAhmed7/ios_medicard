import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_session.dart';
import 'auth_session_storage.dart';
import 'jwt_helper.dart';
import 'refresh_token_dto.dart';

class AuthRefreshService {
  final AuthSessionStorage _sessionStorage;

  final Dio _refreshDio;

  AuthRefreshService({
    required AuthSessionStorage sessionStorage,
    required Dio refreshDio,
  }) : _sessionStorage = sessionStorage,
       _refreshDio = refreshDio;

  // ── Single-flight guard ────────────────────────────────────────────────────

  Future<AuthSession?>? _ongoingRefresh;

  Future<AuthSession?> refreshToken() {
    _ongoingRefresh ??= _performRefresh().whenComplete(() {
      _ongoingRefresh = null;
    });
    return _ongoingRefresh!;
  }

  // ── Core refresh logic ─────────────────────────────────────────────────────

  Future<AuthSession?> _performRefresh() async {
    try {
      final session = await _sessionStorage.getSession();

      // Nothing to refresh — not logged in.
      if (session == null || !session.hasRefreshToken) {
        return null;
      }

      // Refresh token is already expired — no point calling the API.
      if (session.isRefreshTokenExpired) {
        if (kDebugMode) {
          debugPrint(
            '[AuthRefreshService] Refresh token expired — clearing session',
          );
        }
        await _clearSessionIfStillCurrent(session.refreshToken);
        return null;
      }

      // POST /api/Auth/refresh-token
      final requestBody = RefreshTokenRequestDto(
        refreshToken: session.refreshToken,
      ).toJson();

      final response = await _refreshDio.post<Map<String, dynamic>>(
        'Auth/refresh-token',
        data: requestBody,
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      final envelope = RefreshTokenEnvelopeDto.fromJson(response.data ?? {});

      final data = envelope.data;
      final newAccessToken = data?.token;
      final newRefreshToken = data?.refreshToken;

      if (envelope.succeeded != true ||
          newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[AuthRefreshService] Refresh failed — response: ${envelope.message}',
          );
        }
        // A malformed/partial 2xx response can be caused by a temporary
        // backend problem. Only destroy the session when the envelope itself
        // explicitly says the credential is invalid.
        if (_isCredentialRejection(envelope.httpStatusCode)) {
          await _clearSessionIfStillCurrent(session.refreshToken);
        }
        return null;
      }

      // Determine access-token expiry.
      // Prefer the field from the response; fall back to decoding the JWT.
      final accessTokenExpiry =
          data?.expiresAt ??
          getJwtExpiryDate(newAccessToken) ??
          DateTime.now().toUtc().add(const Duration(minutes: 55));

      final newSession = AuthSession(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        accessTokenExpiresAt: accessTokenExpiry,
        refreshTokenExpiresAt: data?.refreshTokenExpiresAt,
      );

      // A login/logout may have happened while the refresh request was in
      // flight. Never let an old response overwrite that newer session.
      final currentSession = await _sessionStorage.getSession();
      if (currentSession == null ||
          currentSession.refreshToken != session.refreshToken) {
        if (kDebugMode) {
          debugPrint('[AuthRefreshService] Ignoring stale refresh response');
        }
        return currentSession;
      }

      await _sessionStorage.saveSession(newSession);

      if (kDebugMode) {
        debugPrint('[AuthRefreshService] Token refreshed successfully');
      }

      return newSession;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (kDebugMode) {
        final data = e.response?.data;
        final message = data is Map ? data['message'] : null;
        debugPrint(
          '[AuthRefreshService] Refresh request failed (HTTP $statusCode, message=$message)',
        );
      }
      if (_isCredentialRejection(statusCode)) {
        final attemptedToken = _refreshTokenUsedBy(e.requestOptions);
        if (attemptedToken != null) {
          await _clearSessionIfStillCurrent(attemptedToken);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AuthRefreshService] Unexpected refresh error: ${e.runtimeType}',
        );
      }
      return null;
    }
  }

  bool _isCredentialRejection(int? statusCode) {
    return statusCode == 400 || statusCode == 401 || statusCode == 403;
  }

  String? _refreshTokenUsedBy(RequestOptions options) {
    final body = options.data;
    if (body is Map) {
      final value = body['refreshToken'];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  Future<void> _clearSessionIfStillCurrent(String attemptedToken) async {
    final currentSession = await _sessionStorage.getSession();
    if (currentSession?.refreshToken == attemptedToken) {
      await _sessionStorage.clearSession();
    }
  }
}
