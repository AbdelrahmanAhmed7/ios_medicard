import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared outer gutters used by top-level screen content.
abstract final class AppSpacing {
  static const double pageHorizontalValue = 16;

  /// Shared compact-card geometry. Keeping these values in logical pixels
  /// prevents ScreenUtil and device text settings from changing the visible
  /// space below bottom-anchored actions.
  static const double compactCardFooterBottomInset = 18;
  static const double compactCardBorderWidth = 1;
  static const double compactCardMaxTextScale = 1.2;

  static double get pageHorizontal => pageHorizontalValue.w;

  static EdgeInsets get pageHorizontalInsets =>
      EdgeInsets.symmetric(horizontal: pageHorizontal);
}
