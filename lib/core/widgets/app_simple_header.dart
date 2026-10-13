import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_text_styles.dart';

/// Lightweight page header replacing the big blue [AppBlueHeader] on inner
/// screens. White background, guarded back button, centered dark title and
/// optional bottom content. The home tab headers stay blue.
class AppSimpleHeader extends StatelessWidget {
  /// Centered title. Pass null to omit.
  final String? title;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// Whether to show the back button. Defaults to `true`.
  final bool showBack;

  /// Custom back-button handler. Falls back to a guarded pop.
  final VoidCallback? onBack;

  /// Widgets placed at the end of the title row.
  final List<Widget>? actions;

  /// Arbitrary widget rendered below the title row.
  final Widget? bottomChild;

  const AppSimpleHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.bottomChild,
  });

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    // Guarded: a bare pop() crashes go_router when this is the last page
    // (deep link / restored state).
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Transparent on purpose: blends with each screen's own background color
    // so the header and body look like one surface.
    return SafeArea(
      bottom: false,
      child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, bottomChild != null ? 12.h : 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBack)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF111827),
                        size: 22.sp,
                      ),
                      onPressed: () => _handleBack(context),
                    )
                  else
                    SizedBox(width: 8.w),
                  if (title != null)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.of(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              subtitle!,
                              textAlign: TextAlign.left,
                              style: AppTextStyles.of(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
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
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ],
              ),
              if (bottomChild != null) ...[
                SizedBox(height: 8.h),
                bottomChild!,
              ],
            ],
          ),
        ),
      );
  }
}
