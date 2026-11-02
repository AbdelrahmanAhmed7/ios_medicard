import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';

/// Shared surface and interaction theme for dropdowns throughout the app.
class AppDropdownTheme extends StatelessWidget {
  final Widget child;

  const AppDropdownTheme({super.key, required this.child});

  static const Color menuColor = Colors.white;
  static const double menuRadius = 12;
  static const double menuElevation = 4;
  static const BorderRadius dropdownBorderRadius = BorderRadius.all(
    Radius.circular(menuRadius),
  );
  static const RoundedRectangleBorder menuShape = RoundedRectangleBorder(
    borderRadius: dropdownBorderRadius,
    side: BorderSide(color: AppColors.lineClr),
  );

  static MenuStyle get menuStyle => const MenuStyle(
    backgroundColor: WidgetStatePropertyAll(menuColor),
    elevation: WidgetStatePropertyAll(menuElevation),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    shape: WidgetStatePropertyAll(menuShape),
  );

  static TextStyle menuItemTextStyle({
    bool selected = false,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) => AppTextStyles.of(
    fontSize: (fontSize ?? 14).sp,
    fontWeight: fontWeight ?? (selected ? FontWeight.w600 : FontWeight.w500),
    color: color ?? (selected ? AppColors.brandBlueClr : AppColors.inkClr),
    height: 1.3,
  );

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
        canvasColor: menuColor,
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
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) : super(
         child: Text(
           label,
           maxLines: 1,
           overflow: TextOverflow.ellipsis,
           style: AppDropdownTheme.menuItemTextStyle(
             fontSize: fontSize,
             fontWeight: fontWeight,
             color: color,
           ),
         ),
       );
}
