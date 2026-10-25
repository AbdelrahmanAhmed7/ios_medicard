import 'package:flutter/material.dart';

import 'app_toast.dart';

/// Compatibility type for older call sites. Messages are rendered through the
/// app-wide toast overlay; no [SnackBar] or [ScaffoldMessenger] is used.
enum SnackBarType { success, error, warning, info }

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
  SnackBarType? type,
  VoidCallback? onAction,
  String? actionLabel,
}) {
  final effectiveType =
      type ?? (isError ? SnackBarType.error : SnackBarType.success);
  switch (effectiveType) {
    case SnackBarType.success:
      showSuccessToast(message);
    case SnackBarType.error:
      showErrorToast(message);
    case SnackBarType.warning:
      showWarningToast(message);
    case SnackBarType.info:
      showInfoToast(message);
  }
}

void showSimpleToast(BuildContext context, String message) {
  showInfoToast(message);
}
