import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theming/app_text_styles.dart';

/// Shown in the success state when the API returns no data at all.
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 56, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            'home.no_data_available'.tr(),
            style: AppTextStyles.of(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'home.pull_down_refresh'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
