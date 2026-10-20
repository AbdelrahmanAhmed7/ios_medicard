import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/featured_service_model.dart';
import 'featured_service_card.dart';
import 'home_horizontal_card_style.dart';
import 'home_section_header.dart';

class FeaturedServicesSection extends StatelessWidget {
  final List<FeaturedServiceModel> services;
  final VoidCallback? onViewAll;

  const FeaturedServicesSection({
    super.key,
    required this.services,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'home.packages'.tr(), onViewAll: onViewAll),
        const SizedBox(height: HomeHorizontalCardStyle.sectionGap),
        SizedBox(
          height: HomeHorizontalCardStyle.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: HomeHorizontalCardStyle.listPadding,
            itemCount: services.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: HomeHorizontalCardStyle.cardGap),
            itemBuilder: (_, i) => FeaturedServiceCard(service: services[i]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
