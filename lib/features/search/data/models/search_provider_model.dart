import 'package:json_annotation/json_annotation.dart';

part 'search_provider_model.g.dart';

@JsonSerializable()
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
      _$SearchProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchProviderModelToJson(this);
}
