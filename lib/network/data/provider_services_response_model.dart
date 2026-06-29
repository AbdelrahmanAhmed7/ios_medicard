import 'package:json_annotation/json_annotation.dart';
import 'network_provider_response_model.dart';

part 'provider_services_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProviderServicesResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProviderServicesData? data;

  ProviderServicesResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderServicesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServicesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderServicesData {
  final List<ProviderService>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  ProviderServicesData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory ProviderServicesData.fromJson(Map<String, dynamic> json) =>
      _$ProviderServicesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServicesDataToJson(this);

  // Helper getters to keep existing code working
  List<ProviderService>? get services => items;
  Pagination? get pagination {
    if (pageNumber == null || pageSize == null || totalCount == null || totalPages == null) {
      return null;
    }
    return Pagination(
      currentPage: pageNumber!,
      pageSize: pageSize!,
      totalCount: totalCount!,
      totalPages: totalPages!,
      hasNextPage: pageNumber! < totalPages!,
      hasPreviousPage: pageNumber! > 1,
    );
  }
}

@JsonSerializable()
class ProviderService {
  final int? id;
  final String? serviceName;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final bool? isSpecialOffer;

  ProviderService({
    this.id,
    this.serviceName,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.isSpecialOffer,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) =>
      _$ProviderServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServiceToJson(this);

  // Helper getter to keep existing code working
  bool? get hasSpecialOffer => isSpecialOffer;
}
