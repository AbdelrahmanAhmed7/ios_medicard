import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared horizontal geometry for page navigation, in either text direction.
abstract final class AppHeaderSpacing {
  static double get start => 4.w;
  static double get buttonWidth => 48.w;
  static double get contentStart => start + buttonWidth;

  /// Offset that lines a title block up with the visible back arrow (the icon
  /// is centered inside the [buttonWidth] tap target).
  static double get titleInset => (buttonWidth - 22.sp) / 2;

  static EdgeInsetsDirectional padding({
    required double top,
    required double bottom,
  }) => EdgeInsetsDirectional.fromSTEB(start, top, 16.w, bottom);
}

class AppHeaderBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;

  const AppHeaderBackButton({
    super.key,
    required this.onPressed,
    this.color = const Color(0xFF111827),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppHeaderSpacing.buttonWidth,
      height: 48,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: color, size: 22.sp),
      ),
    );
  }
}
