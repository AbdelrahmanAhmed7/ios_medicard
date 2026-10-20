import 'package:flutter/material.dart';

import '../../../../core/theming/app_text_styles.dart';

/// Shared geometry and typography for the horizontal cards on the home page.
/// Logical pixels are intentional here so card spacing does not change with
/// the device width through ScreenUtil.
abstract final class HomeHorizontalCardStyle {
  static const double width = 270;
  static const double height = 274;
  static const double imageHeight = 148;
  static const double radius = 16;
  static const double clippedRadius = 15;

  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(10, 8, 10, 10);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets ratingPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 3,
  );

  static const double cardGap = 12;
  static const double sectionGap = 12;
  static const double textGap = 3;
  static const double footerGap = 8;

  static const Color ink = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFF6B7280);
  static const Color faint = Color(0xFF9CA3AF);
  static const Color primary = Color(0xFF3872B1);
  static const Color line = Color(0xFFE5E7EB);
  static const Color imageBackground = Color(0xFFEEF3FB);

  static TextStyle get ratingText =>
      AppTextStyles.of(fontSize: 11, fontWeight: FontWeight.w600, color: ink);

  static TextStyle get titleText =>
      AppTextStyles.of(fontSize: 13, fontWeight: FontWeight.w600, color: ink);

  static TextStyle get supportingText =>
      AppTextStyles.of(fontSize: 11, fontWeight: FontWeight.w400, color: muted);

  static TextStyle get actionText => AppTextStyles.of(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static TextStyle get priceBeforeText => AppTextStyles.of(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: faint,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle get priceAfterText => AppTextStyles.of(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: primary,
  );
}
