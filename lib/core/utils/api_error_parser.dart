import 'package:dio/dio.dart';

String parseApiError(dynamic error) {
  try {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        // Format 1: { "errors": { "Field": ["msg1", "msg2"] } }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = errors.values
              .expand((e) => e is List ? e : [e])
              .map((e) => e.toString())
              .join('\n');
          if (messages.isNotEmpty) return messages;
        }
        // Format 2: { "message": "Incorrect password." }
        if (data['message'] is String &&
            (data['message'] as String).isNotEmpty) {
          return data['message'] as String;
        }
      }
    }
  } catch (_) {}
  return 'Something went wrong. Please try again.';
}
