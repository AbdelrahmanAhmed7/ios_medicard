import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medicard/core/network/retry_inceptor.dart';
import 'package:medicard/core/services/app_language_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'error_mapping_interceptor.dart';

/// Base URL shared by all Medicard v2 API instances.
const _medicardBaseUrl = 'https://medicard-api-v2.medicardeg.com/api/';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  // ── Accept-Language interceptor ────────────────────────────────────────────

  static Interceptor get _acceptLanguageInterceptor {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        await AppLanguageManager.instance.initializationFuture;
        final language = AppLanguageManager.instance.currentLanguage;
        options.headers['Accept-Language'] = language;
        return handler.next(options);
      },
    );
  }

  // ── Pretty logger (debug only — never logs Authorization header) ───────────

  static Interceptor get _logger => PrettyDioLogger(
    requestHeader: false, // keeps tokens out of logs
    requestBody: true,
    responseHeader: false,
    responseBody: false,
    error: true,
    compact: false,
    maxWidth: 90,
    // Login and refresh payloads contain credentials/tokens. Skipping these
    // exchanges entirely prevents request/response body token leakage.
    filter: (options, args) {
      final path = options.path.toLowerCase();
      return !path.contains('auth/login') &&
          !path.contains('auth/register') &&
          !path.contains('auth/refresh-token');
    },
  );

  // ── Main singleton Dio ─────────────────────────────────────────────────────

  /// Primary Dio used for all authenticated API calls.
  /// The [AuthInterceptor] is added to this instance by [setupServiceLocator]
  /// after this method returns.
  static Future<Dio> getDio() async {
    await AppLanguageManager.instance.initializationFuture;
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: _medicardBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    _addCommonInterceptors(_dio!);
    return _dio!;
  }

  // ── Refresh-token Dio ──────────────────────────────────────────────────────

  /// Bare Dio used only for POST /api/Auth/refresh-token.
  /// Never carries the [AuthInterceptor] so refresh calls never recurse.
  static Dio createRefreshDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _medicardBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(_acceptLanguageInterceptor);
    dio.interceptors.add(ErrorMappingInterceptor());
    if (kDebugMode) dio.interceptors.add(_logger);
    return dio;
  }

  // ── External card API (no auth) ────────────────────────────────────────────

  static Future<Dio> getDioForMedicard() async {
    await AppLanguageManager.instance.initializationFuture;
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    _addCommonInterceptors(dio);
    return dio;
  }

  // ── Login/register Dio (no auth) ───────────────────────────────────────────

  static Future<Dio> getDioForLogin() async {
    await AppLanguageManager.instance.initializationFuture;
    final dio = Dio(
      BaseOptions(
        baseUrl: _medicardBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
    _addCommonInterceptors(dio);
    return dio;
  }

  // ── Token helpers ──────────────────────────────────────────────────────────

  /// Syncs the singleton Dio default header after a successful login.
  /// Token value is intentionally not logged.
  static void setTokenIntoHeaderAfterLogin(String token) {
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Removes the Authorization header from the singleton Dio on logout.
  static void clearTokenFromHeader() {
    _dio?.options.headers.remove('Authorization');
  }

  static Future<void> setAcceptLanguage(String language) async {
    await AppLanguageManager.instance.setLanguage(language);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static void _addCommonInterceptors(Dio dio) {
    dio.interceptors.add(_acceptLanguageInterceptor);
    dio.interceptors.add(ErrorMappingInterceptor());
    dio.interceptors.add(
      RetryInterceptor(
        maxRetries: 2,
        baseDelay: const Duration(milliseconds: 500),
      ),
    );
    if (kDebugMode) dio.interceptors.add(_logger);
  }
}
