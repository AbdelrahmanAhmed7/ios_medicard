import 'package:flutter/material.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Shared geometry and typography for the horizontal cards on the home page.
/// Logical pixels are intentional here so card spacing does not change with
/// the device width through ScreenUtil.
abstract final class HomeHorizontalCardStyle {
  static const double width = 270;
  static const double height = 274;
  static const double imageHeight = 148;
  static const double radius = 16;
  static const double clippedRadius = 15;
  static const double borderWidth = AppSpacing.compactCardBorderWidth;

  /// Visible space between a card's footer actions and its bottom border.
  /// Footer rows are bottom-anchored, so this stays identical across text
  /// scales instead of absorbing whatever height is left in the card.
  static const double footerBottomInset =
      AppSpacing.compactCardFooterBottomInset;
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(
    10,
    8,
    10,
    footerBottomInset - borderWidth,
  );
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets ratingPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 3,
  );

  static const double cardGap = 12;
  static const double sectionGap = 12;
  static const double textGap = 3;
  static const double footerGap = 8;

  static const Color ink = AppColors.exactFF1A1A2E;
  static const Color muted = AppColors.exactFF6B7280;
  static const Color faint = AppColors.exactFF9CA3AF;
  static const Color primary = AppColors.brandBlueClr;
  static const Color line = AppColors.exactFFE5E7EB;
  static const Color imageBackground = AppColors.exactFFEEF3FB;

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

