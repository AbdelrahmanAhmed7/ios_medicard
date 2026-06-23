// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchProviderModel _$SearchProviderModelFromJson(Map<String, dynamic> json) =>
    SearchProviderModel(
      providerId: (json['providerId'] as num?)?.toInt(),
      providerName: json['providerName'] as String?,
      categoryName: json['categoryName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      hotline: json['hotline'] as String?,
      maxDiscountPercentage: (json['maxDiscountPercentage'] as num?)
          ?.toDouble(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SearchProviderModelToJson(
  SearchProviderModel instance,
) => <String, dynamic>{
  'providerId': instance.providerId,
  'providerName': instance.providerName,
  'categoryName': instance.categoryName,
  'imageUrl': instance.imageUrl,
  'hotline': instance.hotline,
  'maxDiscountPercentage': instance.maxDiscountPercentage,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'distanceKm': instance.distanceKm,
};
