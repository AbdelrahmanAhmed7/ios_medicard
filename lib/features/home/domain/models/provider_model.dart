class ProviderModel {
  final String imageUrl;
  final String name;
  final double rating;
  final int reviewCount;
  final String type;
  final String location;
  final List<String> badges;

  const ProviderModel({
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.type,
    required this.location,
    this.badges = const [],
  });
}