class SearchProviderModel {
  final int? providerId;
  final String? providerName;
  final String? categoryName;
  final String? imageUrl;
  final String? hotline;
  final double? maxDiscountPercentage;
  final double? averageRating;
  final int? totalReviews;
  final double? distanceKm;

  const SearchProviderModel({
    this.providerId,
    this.providerName,
    this.categoryName,
    this.imageUrl,
    this.hotline,
    this.maxDiscountPercentage,
    this.averageRating,
    this.totalReviews,
    this.distanceKm,
  });

  factory SearchProviderModel.fromJson(Map<String, dynamic> json) =>
      SearchProviderModel(
        providerId: _intValue(json['providerId'] ?? json['id']),
        providerName: _stringValue(json['providerName'] ?? json['name']),
        categoryName: _stringValue(json['categoryName'] ?? json['category']),
        imageUrl: _stringValue(
          json['imageUrl'] ?? json['providerImageUrl'] ?? json['image'],
        ),
        hotline: _stringValue(json['hotline'] ?? json['hotLine']),
        maxDiscountPercentage: _doubleValue(
          json['maxDiscountPercentage'] ?? json['discountPercentage'],
        ),
        averageRating: _doubleValue(json['averageRating'] ?? json['rating']),
        totalReviews: _intValue(json['totalReviews'] ?? json['reviewsCount']),
        distanceKm: _doubleValue(json['distanceKm']),
      );

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'providerName': providerName,
    'categoryName': categoryName,
    'imageUrl': imageUrl,
    'hotline': hotline,
    'maxDiscountPercentage': maxDiscountPercentage,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'distanceKm': distanceKm,
  };
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleValue(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _stringValue(dynamic value) {
  final text = value?.toString();
  return text == null || text.trim().isEmpty ? null : text;
}
