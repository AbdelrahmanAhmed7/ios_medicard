import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/auth/auth_refresh_service.dart';
import 'package:medicard/core/auth/auth_session.dart';
import 'package:medicard/core/auth/auth_session_storage.dart';

void main() {
  group('AuthRefreshService', () {
    test('shares one refresh request and persists the rotated token', () async {
      const originalRefreshToken = 'refresh-token-v1';
      const rotatedRefreshToken = 'refresh-token-v2';
      final expectedExpiry = DateTime.fromMillisecondsSinceEpoch(
        2000000000 * 1000,
        isUtc: true,
      );
      final accessToken = _jwtWithExpiry(2000000000);
      final storage = _FakeAuthSessionStorage(
        AuthSession(
          accessToken: _jwtWithExpiry(1900000000),
          refreshToken: originalRefreshToken,
          accessTokenExpiresAt: DateTime.utc(2030),
          refreshTokenExpiresAt: DateTime.utc(2040),
        ),
      );
      final requestStarted = Completer<void>();
      final releaseResponse = Completer<void>();
      var requestCount = 0;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            requestCount++;
            expect(options.path, 'Auth/refresh-token');
            expect(options.data, {'refreshToken': originalRefreshToken});
            requestStarted.complete();
            await releaseResponse.future;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'httpStatusCode': 200,
                  'succeeded': true,
                  'message': 'Token refreshed successfully.',
                  'data': {
                    'token': accessToken,
                    'refreshToken': rotatedRefreshToken,
                    'refreshTokenExpiresAt': '2040-01-02T03:04:05+03:00',
                  },
                },
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        sessionStorage: storage,
        refreshDio: dio,
      );

      final firstRefresh = service.refreshToken();
      final secondRefresh = service.refreshToken();
      await requestStarted.future;

      expect(identical(firstRefresh, secondRefresh), isTrue);
      expect(requestCount, 1);

      releaseResponse.complete();
      final results = await Future.wait([firstRefresh, secondRefresh]);

      expect(results[0], same(results[1]));
      expect(results[0]?.accessToken, accessToken);
      expect(results[0]?.refreshToken, rotatedRefreshToken);
      expect(results[0]?.accessTokenExpiresAt, expectedExpiry);
      expect(
        results[0]?.refreshTokenExpiresAt,
        DateTime.utc(2040, 1, 2, 0, 4, 5),
      );
      expect(storage.savedSession, same(results[0]));
      expect(storage.clearCount, 0);
    });

    test(
      'clears the session when the server rejects its refresh token',
      () async {
        final storage = _FakeAuthSessionStorage(
          AuthSession(
            accessToken: _jwtWithExpiry(1900000000),
            refreshToken: 'invalid-refresh-token',
            accessTokenExpiresAt: DateTime.utc(2030),
            refreshTokenExpiresAt: DateTime.utc(2040),
          ),
        );
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.reject(
                DioException.badResponse(
                  statusCode: 400,
                  requestOptions: options,
                  response: Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 400,
                    data: {'message': 'Invalid refresh token.'},
                  ),
                ),
              );
            },
          ),
        );
        final service = AuthRefreshService(
          sessionStorage: storage,
          refreshDio: dio,
        );

        final result = await service.refreshToken();

        expect(result, isNull);
        expect(storage.clearCount, 1);
        expect(storage.session, isNull);
      },
    );

    test(
      'keeps the session when a successful response is incomplete',
      () async {
        final originalSession = AuthSession(
          accessToken: _jwtWithExpiry(1900000000),
          refreshToken: 'refresh-token-v1',
          accessTokenExpiresAt: DateTime.utc(2030),
          refreshTokenExpiresAt: DateTime.utc(2040),
        );
        final storage = _FakeAuthSessionStorage(originalSession);
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'httpStatusCode': 200,
                    'succeeded': true,
                    'message': 'Temporary incomplete response.',
                    'data': null,
                  },
                ),
              );
            },
          ),
        );
        final service = AuthRefreshService(
          sessionStorage: storage,
          refreshDio: dio,
        );

        final result = await service.refreshToken();

        expect(result, isNull);
        expect(storage.clearCount, 0);
        expect(storage.session, same(originalSession));
      },
    );

    test('does not overwrite a newer session with a stale response', () async {
      final originalSession = AuthSession(
        accessToken: _jwtWithExpiry(1900000000),
        refreshToken: 'refresh-token-v1',
        accessTokenExpiresAt: DateTime.utc(2030),
        refreshTokenExpiresAt: DateTime.utc(2040),
      );
      final newerSession = AuthSession(
        accessToken: _jwtWithExpiry(2100000000),
        refreshToken: 'new-login-refresh-token',
        accessTokenExpiresAt: DateTime.utc(2035),
        refreshTokenExpiresAt: DateTime.utc(2040),
      );
      final storage = _FakeAuthSessionStorage(originalSession);
      final requestStarted = Completer<void>();
      final releaseResponse = Completer<void>();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            requestStarted.complete();
            await releaseResponse.future;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'httpStatusCode': 200,
                  'succeeded': true,
                  'data': {
                    'token': _jwtWithExpiry(2000000000),
                    'refreshToken': 'refresh-token-v2',
                    'refreshTokenExpiresAt': '2040-01-02T03:04:05+03:00',
                  },
                },
              ),
            );
          },
        ),
      );
      final service = AuthRefreshService(
        sessionStorage: storage,
        refreshDio: dio,
      );

      final refresh = service.refreshToken();
      await requestStarted.future;
      storage.session = newerSession;
      releaseResponse.complete();

      final result = await refresh;

      expect(result, same(newerSession));
      expect(storage.session, same(newerSession));
      expect(storage.savedSession, isNull);
      expect(storage.clearCount, 0);
    });
  });
}

String _jwtWithExpiry(int secondsSinceEpoch) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'none', 'typ': 'JWT'})}.'
      '${encode({'exp': secondsSinceEpoch})}.';
}

class _FakeAuthSessionStorage extends AuthSessionStorage {
  _FakeAuthSessionStorage(this.session);

  AuthSession? session;
  AuthSession? savedSession;
  int clearCount = 0;

  @override
  Future<AuthSession?> getSession() async => session;

  @override
  Future<void> saveSession(AuthSession newSession) async {
    savedSession = newSession;
    session = newSession;
  }

  @override
  Future<void> clearSession() async {
    clearCount++;
    session = null;
  }
}
