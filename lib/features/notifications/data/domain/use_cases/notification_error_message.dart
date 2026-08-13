import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/network/app_failure.dart';
import '../../../../../core/utils/api_error_parser.dart';

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
    return parseApiError(message);
  }

  return parseApiError(message);
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
      return 'errors.no_internet'.tr();
    case AppFailureType.timeout:
    case AppFailureType.connectionTimeout:
    case AppFailureType.transferTimeout:
      return 'errors.timeout_error'.tr();
    case AppFailureType.unauthorized:
      return 'errors.session_expired'.tr();
    case AppFailureType.forbidden:
      return 'errors.forbidden_error'.tr();
    case AppFailureType.notFound:
      return 'errors.not_found_error'.tr();
    case AppFailureType.server:
      return 'errors.server_error'.tr();
    case AppFailureType.cancelled:
    case AppFailureType.unexpected:
      return parseApiError(failure.message ?? '');
  }
}
