class ProviderModel {
  final int? providerId;
  final String imageUrl;
  final String name;
  final double rating;
  final int reviewCount;
  final String type;
  final String location;
  final List<String> badges;
  final String mapUrl;
  final double? distanceKm;

  const ProviderModel({
    this.providerId,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.type,
    required this.location,
    this.badges = const [],
    this.mapUrl = '',
    this.distanceKm,
  });
}