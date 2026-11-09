import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'font_manager.dart';

/// Canonical font sizes used across the app.
///
/// Reference these tokens (with `.sp`) instead of raw numeric literals so
/// that the typography scale can be adjusted in this one place.
abstract final class AppFontSizes {
  static const double s10 = 10;
  static const double s11 = 11;
  static const double s12 = 12;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s15 = 15;
  static const double s16 = 16;
  static const double s17 = 17;
  static const double s18 = 18;
  static const double s19 = 19;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s48 = 48;
}

class AppTextStyles {
  // Base text style builder
  static TextStyle _baseStyle(
    BuildContext context, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: FontManager.getFontFamily(context),
    );
  }

  // Flexible style method with optional parameters
  static TextStyle custom(
    BuildContext context, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.blackClr,
  }) {
    return _baseStyle(
      context,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Single entry point for every text style in the app.
  ///
  /// The font family is inherited from [ThemeData] (via [FontManager]), so
  /// callers only pass the properties they need. This is the one choke point
  /// that allows future global typography changes (scale, family, weights)
  /// without touching call sites.
  static TextStyle of({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }


  // Size 20
  static TextStyle font20BlackSemiBold(BuildContext context) => custom(
    context,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.blackClr,
  );

  static TextStyle font20WhiteSemiBold(BuildContext context) => custom(
    context,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteClr,
  );

  // Size 18
  static TextStyle font18BlackSemiBold(BuildContext context) => custom(
    context,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.blackClr,
  );

  static TextStyle font18BlackMedium(BuildContext context) => custom(
    context,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.blackClr,
  );

  // Size 16
  static TextStyle font16BlackRegular(BuildContext context) =>
      custom(context, fontSize: 16, color: AppColors.blackClr);

  static TextStyle font16BlackMedium(BuildContext context) => custom(
    context,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.blackClr,
  );

  static TextStyle font16GreyRegular(BuildContext context) =>
      custom(context, fontSize: 16, color: AppColors.greyClr);

  static TextStyle font16WhiteRegular(BuildContext context) =>
      custom(context, fontSize: 16, color: AppColors.whiteClr);

  static TextStyle font16WhiteMedium(BuildContext context) => custom(
    context,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteClr,
  );

  static TextStyle font16BlueMedium(BuildContext context) => custom(
    context,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.blueClr,
  );

  static TextStyle font16GreenMedium(BuildContext context) => custom(
    context,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.greenClrW,
  );

  // Size 14
  static TextStyle font14BlackRegular(BuildContext context) =>
      custom(context, fontSize: 14, color: AppColors.blackClr);

  static TextStyle font14BlackMedium(BuildContext context) => custom(
    context,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.blackClr,
  );

  static TextStyle font14GreyRegular(BuildContext context) =>
      custom(context, fontSize: 14, color: AppColors.greyClr);

  static TextStyle font14WhiteRegular(BuildContext context) =>
      custom(context, fontSize: 14, color: AppColors.whiteClr);

  static TextStyle font14WhiteMedium(BuildContext context) => custom(
    context,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteClr,
  );

  static TextStyle font14PrimaryMedium(BuildContext context) => custom(
    context,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryClr,
  );

  static TextStyle font14BlueRegular(BuildContext context) =>
      custom(context, fontSize: 14, color: AppColors.blueClr);

  static TextStyle font14BlueMedium(BuildContext context) => custom(
    context,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.blueClr,
  );

  static TextStyle font14GreenRegular(BuildContext context) =>
      custom(context, fontSize: 14, color: AppColors.greenClrW);

  // Size 12
  static TextStyle font12BlackRegular(BuildContext context) =>
      custom(context, fontSize: 12, color: AppColors.blackClr);

  static TextStyle font12BlackMedium(BuildContext context) => custom(
    context,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.blackClr,
  );

  static TextStyle font12GreyRegular(BuildContext context) =>
      custom(context, fontSize: 12, color: AppColors.greyClr);

  static TextStyle font12WhiteRegular(BuildContext context) =>
      custom(context, fontSize: 12, color: AppColors.whiteClr);

  static TextStyle font12BlueRegular(BuildContext context) =>
      custom(context, fontSize: 12, color: AppColors.blueClr);

  static TextStyle font12BlueMedium(BuildContext context) => custom(
    context,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.blueClr,
  );

  // Size 10
  static TextStyle font10BlackRegular(BuildContext context) =>
      custom(context, fontSize: 10, color: AppColors.blackClr);

  static TextStyle font10BlackMedium(BuildContext context) => custom(
    context,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.blackClr,
  );

  static TextStyle font10GreyRegular(BuildContext context) =>
      custom(context, fontSize: 10, color: AppColors.greyClr);

  static TextStyle font10WhiteRegular(BuildContext context) =>
      custom(context, fontSize: 10, color: AppColors.whiteClr);

  // Size 8
  static TextStyle font8WhiteRegular(BuildContext context) =>
      custom(context, fontSize: 8, color: AppColors.whiteClr);

  static TextStyle font8GreyRegular(BuildContext context) =>
      custom(context, fontSize: 8, color: AppColors.greyClr);
}

// Extension for quick modifications
extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size.sp);
  TextStyle withValues({double? opacity}) =>
      copyWith(color: color?.withValues(alpha: opacity));
}
