class FeaturedServiceModel {
  final int? packageId;
  final int? providerId;
  final int? providerBranchId;
  final String imageUrl;
  final String providerLogoUrl;
  final String providerName;
  final String serviceName;
  final String location;
  final double originalPrice;
  final double discountedPrice;
  final double rating;
  final int reviewCount;

  const FeaturedServiceModel({
    this.packageId,
    this.providerId,
    this.providerBranchId,
    required this.imageUrl,
    required this.providerLogoUrl,
    required this.providerName,
    required this.serviceName,
    required this.location,
    required this.originalPrice,
    required this.discountedPrice,
    required this.rating,
    required this.reviewCount,
  });
}
