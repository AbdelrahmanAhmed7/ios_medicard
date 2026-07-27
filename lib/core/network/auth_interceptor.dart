import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/auth_refresh_service.dart';
import '../auth/auth_session_storage.dart';

/// Paths that must NEVER receive an [Authorization] header.
const _publicPaths = {'Auth/login', 'Auth/register', 'Auth/refresh-token'};

bool _isPublicPath(String path) {
  for (final p in _publicPaths) {
    if (path.contains(p)) return true;
  }
  return false;
}

/// Intercepts every Dio request/error to:
///
/// 1. **Attach** `Authorization: Bearer <token>` to protected requests.
/// 2. **Proactively refresh** when the token is expired or about to expire.
/// 3. **Retry** a failed (401) request exactly once after a successful refresh.
/// 4. **Signal session expiry** (clear session) when refresh fails.
class AuthInterceptor extends Interceptor {
  final AuthSessionStorage _sessionStorage;
  final AuthRefreshService _refreshService;

  /// Called when the session is definitively invalid.
  /// Wire this to trigger navigation to the login screen.
  final void Function() onSessionExpired;

  AuthInterceptor({
    required AuthSessionStorage sessionStorage,
    required AuthRefreshService refreshService,
    required this.onSessionExpired,
  }) : _sessionStorage = sessionStorage,
       _refreshService = refreshService;

  // ── Request ────────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip for public endpoints and the refresh call itself.
    if (_isPublicPath(options.path) ||
        options.extra['skipAuthInterceptor'] == true) {
      return handler.next(options);
    }

    if (kDebugMode) {
      debugPrint('[HTTP] preparing ${options.method} ${options.path}');
    }

    final session = await _sessionStorage.getSession();

    if (session == null || !session.hasAccessToken) {
      if (kDebugMode) {
        debugPrint('[HTTP] authentication unavailable for ${options.path}');
      }
      // No session — let through; server 401 will be handled in onError.
      return handler.next(options);
    }

    if (session.isAccessTokenExpiredOrAboutToExpire &&
        session.hasRefreshToken) {
      if (kDebugMode) {
        debugPrint(
          '[AuthInterceptor] Access token expiring — proactive refresh',
        );
      }
      final newSession = await _refreshService.refreshToken();
      if (newSession != null && newSession.hasAccessToken) {
        options.headers['Authorization'] = 'Bearer ${newSession.accessToken}';
      } else {
        final retainedSession = await _sessionStorage.getSession();
        if (retainedSession != null && retainedSession.hasAccessToken) {
          options.headers['Authorization'] =
              'Bearer ${retainedSession.accessToken}';
          return handler.next(options);
        }
        if (kDebugMode) {
          debugPrint('[AuthInterceptor] Proactive refresh failed');
        }
        onSessionExpired();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Session expired',
          ),
        );
      }
    } else if (session.hasAccessToken) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    if (kDebugMode) {
      debugPrint(
        '[HTTP] sending ${options.method} ${options.path} (authorized=${options.headers.containsKey('Authorization')})',
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[HTTP] received ${response.statusCode} for ${response.requestOptions.method} ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }

  // ── Error (401 handling + single retry) ────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    if (kDebugMode) {
      debugPrint(
        '[HTTP] exception for ${options.method} ${options.path} (status=$statusCode, type=${err.type})',
      );
    }

    // Only handle 401 on non-public, non-retried requests.
    if (statusCode != 401 ||
        _isPublicPath(options.path) ||
        options.extra['retried'] == true ||
        options.extra['skipAuthInterceptor'] == true) {
      return super.onError(err, handler);
    }

    if (kDebugMode) {
      debugPrint('[AuthInterceptor] 401 — attempting token refresh');
    }

    // Prevent infinite retry.
    options.extra['retried'] = true;

    final newSession = await _refreshService.refreshToken();

    if (newSession == null || !newSession.hasAccessToken) {
      final retainedSession = await _sessionStorage.getSession();
      if (retainedSession != null && retainedSession.hasRefreshToken) {
        return super.onError(err, handler);
      }
      if (kDebugMode) {
        debugPrint('[AuthInterceptor] Refresh failed after 401 — logging out');
      }
      onSessionExpired();
      return super.onError(err, handler);
    }

    // Retry with new token using a fresh bare Dio (no auth interceptor).
    try {
      final retryDio = Dio(
        BaseOptions(
          baseUrl: options.baseUrl,
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
          sendTimeout: options.sendTimeout,
        ),
      );

      final response = await retryDio.request<dynamic>(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        cancelToken: options.cancelToken,
        options: Options(
          method: options.method,
          headers: {
            ...options.headers,
            'Authorization': 'Bearer ${newSession.accessToken}',
          },
          extra: {
            ...options.extra,
            'skipAuthInterceptor': true,
            'retried': true,
          },
          responseType: options.responseType,
          validateStatus: options.validateStatus,
          contentType: options.contentType,
          followRedirects: options.followRedirects,
          maxRedirects: options.maxRedirects,
          receiveTimeout: options.receiveTimeout,
          sendTimeout: options.sendTimeout,
        ),
      );
      return handler.resolve(response);
    } catch (retryError) {
      if (retryError is DioException) {
        return super.onError(retryError, handler);
      }
      return super.onError(err, handler);
    }
  }
}
