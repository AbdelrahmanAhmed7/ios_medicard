import 'package:dio/dio.dart';

import '../../../../../core/network/app_failure.dart';

String notificationErrorMessage(Object error) {
  if (error is DioException) {
    final responseMessage = _responseMessage(error.response?.data);
    if (responseMessage != null) return responseMessage;

    final mappedError = error.error;
    if (mappedError is AppFailure) return _failureMessage(mappedError);

    final message = error.message;
    if (message != null && message.trim().isNotEmpty) return message;
  }

  if (error is AppFailure) return _failureMessage(error);

  final message = error.toString();
  if (message.trim().isEmpty || message == 'null') {
    return 'Something went wrong. Please try again.';
  }

  return message;
}

String? _responseMessage(Object? data) {
  if (data is! Map) return null;

  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) return message;

  final errors = data['errors'];
  if (errors is Map) {
    final messages = errors.values
        .expand((error) => error is List ? error : [error])
        .map((error) => error.toString())
        .where((error) => error.trim().isNotEmpty)
        .join('\n');

    if (messages.isNotEmpty) return messages;
  }

  return null;
}

String _failureMessage(AppFailure failure) {
  switch (failure.type) {
    case AppFailureType.network:
      return 'Connection error. Please check your internet connection.';
    case AppFailureType.timeout:
      return 'Connection timeout. Please try again.';
    case AppFailureType.unauthorized:
      return 'Unauthorized. Please log in again.';
    case AppFailureType.forbidden:
      return 'Access denied.';
    case AppFailureType.notFound:
      return 'Endpoint not found.';
    case AppFailureType.server:
      return 'Server error. Please try again later.';
    case AppFailureType.unexpected:
      return failure.message ?? 'Something went wrong. Please try again.';
  }
}
