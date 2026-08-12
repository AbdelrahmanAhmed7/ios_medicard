import 'package:intl/intl.dart';

/// Formats raw date strings returned by the backend (e.g. `2026-07-28T 15:05:57`)
/// into a readable, localized date/time string.
class AppDateFormatter {
  static final List<DateFormat> _fallbackFormats = [
    DateFormat('yyyy-MM-dd HH:mm:ss'),
    DateFormat('yyyy-MM-dd HH:mm'),
    DateFormat('yyyy-MM-dd'),
  ];

  /// Parses a backend date string into a [DateTime]. Returns `null` when the
  /// value cannot be parsed.
  static DateTime? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().replaceAll('T ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed;
    for (final format in _fallbackFormats) {
      try {
        return format.parseStrict(normalized);
      } catch (_) {
        // Try the next format.
      }
    }
    return null;
  }

  /// Returns the date string unchanged when it cannot be parsed.
  static String _safe(String? value, String Function(DateTime) builder) {
    final date = tryParse(value);
    if (date == null) return value ?? '';
    return builder(date);
  }

  static String _localeCode(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return 'en';
    return languageCode.length >= 2 ? languageCode.substring(0, 2) : 'en';
  }

  /// Full readable format: "28 Jul 2026, 3:05 PM" / "28 يوليو 2026، 3:05 م"
  static String formatDateTime(String? value, String? languageCode) {
    final locale = _localeCode(languageCode);
    return _safe(
      value,
      (date) {
        try {
          return DateFormat('dd MMM yyyy, h:mm a', locale).format(date);
        } catch (_) {
          return DateFormat('dd/MM/yyyy, h:mm a').format(date);
        }
      },
    );
  }

  /// Compact format used in narrow cards:
  /// "28 Jul, 3:05 PM" / "28 يوليو، 3:05 م"
  static String formatDateTimeShort(String? value, String? languageCode) {
    final locale = _localeCode(languageCode);
    return _safe(
      value,
      (date) {
        try {
          return DateFormat('dd MMM, h:mm a', locale).format(date);
        } catch (_) {
          return DateFormat('dd/MM/yyyy HH:mm').format(date);
        }
      },
    );
  }
}