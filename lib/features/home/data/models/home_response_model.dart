import 'package:json_annotation/json_annotation.dart';

part 'home_response_model.g.dart';

@JsonSerializable()
class HomeResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final HomeDataModel? data;

  const HomeResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HomeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeResponseModelToJson(this);
}

@JsonSerializable()
class HomeDataModel {
  final List<HomeSlider>? sliders;
  final List<HomePendingAppointment>? pendingAppointments;
  final List<HomeNearestProvider>? nearestProviders;
  final List<HomePackage>? packages;

  const HomeDataModel({
    this.sliders,
    this.pendingAppointments,
    this.nearestProviders,
    this.packages,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);
}

@JsonSerializable()
class HomeSlider {
  final int? id;
  final String? imageUrl;
  final int? providerId;
  final String? providerName;

  const HomeSlider({
    this.id,
    this.imageUrl,
    this.providerId,
    this.providerName,
  });

  factory HomeSlider.fromJson(Map<String, dynamic> json) =>
      _$HomeSliderFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSliderToJson(this);
}

@JsonSerializable()
class HomePendingAppointment {
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? providerImageUrl;
  final String? branchName;
  final String? service;
  final String? status;
  final String? date;

  const HomePendingAppointment({
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.providerImageUrl,
    this.branchName,
    this.service,
    this.status,
    this.date,
  });

  factory HomePendingAppointment.fromJson(Map<String, dynamic> json) =>
      _$HomePendingAppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$HomePendingAppointmentToJson(this);
}

@JsonSerializable()
class HomeNearestProvider {
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? providerImageUrl;
  final String? branchName;
  final String? fullAddress;
  final String? mapUrl;
  final double? distanceKm;

  const HomeNearestProvider({
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.providerImageUrl,
    this.branchName,
    this.fullAddress,
    this.mapUrl,
    this.distanceKm,
  });

  factory HomeNearestProvider.fromJson(Map<String, dynamic> json) =>
      _$HomeNearestProviderFromJson(json);

  Map<String, dynamic> toJson() => _$HomeNearestProviderToJson(this);
}

@JsonSerializable()
class HomePackage {
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

  const HomePackage({
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

  factory HomePackage.fromJson(Map<String, dynamic> json) =>
      _$HomePackageFromJson(json);

  Map<String, dynamic> toJson() => _$HomePackageToJson(this);
}
