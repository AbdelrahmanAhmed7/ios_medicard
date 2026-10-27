import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../data/home_mock_data.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';

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
                      onTap: () => _onActionTap(context, action),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              action.assetPath,
                              width: 34,
                              height: 34,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              action.labelKey.tr(),
                              style: AppTextStyles.of(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
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
      case 'home.providers':
        context.push(
          '/search/providers',
          extra: {'enableCartFeatures': !isGuest},
        );
        break;
    }
  }
}
