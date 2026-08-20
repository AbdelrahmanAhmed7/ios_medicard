import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../data/home_mock_data.dart';

class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: actions
            .map(
              (action) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 82,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _onActionTap(context, action),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              action.assetPath,
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              action.labelKey.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
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
      case 'home.providers':
        context.push(
          '/search/providers',
          extra: {'enableCartFeatures': !isGuest},
        );
        break;
    }
  }
}
