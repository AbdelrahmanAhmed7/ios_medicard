import 'package:flutter/material.dart';

import '../services/haptic_feedback_service.dart';

enum ToastType { success, error, warning, info }

// ── Global navigator key — set this on MaterialApp.router ──────────────────
final GlobalKey<NavigatorState> toastNavigatorKey = GlobalKey<NavigatorState>();

Color _backgroundColorFor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return const Color(0xFF2E7D32);
    case ToastType.error:
      return const Color(0xFFC62828);
    case ToastType.warning:
      return const Color(0xFFE65100);
    case ToastType.info:
      return const Color(0xFF1565C0);
  }
}

IconData _iconFor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Icons.check_circle_outline;
    case ToastType.error:
      return Icons.error_outline;
    case ToastType.warning:
      return Icons.warning_amber_outlined;
    case ToastType.info:
      return Icons.info_outline;
  }
}

void showToast(
  String message, {
  ToastType type = ToastType.info,
  bool isError = false,
}) {
  final effectiveType = isError ? ToastType.error : type;

  // haptic feedback
  if (effectiveType == ToastType.error) {
    HapticFeedbackService.instance.heavyImpact();
  } else if (effectiveType == ToastType.success) {
    HapticFeedbackService.instance.lightImpact();
  }

  final overlay = toastNavigatorKey.currentState?.overlay;
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastWidget(
      message: message,
      type: effectiveType,
      backgroundColor: _backgroundColorFor(effectiveType),
      icon: _iconFor(effectiveType),
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

/// Shorthand helpers
void showSuccessToast(String message) =>
    showToast(message, type: ToastType.success);

void showErrorToast(String message) =>
    showToast(message, type: ToastType.error, isError: true);

void showInfoToast(String message) => showToast(message, type: ToastType.info);

void showWarningToast(String message) =>
    showToast(message, type: ToastType.warning);

// ── Internal toast widget ───────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // auto-dismiss after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
