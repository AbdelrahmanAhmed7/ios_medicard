import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../domain/models/provider_model.dart';
import 'home_section_header.dart';
import 'nearest_provider_card.dart';

class NearestSection extends StatelessWidget {
  final List<ProviderModel> providers;
  final VoidCallback? onViewAll;

  const NearestSection({super.key, required this.providers, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'home.nearest_providers'.tr(),
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 274,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pageHorizontalInsets,
            itemCount: providers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => NearestProviderCard(provider: providers[i]),
          ),
        ),
      ],
    );
  }
}
