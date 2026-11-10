import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../data/home_mock_data.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';

class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;
  final double verticalPadding;

  const QuickActionsRow({
    super.key,
    required this.actions,
    this.verticalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Row(
        children: actions
            .map(
              (action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    height: 96,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: action.enabled
                          ? () => _onActionTap(context, action)
                          : null,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: action.enabled
                              ? AppColors.exactFFEEF3FB
                              : AppColors.exactFFF3F4F6,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (action.assetPath case final assetPath?)
                              Image.asset(assetPath, width: 34, height: 34)
                            else if (action.icon case final icon?)
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: action.enabled
                                      ? AppColors.whiteClr
                                      : AppColors.exactFFE5E7EB,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  size: 28,
                                  color: action.enabled
                                      ? AppColors.exactFF2563A6
                                      : AppColors.exactFF9CA3AF,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              action.labelKey.tr(),
                              style: AppTextStyles.of(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: action.enabled
                                    ? AppColors.exactFF1A1A2E
                                    : AppColors.exactFF9CA3AF,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _onActionTap(BuildContext context, QuickAction action) {
    final isGuest = GoRouterState.of(context).uri.path == '/guest-home';
    switch (action.labelKey) {
      case 'home.services':
        context.push(
          '/search/services',
          extra: {'enableCartFeatures': !isGuest},
        );
        break;
      case 'home.upload_prescription':
        if (isGuest) {
          context.go('/medicard-login');
        } else {
          context.push('/manual-prescriptions');
        }
        break;
      case 'home.providers':
        context.push(
          '/search/providers',
          extra: {'enableCartFeatures': !isGuest},
        );
        break;
    }
  }
}
