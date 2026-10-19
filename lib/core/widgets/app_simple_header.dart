import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_spacing.dart';
import '../theming/app_text_styles.dart';

/// Lightweight page header replacing the big blue [AppBlueHeader] on inner
/// screens. White background, guarded back button, start-aligned dark title and
/// optional bottom content. The home tab headers stay blue.
///
/// When a [subtitle] is provided the back button sits on its own row and the
/// title/subtitle block is rendered underneath it, starting on the same edge as
/// the back arrow (large-title layout). Headers with a title only keep the
/// title inline with the back button.
class AppSimpleHeader extends StatelessWidget {
  /// Start-aligned title. Pass null to omit.
  final String? title;

  /// Optional subtitle below the title. When set, the title moves below the
  /// back button so it starts on the back arrow's edge.
  final String? subtitle;

  /// Whether to show the back button. Defaults to `true`.
  final bool showBack;

  /// Custom back-button handler. Falls back to a guarded pop.
  final VoidCallback? onBack;

  /// Widgets placed at the end of the title row.
  final List<Widget>? actions;

  /// Arbitrary widget rendered below the title row.
  final Widget? bottomChild;

  /// Title color. Defaults to the design-system ink.
  final Color titleColor;

  /// Subtitle color. Defaults to the muted grey.
  final Color subtitleColor;

  /// Back arrow color. Defaults to the design-system ink.
  final Color backColor;

  const AppSimpleHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.bottomChild,
    this.titleColor = const Color(0xFF111827),
    this.subtitleColor = const Color(0xFF6B7280),
    this.backColor = const Color(0xFF111827),
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

  Widget _titleBlock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            textAlign: TextAlign.start,
            style: AppTextStyles.of(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(
            subtitle!,
            textAlign: TextAlign.start,
            style: AppTextStyles.of(fontSize: 13.sp, color: subtitleColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;
    final backButton = showBack
        ? AppHeaderBackButton(
            color: backColor,
            onPressed: () => _handleBack(context),
          )
        : null;
    final trailing = actions == null
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: actions!);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          showBack ? AppHeaderSpacing.start : AppSpacing.pageHorizontal,
          16.h,
          showBack ? 16.w : AppSpacing.pageHorizontal,
          bottomChild != null ? 12.h : 14.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasSubtitle) ...[
              if (backButton != null || trailing != null)
                Row(
                  children: [
                    if (backButton != null) backButton else const Spacer(),
                    ?trailing,
                  ],
                ),
              if (backButton != null || trailing != null) SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: showBack ? AppHeaderSpacing.titleInset : 0,
                ),
                child: _titleBlock(),
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ?backButton,
                  if (title != null)
                    Expanded(child: _titleBlock())
                  else
                    const Spacer(),
                  ?trailing,
                ],
              ),
            if (bottomChild != null) ...[SizedBox(height: 8.h), bottomChild!],
          ],
        ),
      ),
    );
  }
}
