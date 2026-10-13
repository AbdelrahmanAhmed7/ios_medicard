import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:medicard/core/network/app_failure.dart';

String parseApiError(dynamic error) {
  try {
    if (error is String && error.trim().isNotEmpty) {
      return friendlyApiMessage(error);
    }

    if (error is SocketException) {
      return 'errors.no_internet'.tr();
    }

    if (error is AppFailure) {
      if (error.message?.trim().isNotEmpty == true) {
        return friendlyApiMessage(error.message!);
      }
      final failureMessage = _messageForAppFailure(error);
      if (failureMessage != null) return failureMessage;
    }

    if (error is DioException) {
      final data = error.response?.data;
      final statusCode = error.response?.statusCode;
      final mappedError = error.error;

      // Network-level failures (no internet / unreachable host).
      if (error.type == DioExceptionType.connectionError ||
          (error.type == DioExceptionType.unknown &&
              error.error is IOException)) {
        return 'errors.no_internet'.tr();
      }

      // Timeouts (connection/send/receive) get a specific friendly message.
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'errors.timeout_error'.tr();
      }

      // Server errors (>= 500) always fall back to a friendly generic
      // message — the server response body is usually a raw technical message.
      if (statusCode != null && statusCode >= 500) {
        return 'errors.temporary_service_issue'.tr();
      }

      if (mappedError is AppFailure) {
        final failureMessage = _messageForAppFailure(mappedError);
        if (failureMessage != null) return failureMessage;
      }

      if (data is Map) {
        // ASP.NET validation responses return every failing field at once.
        // Surface only the most relevant single backend message instead of
        // concatenating all of them into one confusing block.
        final errorMessage = _pickRelevantFieldError(data['errors']);
        if (errorMessage.isNotEmpty) return friendlyApiMessage(errorMessage);

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
  } catch (parseError, stackTrace) {
    if (kDebugMode) {
      debugPrint('[ApiErrorParser] Failed to parse error: $parseError');
      debugPrint('$stackTrace');
    }
  }
  return 'errors.request_failed'.tr();
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

/// Picks the single most relevant field error from a field-keyed errors map.
/// Identity fields (phone/card/email) come first since they are what users
/// usually mistype, then credential fields, then whatever arrives first.
String _pickRelevantFieldError(dynamic errors) {
  if (errors == null) return '';
  if (errors is! Map) return _extractMessages(errors);

  final messagesByKey = <String, String>{};
  errors.forEach((key, value) {
    final message = _extractMessages(value);
    if (message.isNotEmpty) {
      messagesByKey[key.toString().toLowerCase()] = message;
    }
  });
  if (messagesByKey.isEmpty) return '';

  const priority = [
    'phonenumber',
    'cardnumber',
    'email',
    'password',
    'confirmpassword',
    'nationalid',
    'passportnumber',
  ];
  for (final key in priority) {
    final message = messagesByKey[key];
    if (message != null) return message;
  }
  return messagesByKey.values.first;
}

String friendlyApiMessage(String message) {
  final normalized = message.trim();
  final lower = normalized.toLowerCase();

  if (_isGenericMessage(normalized)) {
    return 'errors.request_failed'.tr();
  }

  if (lower.contains('invalid phone number format')) {
    return 'auth.register.phoneNumberInvalid'.tr();
  }

  if (lower.contains('national id or passport number is required')) {
    return 'auth.register.nationalIdOrPassportRequired'.tr();
  }

  if (lower.contains('user not found') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid username or password') ||
      lower.contains('wrong username or password') ||
      normalized.contains('بيانات الدخول غير صحيحة') ||
      normalized.contains('المستخدم غير موجود') ||
      normalized.contains('مستخدم غير موجود')) {
    return 'errors.invalid_credentials'.tr();
  }

  if (lower.contains('cartitempricemissing') ||
      lower.contains('cart item price missing')) {
    return 'cart.some_prices_missing'.tr();
  }

  if (lower.contains('current password') &&
      (lower.contains('incorrect') ||
          lower.contains('invalid') ||
          lower.contains('wrong'))) {
    return 'change_password.current_password_incorrect'.tr();
  }

  if (lower.contains('password') &&
      (lower.contains('incorrect') ||
          lower.contains('invalid') ||
          lower.contains('wrong'))) {
    return 'change_password.current_password_incorrect'.tr();
  }

  if (lower.contains('servicenotfound') ||
      lower.contains('service not found')) {
    return 'cart.service_not_available'.tr();
  }

  if (lower.contains('invalid invoice response')) {
    return 'cart.invalid_invoice_response'.tr();
  }

  if (lower.contains('invoicealreadyused') ||
      lower.contains('invoice already used')) {
    return 'activity.invoice_already_used'.tr();
  }

  return normalized;
}

bool _isGenericMessage(String message) {
  final lower = message.trim().toLowerCase();
  return lower == 'something went wrong' ||
      lower == 'something went wrong. please try again.' ||
      lower == 'an unexpected error occurred' ||
      lower == 'unexpected error occurred.' ||
      lower == 'حدث خطأ غير متوقع' ||
      lower == 'حدث خطأ ما. يرجى المحاولة مرة أخرى.' ||
      lower.contains('unexpected error') ||
      lower.contains('unknown error') ||
      lower.contains('internal error') ||
      lower.contains('an unexpected error occurred');
}

String? _messageForStatusCode(int? statusCode) {
  if (statusCode != null && statusCode >= 500) {
    return 'errors.temporary_service_issue'.tr();
  }

  return switch (statusCode) {
    400 => 'errors.validation_failed'.tr(),
    401 => 'errors.session_expired'.tr(),
    403 => 'errors.forbidden_error'.tr(),
    404 => 'errors.not_found_error'.tr(),
    405 => 'errors.action_unavailable'.tr(),
    _ => null,
  };
}

String? _messageForAppFailure(AppFailure failure) {
  return switch (failure.type) {
    AppFailureType.network => 'errors.no_internet'.tr(),
    AppFailureType.timeout ||
    AppFailureType.connectionTimeout ||
    AppFailureType.transferTimeout => 'errors.timeout_error'.tr(),
    AppFailureType.unauthorized => 'errors.session_expired'.tr(),
    AppFailureType.forbidden => 'errors.forbidden_error'.tr(),
    AppFailureType.notFound => 'errors.not_found_error'.tr(),
    AppFailureType.server => 'errors.temporary_service_issue'.tr(),
    AppFailureType.cancelled => null,
    AppFailureType.unexpected => null,
  };
}
