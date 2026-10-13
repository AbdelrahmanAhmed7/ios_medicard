import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/featured_service_model.dart';
import 'featured_service_card.dart';
import 'home_section_header.dart';

class FeaturedServicesSection extends StatelessWidget {
  final List<FeaturedServiceModel> services;

  const FeaturedServicesSection({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'home.packages'.tr()),
        const SizedBox(height: 12),
        SizedBox(
          height: 274,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => FeaturedServiceCard(service: services[i]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
