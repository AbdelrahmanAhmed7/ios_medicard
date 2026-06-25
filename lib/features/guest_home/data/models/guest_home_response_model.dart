import 'package:json_annotation/json_annotation.dart';

part 'guest_home_response_model.g.dart';

@JsonSerializable()
class GuestHomeResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final GuestHomeDataModel? data;

  const GuestHomeResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GuestHomeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GuestHomeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestHomeResponseModelToJson(this);
}

@JsonSerializable()
class GuestHomeDataModel {
  final List<GuestSlider>? sliders;
  final List<GuestCategory>? categories;
  final List<GuestNearestProvider>? nearestProviders;
  final List<GuestPackage>? packages;

  const GuestHomeDataModel({
    this.sliders,
    this.categories,
    this.nearestProviders,
    this.packages,
  });

  factory GuestHomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$GuestHomeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$GuestHomeDataModelToJson(this);
}

@JsonSerializable()
class GuestSlider {
  final int? id;
  final String? imageUrl;
  final int? providerId;
  final String? providerName;

  const GuestSlider({
    this.id,
    this.imageUrl,
    this.providerId,
    this.providerName,
  });

  factory GuestSlider.fromJson(Map<String, dynamic> json) =>
      _$GuestSliderFromJson(json);

  Map<String, dynamic> toJson() => _$GuestSliderToJson(this);
}

@JsonSerializable()
class GuestCategory {
  final int? id;
  final String? name;
  final String? imageUrl;

  const GuestCategory({
    this.id,
    this.name,
    this.imageUrl,
  });

  factory GuestCategory.fromJson(Map<String, dynamic> json) =>
      _$GuestCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$GuestCategoryToJson(this);
}

@JsonSerializable()
class GuestNearestProvider {
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? providerImageUrl;
  final String? branchName;
  final String? fullAddress;
  final String? mapUrl;
  final double? distanceKm;

  const GuestNearestProvider({
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.providerImageUrl,
    this.branchName,
    this.fullAddress,
    this.mapUrl,
    this.distanceKm,
  });

  factory GuestNearestProvider.fromJson(Map<String, dynamic> json) =>
      _$GuestNearestProviderFromJson(json);

  Map<String, dynamic> toJson() => _$GuestNearestProviderToJson(this);
}

@JsonSerializable()
class GuestPackage {
  final int? packageId;
  final int? providerId;
  final String? providerName;
  final String? name;
  final String? imageUrl;
  final String? description;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final int? servicesCount;

  const GuestPackage({
    this.packageId,
    this.providerId,
    this.providerName,
    this.name,
    this.imageUrl,
    this.description,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.servicesCount,
  });

  factory GuestPackage.fromJson(Map<String, dynamic> json) =>
      _$GuestPackageFromJson(json);

  Map<String, dynamic> toJson() => _$GuestPackageToJson(this);
}
