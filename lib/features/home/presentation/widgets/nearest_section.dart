import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/provider_model.dart';
import 'home_horizontal_card_style.dart';
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
        const SizedBox(height: HomeHorizontalCardStyle.sectionGap),
        SizedBox(
          height: HomeHorizontalCardStyle.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: HomeHorizontalCardStyle.listPadding,
            itemCount: providers.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: HomeHorizontalCardStyle.cardGap),
            itemBuilder: (_, i) => NearestProviderCard(provider: providers[i]),
          ),
        ),
      ],
    );
  }
}
