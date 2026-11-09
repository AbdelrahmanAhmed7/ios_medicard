import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theming/app_text_styles.dart';
import 'home_horizontal_card_style.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Reusable section header: "Title  View all ›"
/// Used by Pending Appointments, Nearest Providers, Featured Services.
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const HomeSectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: HomeHorizontalCardStyle.listPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.of(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.inkClr,
              ),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'home.view_all'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandBlueClr,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '›',
                      style: AppTextStyles.of(
                        fontSize: 18,
                        color: AppColors.brandBlueClr,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

