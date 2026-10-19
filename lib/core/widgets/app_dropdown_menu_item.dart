import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Dropdown option with the app's option typography.
///
/// A bare `DropdownMenuItem(child: Text(...))` inherits the ambient
/// `DefaultTextStyle` (`TextTheme.bodyMedium` inside a `Material`), so option
/// text used to render in the legacy navy while the selected value rendered in
/// the design-system ink. Every dropdown in the app should build its options
/// with this widget so open-menu rows and the closed-button value agree.
class AppDropdownMenuItem<T> extends DropdownMenuItem<T> {
  AppDropdownMenuItem({
    super.key,
    required String label,
    super.value,
    super.enabled = true,
    super.onTap,
    super.alignment,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.inkClr,
  }) : super(
         child: Text(
           label,
           maxLines: 1,
           overflow: TextOverflow.ellipsis,
           style: AppTextStyles.of(
             fontSize: fontSize.sp,
             fontWeight: fontWeight,
             color: color,
             height: 1.3,
           ),
         ),
       );
}