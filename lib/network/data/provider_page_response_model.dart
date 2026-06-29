import 'package:json_annotation/json_annotation.dart';

part 'provider_page_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProviderPageResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProviderPageData? data;

  ProviderPageResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProviderPageResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderPageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPageResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderPageData {
  final int id;
  final String name;
  final String categoryName;
  final String imageUrl;
  final String? hotLine;
  final String? phoneNumber1;
  final String? phoneNumber2;
  final int? totalServices;
  final double? averageRating;
  final int? totalReviews;
  final List<ProviderBranch>? branches;
  final int? pageNumber;
  final int? pageSize;
  final int? totalPages;

  ProviderPageData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.imageUrl,
    this.hotLine,
    this.phoneNumber1,
    this.phoneNumber2,
    this.totalServices,
    this.averageRating,
    this.totalReviews,
    this.branches,
    this.pageNumber,
    this.pageSize,
    this.totalPages,
  });

  factory ProviderPageData.fromJson(Map<String, dynamic> json) =>
      _$ProviderPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPageDataToJson(this);

  // Helper getters to keep existing code working
  String get providerName => name;
  String get providerLogo => imageUrl;
  int get providerId => id;
  double? get rating => averageRating;
  int? get reviewsCount => totalReviews;
  List<String>? get phones {
    final List<String> result = [];
    if (hotLine != null && hotLine!.isNotEmpty) result.add(hotLine!);
    if (phoneNumber1 != null && phoneNumber1!.isNotEmpty) result.add(phoneNumber1!);
    if (phoneNumber2 != null && phoneNumber2!.isNotEmpty) result.add(phoneNumber2!);
    return result.isEmpty ? null : result;
  }
  int? get servicesCount => totalServices;
}

@JsonSerializable()
class ProviderBranch {
  final int branchId;
  final String branchName;
  final String? phoneNumber1;
  final String? phoneNumber2;
  final String? fullAddress;
  final String? mapUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  ProviderBranch({
    required this.branchId,
    required this.branchName,
    this.phoneNumber1,
    this.phoneNumber2,
    this.fullAddress,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory ProviderBranch.fromJson(Map<String, dynamic> json) =>
      _$ProviderBranchFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderBranchToJson(this);

  // Helper getter to keep existing code working
  String? get phone => phoneNumber1;
  String? get mapsUrl => mapUrl;
}

// ============ REVIEWS ============
@JsonSerializable(explicitToJson: true)
class ProviderReviewsResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProviderReviewsData? data;

  ProviderReviewsResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProviderReviewsResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderReviewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderReviewsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderReviewsData {
  final List<ProviderReview>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  ProviderReviewsData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory ProviderReviewsData.fromJson(Map<String, dynamic> json) =>
      _$ProviderReviewsDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderReviewsDataToJson(this);
}

@JsonSerializable()
class ProviderReview {
  final String? userName;
  final String? userImageUrl;
  final int? rating;
  final String? ratingText;
  final String? createdAt;

  ProviderReview({
    this.userName,
    this.userImageUrl,
    this.rating,
    this.ratingText,
    this.createdAt,
  });

  factory ProviderReview.fromJson(Map<String, dynamic> json) =>
      _$ProviderReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderReviewToJson(this);
}

// ============ PACKAGES ============
@JsonSerializable(explicitToJson: true)
class ProviderPackagesResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProviderPackagesData? data;

  ProviderPackagesResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProviderPackagesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderPackagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPackagesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderPackagesData {
  final List<ProviderPackage>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  ProviderPackagesData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory ProviderPackagesData.fromJson(Map<String, dynamic> json) =>
      _$ProviderPackagesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPackagesDataToJson(this);
}

@JsonSerializable()
class ProviderPackage {
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? description;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final int? servicesCount;

  ProviderPackage({
    this.id,
    this.name,
    this.imageUrl,
    this.description,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.servicesCount,
  });

  factory ProviderPackage.fromJson(Map<String, dynamic> json) =>
      _$ProviderPackageFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPackageToJson(this);
}
