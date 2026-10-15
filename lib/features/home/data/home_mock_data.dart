class QuickAction {
  final String labelKey;
  final String assetPath;

  const QuickAction({required this.labelKey, required this.assetPath});
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
  ];

  static const List<QuickAction> guestQuickActions = [
    QuickAction(labelKey: 'home.services', assetPath: 'assets/home/2.png'),
    QuickAction(labelKey: 'home.providers', assetPath: 'assets/home/3.png'),
  ];

  static const List<PromoBanner> promoBanners = [
    PromoBanner(imageUrl: '', providerLogoUrl: '', title: '', subtitle: ''),
  ];
}
