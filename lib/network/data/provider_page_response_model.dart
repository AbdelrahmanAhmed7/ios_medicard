import 'package:json_annotation/json_annotation.dart';

part 'provider_page_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProviderPageResponse {
  final bool success;
  final String timestamp;
  final String message;
  final ProviderPageData? data;

  ProviderPageResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory ProviderPageResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderPageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPageResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderPageData {
  final int providerId;
  final String providerName;
  final String providerLogo;
  final String categoryName;
  final double? rating;
  final int? reviewsCount;
  final List<String>? phones;
  final List<ProviderBranch>? branches;
  final int? servicesCount;

  ProviderPageData({
    required this.providerId,
    required this.providerName,
    required this.providerLogo,
    required this.categoryName,
    this.rating,
    this.reviewsCount,
    this.phones,
    this.branches,
    this.servicesCount,
  });

  factory ProviderPageData.fromJson(Map<String, dynamic> json) =>
      _$ProviderPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderPageDataToJson(this);
}

@JsonSerializable()
class ProviderBranch {
  final int branchId;
  final String branchName;
  final String? phone;
  final String? fullAddress;
  final String? mapsUrl;
  final double? latitude;
  final double? longitude;

  ProviderBranch({
    required this.branchId,
    required this.branchName,
    this.phone,
    this.fullAddress,
    this.mapsUrl,
    this.latitude,
    this.longitude,
  });

  factory ProviderBranch.fromJson(Map<String, dynamic> json) =>
      _$ProviderBranchFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderBranchToJson(this);
}
