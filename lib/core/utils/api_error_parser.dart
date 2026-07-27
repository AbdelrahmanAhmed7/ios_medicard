import 'package:dio/dio.dart';
import 'package:medicard/core/network/app_failure.dart';

String parseApiError(dynamic error) {
  try {
    if (error is String && error.trim().isNotEmpty) {
      return friendlyApiMessage(error);
    }

    if (error is AppFailure && error.message?.trim().isNotEmpty == true) {
      return friendlyApiMessage(error.message!);
    }

    if (error is DioException) {
      final data = error.response?.data;
      final statusCode = error.response?.statusCode;
      final mappedError = error.error;
      if (mappedError is AppFailure &&
          mappedError.message?.trim().isNotEmpty == true) {
        return friendlyApiMessage(mappedError.message!);
      }

      if (data is Map) {
        final errorMessages = _extractMessages(data['errors']);
        if (errorMessages.isNotEmpty) return friendlyApiMessage(errorMessages);

        if (data['message'] is String &&
            (data['message'] as String).trim().isNotEmpty) {
          return friendlyApiMessage(data['message'] as String);
        }

        final title = data['title'];
        if (title is String && title.trim().isNotEmpty) {
          return friendlyApiMessage(title);
        }
      }

      if (data is List) {
        final messages = _extractMessages(data);
        if (messages.isNotEmpty) return friendlyApiMessage(messages);
      }

      final statusMessage = _messageForStatusCode(statusCode);
      if (statusMessage != null) return statusMessage;
    }
  } catch (_) {}
  return 'Something went wrong. Please try again.';
}

String _extractMessages(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Iterable) {
    return value
        .map(_extractMessages)
        .where((message) => message.isNotEmpty)
        .join('\n');
  }
  if (value is Map) {
    return value.values
        .map(_extractMessages)
        .where((message) => message.isNotEmpty)
        .join('\n');
  }
  return value.toString().trim();
}

String friendlyApiMessage(String message) {
  final normalized = message.trim();
  final lower = normalized.toLowerCase();

  if (lower.contains('cartitempricemissing') ||
      lower.contains('cart item price missing')) {
    return 'Some cart items are still missing prices. Please choose providers for them and try again.';
  }

  if (lower.contains('current password') &&
      (lower.contains('incorrect') ||
          lower.contains('invalid') ||
          lower.contains('wrong'))) {
    return 'Current password is incorrect';
  }

  if (lower.contains('password') &&
      (lower.contains('incorrect') ||
          lower.contains('invalid') ||
          lower.contains('wrong'))) {
    return 'Current password is incorrect';
  }

  return normalized;
}

String? _messageForStatusCode(int? statusCode) {
  if (statusCode != null && statusCode >= 500) {
    return 'Server error. Please try again later.';
  }

  return switch (statusCode) {
    400 => 'Please check the entered data and try again.',
    401 => 'Your session has expired. Please log in again.',
    403 => 'You do not have permission to perform this action.',
    404 => 'The requested service is unavailable.',
    405 => 'This action is currently unavailable. Please try again later.',
    _ => null,
  };
}
