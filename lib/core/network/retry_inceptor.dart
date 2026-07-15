import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_failure.dart';
import 'dio_factory.dart';

/// Interceptor to retry failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Automatic retries are restricted to idempotent requests. Replaying a
    // POST/PUT could duplicate a server-side operation after a lost response.
    if (!_shouldRetry(err) || !_isIdempotent(err.requestOptions.method)) {
      return super.onError(err, handler);
    }

    final initialRetryCount =
        err.requestOptions.extra['retryCount'] as int? ?? 0;
    final dio = await _getDioInstance();
    var lastError = err;

    for (var retryCount = initialRetryCount; retryCount < maxRetries; retryCount++) {
      final attempt = retryCount + 1;
      final delay = Duration(
        milliseconds: baseDelay.inMilliseconds * (1 << retryCount),
      );

      if (kDebugMode) {
        debugPrint(
          '[RetryInterceptor] retry $attempt/$maxRetries for '
          '${err.requestOptions.method} ${err.requestOptions.path} '
          'after ${delay.inMilliseconds}ms',
        );
      }
      await Future.delayed(delay);

      final retryOptions = err.requestOptions.copyWith(
        extra: {
          ...err.requestOptions.extra,
          'retryCount': attempt,
        },
      );

      try {
        // fetch() uses the configured adapter directly, avoiding recursive
        // interceptor re-entry while preserving the authorized request.
        final response = await dio.fetch<dynamic>(retryOptions);
        if (kDebugMode) {
          debugPrint(
            '[RetryInterceptor] retry $attempt succeeded '
            '(status=${response.statusCode})',
          );
        }
        return handler.resolve(response);
      } on DioException catch (retryError) {
        lastError = retryError;
        if (kDebugMode) {
          debugPrint(
            '[RetryInterceptor] retry $attempt failed '
            '(type=${retryError.type}, status=${retryError.response?.statusCode})',
          );
        }
        if (!_shouldRetry(retryError)) break;
      }
    }

    return handler.next(lastError);
  }

  /// Check if error should be retried
  bool _shouldRetry(DioException err) {
    final mappedFailure = err.error;
    if (mappedFailure is AppFailure) {
      return mappedFailure.type == AppFailureType.network ||
          mappedFailure.type == AppFailureType.timeout ||
          mappedFailure.type == AppFailureType.connectionTimeout ||
          mappedFailure.type == AppFailureType.transferTimeout;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.type == DioExceptionType.unknown &&
            err.error != null &&
            err.error.toString().contains('SocketException'));
  }

  bool _isIdempotent(String method) {
    final normalized = method.toUpperCase();
    return normalized == 'GET' || normalized == 'HEAD';
  }

  /// Get Dio instance from factory
  Future<Dio> _getDioInstance() async {
    return await DioFactory.getDio();
  }
}
