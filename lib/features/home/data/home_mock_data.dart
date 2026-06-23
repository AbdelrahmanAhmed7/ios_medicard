class QuickAction {
  final String label;
  final String assetPath;

  const QuickAction({required this.label, required this.assetPath});
}

class PromoBanner {
  final String imageUrl;
  final String providerLogoUrl;
  final String title;
  final String subtitle;

  const PromoBanner({
    required this.imageUrl,
    required this.providerLogoUrl,
    required this.title,
    required this.subtitle,
  });
}

class HomeMockData {
  static const List<QuickAction> quickActions = [
    QuickAction(label: 'Upload\nPrescription', assetPath: 'assets/home/1.png'),
    QuickAction(label: 'Services', assetPath: 'assets/home/2.png'),
    QuickAction(label: 'Providers', assetPath: 'assets/home/3.png'),
  ];

  static const List<PromoBanner> promoBanners = [
    PromoBanner(
      imageUrl: '',
      providerLogoUrl: '',
      title: '',
      subtitle: '',
    ),
  ];

}
