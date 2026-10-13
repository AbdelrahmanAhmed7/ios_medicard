// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderPageResponse _$ProviderPageResponseFromJson(
  Map<String, dynamic> json,
) => ProviderPageResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProviderPageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderPageResponseToJson(
  ProviderPageResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderBranchesResponse _$ProviderBranchesResponseFromJson(
  Map<String, dynamic> json,
) => ProviderBranchesResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ProviderBranch.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProviderBranchesResponseToJson(
  ProviderBranchesResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

ProviderPageData _$ProviderPageDataFromJson(Map<String, dynamic> json) =>
    ProviderPageData(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      categoryName: json['categoryName'] as String,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String,
      hotLine: json['hotLine'] as String?,
      phoneNumber1: json['phoneNumber1'] as String?,
      phoneNumber2: json['phoneNumber2'] as String?,
      totalServices: (json['totalServices'] as num?)?.toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      branches: (json['branches'] as List<dynamic>?)
          ?.map((e) => ProviderBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => ProviderService.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviderPageDataToJson(ProviderPageData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryName': instance.categoryName,
      'categoryId': instance.categoryId,
      'imageUrl': instance.imageUrl,
      'hotLine': instance.hotLine,
      'phoneNumber1': instance.phoneNumber1,
      'phoneNumber2': instance.phoneNumber2,
      'totalServices': instance.totalServices,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'branches': instance.branches?.map((e) => e.toJson()).toList(),
      'services': instance.services?.map((e) => e.toJson()).toList(),
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };

ProviderBranch _$ProviderBranchFromJson(Map<String, dynamic> json) =>
    ProviderBranch(
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      phoneNumber1: json['phoneNumber1'] as String?,
      phoneNumber2: json['phoneNumber2'] as String?,
      fullAddress: json['fullAddress'] as String?,
      mapUrl: json['mapUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ProviderBranchToJson(ProviderBranch instance) =>
    <String, dynamic>{
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'phoneNumber1': instance.phoneNumber1,
      'phoneNumber2': instance.phoneNumber2,
      'fullAddress': instance.fullAddress,
      'mapUrl': instance.mapUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distanceKm': instance.distanceKm,
    };

ProviderReviewsResponse _$ProviderReviewsResponseFromJson(
  Map<String, dynamic> json,
) => ProviderReviewsResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProviderReviewsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderReviewsResponseToJson(
  ProviderReviewsResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderReviewsData _$ProviderReviewsDataFromJson(Map<String, dynamic> json) =>
    ProviderReviewsData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ProviderReview.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviderReviewsDataToJson(
  ProviderReviewsData instance,
) => <String, dynamic>{
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

ProviderReview _$ProviderReviewFromJson(Map<String, dynamic> json) =>
    ProviderReview(
      userName: json['userName'] as String?,
      userImageUrl: json['userImageUrl'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      ratingText: json['ratingText'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ProviderReviewToJson(ProviderReview instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'userImageUrl': instance.userImageUrl,
      'rating': instance.rating,
      'ratingText': instance.ratingText,
      'createdAt': instance.createdAt,
    };

ProviderPackagesResponse _$ProviderPackagesResponseFromJson(
  Map<String, dynamic> json,
) => ProviderPackagesResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : ProviderPackagesData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderPackagesResponseToJson(
  ProviderPackagesResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

ProviderPackagesData _$ProviderPackagesDataFromJson(
  Map<String, dynamic> json,
) => ProviderPackagesData(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProviderPackage.fromJson(e as Map<String, dynamic>))
      .toList(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProviderPackagesDataToJson(
  ProviderPackagesData instance,
) => <String, dynamic>{
  'items': instance.items?.map((e) => e.toJson()).toList(),
  'pageNumber': instance.pageNumber,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
};

ProviderPackage _$ProviderPackageFromJson(Map<String, dynamic> json) =>
    ProviderPackage(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      servicesCount: (json['servicesCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProviderPackageToJson(ProviderPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'servicesCount': instance.servicesCount,
    };

PackageDetailsResponse _$PackageDetailsResponseFromJson(
  Map<String, dynamic> json,
) => PackageDetailsResponse(
  httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
  errors: (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  succeeded: json['succeeded'] as bool?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : PackageDetailsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PackageDetailsResponseToJson(
  PackageDetailsResponse instance,
) => <String, dynamic>{
  'httpStatusCode': instance.httpStatusCode,
  'errors': instance.errors,
  'succeeded': instance.succeeded,
  'message': instance.message,
  'data': instance.data?.toJson(),
};

PackageDetailsData _$PackageDetailsDataFromJson(Map<String, dynamic> json) =>
    PackageDetailsData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      serviceNames: (json['serviceNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      providerId: (json['providerId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PackageDetailsDataToJson(PackageDetailsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'priceBefore': instance.priceBefore,
      'priceAfter': instance.priceAfter,
      'discountPercentage': instance.discountPercentage,
      'serviceNames': instance.serviceNames,
      'providerId': instance.providerId,
    };
