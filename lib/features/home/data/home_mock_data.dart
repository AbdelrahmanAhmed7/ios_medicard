import 'package:flutter/material.dart';

class QuickAction {
  final String labelKey;
  final String? assetPath;
  final IconData? icon;
  final bool enabled;

  const QuickAction({
    required this.labelKey,
    this.assetPath,
    this.icon,
    this.enabled = true,
  });
}

class PromoBanner {
  final int? providerId;
  final String imageUrl;
  final String providerLogoUrl;
  final String title;
  final String subtitle;

  const PromoBanner({
    this.providerId,
    required this.imageUrl,
    required this.providerLogoUrl,
    required this.title,
    required this.subtitle,
  });
}

class HomeMockData {
  static const List<QuickAction> quickActions = [
    QuickAction(labelKey: 'home.services', assetPath: 'assets/home/2.png'),
    QuickAction(labelKey: 'home.providers', assetPath: 'assets/home/3.png'),
    QuickAction(
      labelKey: 'home.medicine',
      icon: Icons.medication_outlined,
      enabled: false,
    ),
  ];

  static const List<QuickAction> guestQuickActions = [
    QuickAction(labelKey: 'home.services', assetPath: 'assets/home/2.png'),
    QuickAction(labelKey: 'home.providers', assetPath: 'assets/home/3.png'),
    QuickAction(
      labelKey: 'home.medicine',
      icon: Icons.medication_outlined,
      enabled: false,
    ),
  ];

  static const List<PromoBanner> promoBanners = [
    PromoBanner(imageUrl: '', providerLogoUrl: '', title: '', subtitle: ''),
  ];
}
