import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Keeps hover and keyboard-focus feedback consistent across every app
/// dropdown without changing the hover treatment of unrelated controls.
class AppDropdownTheme extends StatelessWidget {
  final Widget child;

  const AppDropdownTheme({super.key, required this.child});

  /// Explicit state colors for Material 3 menu entries such as
  /// [MenuItemButton]. Unlike an ambient theme, this style travels with the
  /// menu entry when Flutter renders the menu in an overlay.
  static ButtonStyle menuItemButtonStyle({bool isSelected = false}) =>
      ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) return null;
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.focused)) {
            return AppColors.dropdownFocusClr;
          }
          if (states.contains(WidgetState.hovered)) {
            return isSelected
                ? AppColors.dropdownFocusClr
                : AppColors.dropdownHoverClr;
          }
          return isSelected ? AppColors.dropdownHoverClr : Colors.transparent;
        }),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        hoverColor: AppColors.dropdownHoverClr,
        focusColor: AppColors.dropdownFocusClr,
      ),
      child: child,
    );
  }
}

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
