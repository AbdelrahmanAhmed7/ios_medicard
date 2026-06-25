import 'package:json_annotation/json_annotation.dart';
import 'network_provider_response_model.dart';

part 'provider_services_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProviderServicesResponse {
  final bool success;
  final String timestamp;
  final String message;
  final ProviderServicesData? data;

  ProviderServicesResponse({
    required this.success,
    required this.timestamp,
    required this.message,
    this.data,
  });

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderServicesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServicesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderServicesData {
  final List<ProviderService>? services;
  final Pagination? pagination;

  ProviderServicesData({
    this.services,
    this.pagination,
  });

  factory ProviderServicesData.fromJson(Map<String, dynamic> json) =>
      _$ProviderServicesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServicesDataToJson(this);
}

@JsonSerializable()
class ProviderService {
  final int serviceId;
  final String serviceName;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final bool? hasSpecialOffer;

  ProviderService({
    required this.serviceId,
    required this.serviceName,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.hasSpecialOffer,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) =>
      _$ProviderServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServiceToJson(this);
}
