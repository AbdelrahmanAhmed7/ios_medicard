import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared outer gutters used by top-level screen content.
abstract final class AppSpacing {
  static const double pageHorizontalValue = 16;

  static double get pageHorizontal => pageHorizontalValue.w;

  static EdgeInsets get pageHorizontalInsets =>
      EdgeInsets.symmetric(horizontal: pageHorizontal);
}
