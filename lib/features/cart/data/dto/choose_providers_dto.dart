import 'package:json_annotation/json_annotation.dart';

part 'choose_providers_dto.g.dart';


@JsonSerializable()
class ChooseProvidersDto {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ChooseProvidersDataDto? data;

  const ChooseProvidersDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ChooseProvidersDto.fromJson(Map<String, dynamic> json) =>
      _$ChooseProvidersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChooseProvidersDtoToJson(this);
}


@JsonSerializable()
class ChooseProvidersDataDto {
  final List<ProviderOptionDto>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const ChooseProvidersDataDto({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory ChooseProvidersDataDto.fromJson(Map<String, dynamic> json) =>
      _$ChooseProvidersDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChooseProvidersDataDtoToJson(this);
}


@JsonSerializable()
class ProviderOptionDto {
  final int? providerId;
  final String? providerName;
  final String? providerImageUrl;
  final int? coveredCount;
  final int? uncoveredCount;
  final int? totalCount;
  final double? totalPriceBefore;
  final double? totalPriceAfter;
  final List<ProviderCoveredServiceDto>? coveredServices;
  final List<ProviderCoveredServiceDto>? uncoveredServices;

  const ProviderOptionDto({
    this.providerId,
    this.providerName,
    this.providerImageUrl,
    this.coveredCount,
    this.uncoveredCount,
    this.totalCount,
    this.totalPriceBefore,
    this.totalPriceAfter,
    this.coveredServices,
    this.uncoveredServices,
  });

  factory ProviderOptionDto.fromJson(Map<String, dynamic> json) =>
      _$ProviderOptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderOptionDtoToJson(this);
}


@JsonSerializable()
class ProviderCoveredServiceDto {
  final int? cartItemId;
  final int? serviceId;
  final String? serviceName;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;

  const ProviderCoveredServiceDto({
    this.cartItemId,
    this.serviceId,
    this.serviceName,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
  });

  factory ProviderCoveredServiceDto.fromJson(Map<String, dynamic> json) =>
      _$ProviderCoveredServiceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderCoveredServiceDtoToJson(this);
}
