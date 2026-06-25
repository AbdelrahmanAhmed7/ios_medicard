import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medicard/core/network/retry_inceptor.dart';
import 'package:medicard/core/services/app_language_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/constants.dart';
import '../helpers/shared_pref_helper.dart';
import 'connectivity_service.dart';
import 'error_mapping_interceptor.dart';

class DioFactory {
  DioFactory._();
  static Dio? _dio;
  static final List<Dio> _otherDioInstances = [];

  // Interceptor that adds Accept-Language header using AppLanguageManager
  static Interceptor get _acceptLanguageInterceptor {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Wait for AppLanguageManager to initialize
        await AppLanguageManager.instance.initializationFuture;

        final language = AppLanguageManager.instance.currentLanguage;
        debugPrint('🚀 Accept-Language injected: $language');
        options.headers['Accept-Language'] = language;
        return handler.next(options);
      },
    );
  }

  static Future<Dio> getDio() async {
    // Wait for AppLanguageManager to initialize before creating Dio
    await AppLanguageManager.instance.initializationFuture;

    if (_dio != null) return _dio!;

    const timeout = Duration(seconds: 15);
    _dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout;

    await _addHeaders();
    _addInterceptors(_dio!);
    return _dio!;
  }

  /// Get Dio instance for Medicard external API (no MCI auth headers)
  /// Medicard is a completely separate external API (api.medicardeg.com)
  /// and must NOT carry any MCI app Authorization token.
  static Future<Dio> getDioForMedicard() async {
    // Wait for AppLanguageManager to initialize before creating Dio
    await AppLanguageManager.instance.initializationFuture;

    const timeout = Duration(
      seconds: 30,
    ); // longer timeout for multipart uploads
    final dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout
      ..options.sendTimeout = timeout;

    // Only Accept header — no Authorization token
    dio.options.headers = {'Accept': 'application/json'};
    
    _addInterceptors(dio);
    _otherDioInstances.add(dio);
    return dio;
  }

  /// Get Dio instance with custom timeout for login requests
  static Future<Dio> getDioForLogin() async {
    // Wait for AppLanguageManager to initialize before creating Dio
    await AppLanguageManager.instance.initializationFuture;

    const timeout = Duration(seconds: 10);
    final dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout;

    // Add headers without token (login doesn't need token)
    dio.options.headers = {'Accept': 'application/json'};
    
    _addInterceptors(dio);
    _otherDioInstances.add(dio);
    return dio;
  }

  static Future<void> _addHeaders() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    _dio?.options.headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    _dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<void> setAcceptLanguage(String language) async {
    await AppLanguageManager.instance.setLanguage(language);
  }

  static void _addInterceptors(Dio dio) {
    // Add Accept-Language interceptor
    dio.interceptors.add(_acceptLanguageInterceptor);
    // Map low-level Dio exceptions to domain failures
    dio.interceptors.add(ErrorMappingInterceptor());

    // Add retry interceptor
    dio.interceptors.add(
      RetryInterceptor(
        connectivityService: ConnectivityService.instance,
        maxRetries: 3,
        baseDelay: const Duration(seconds: 2),
      ),
    );

    // Logger — debug mode only
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
  }
}
