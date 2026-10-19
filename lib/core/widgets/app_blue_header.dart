import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_text_styles.dart';

/// Content height shared by the primary BottomNavigationBar screens.
/// The system status-bar height is added by [SafeArea].
const double kMainTabHeaderContentHeight = 120;

/// Reusable blue header used across the app.
///
/// Covers every variation found in the codebase:
/// - Flat vs rounded bottom corners
/// - Optional back button (auto-pops if [onBack] is null and [showBack] is true)
/// - Optional title + subtitle
/// - Optional right-side actions
/// - Optional arbitrary bottom content (e.g. logo row on provider page)
///
/// Usage examples:
///
/// Simple titled screen with back button:
/// ```dart
/// AppBlueHeader(title: 'Cart')
/// ```
///
/// No back button (profile / home tab):
/// ```dart
/// AppBlueHeader(title: 'My Profile', showBack: false)
/// ```
///
/// With right-side action widget:
/// ```dart
/// AppBlueHeader(
///   title: 'Choose Provider',
///   actions: [IconButton(icon: Icon(Icons.share), onPressed: ...)],
/// )
/// ```
///
/// With extra bottom content (provider info row etc.):
/// ```dart
/// AppBlueHeader(
///   showBack: true,
///   bottomChild: MyProviderInfoRow(...),
/// )
/// ```
class AppBlueHeader extends StatelessWidget {
  /// The primary title shown in white. Pass null to omit.
  final String? title;

  /// Optional subtitle shown below the title in smaller white text.
  final String? subtitle;

  /// Whether to show the back button. Defaults to `true`.
  final bool showBack;

  /// Custom back-button handler. Falls back to `Navigator.of(context).pop()`
  /// when null.
  final VoidCallback? onBack;

  /// Widgets placed at the end of the title row (right side).
  final List<Widget>? actions;

  /// Arbitrary widget rendered below the title row.
  /// Use this for complex headers (provider info, search bar, etc.).
  final Widget? bottomChild;

  /// Bottom corner radius. Defaults to 24. Set to 0 for flat.
  final double bottomRadius;

  /// Background color. Defaults to 0xFF3872B1.
  final Color color;

  /// Inner vertical padding below the safe area. Defaults to 16.h top / 24.h bottom.
  final EdgeInsetsGeometry? padding;

  /// Optional fixed content height below the system status bar.
  final double? contentHeight;

  const AppBlueHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.bottomChild,
    this.bottomRadius = 24,
    this.color = const Color(0xFF3872B1),
    this.padding,
    this.contentHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: bottomRadius > 0
            ? BorderRadius.only(
                bottomLeft: Radius.circular(bottomRadius),
                bottomRight: Radius.circular(bottomRadius),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: contentHeight,
          child: Padding(
            padding:
                padding ??
                EdgeInsetsDirectional.fromSTEB(
                  showBack ? AppHeaderSpacing.start : 20.w,
                  8.h,
                  16.w,
                  bottomChild != null ? 16.h : 20.h,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: contentHeight != null && bottomChild == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ──────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showBack)
                      AppHeaderBackButton(
                        color: Colors.white,
                        onPressed: onBack ?? () => Navigator.of(context).pop(),
                      ),
                    if (title != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title!,
                              style: AppTextStyles.of(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 2.h),
                              Text(
                                subtitle!,
                                style: AppTextStyles.of(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    ...?actions,
                  ],
                ),

                // ── Optional bottom content ─────────────────────────────────
                if (bottomChild != null) ...[
                  SizedBox(height: 12.h),
                  bottomChild!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
