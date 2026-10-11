import 'package:json_annotation/json_annotation.dart';

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
  final List<ProviderServicesGroup>? groups;
  final List<ProviderService>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  ProviderServicesData({
    this.groups,
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
  List<ProviderService>? get services {
    if (items != null) return items;
    final groupedItems = groups
        ?.expand(
          (group) => (group.services ?? const <ProviderService>[]).map(
            (service) => service.withCategoryId(group.categoryId),
          ),
        )
        .toList();
    return groupedItems?.isEmpty == true ? null : groupedItems;
  }

  Pagination? get pagination {
    if (pageNumber == null ||
        pageSize == null ||
        totalCount == null ||
        totalPages == null) {
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

@JsonSerializable(explicitToJson: true)
class ProviderServicesGroup {
  final int? categoryId;
  final String? categoryName;
  final List<ProviderService>? services;

  ProviderServicesGroup({this.categoryId, this.categoryName, this.services});

  factory ProviderServicesGroup.fromJson(Map<String, dynamic> json) =>
      _$ProviderServicesGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServicesGroupToJson(this);
}

@JsonSerializable()
class ProviderService {
  final int? id;
  final String? serviceName;
  final String? instruction;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final bool? isSpecialOffer;
  final bool? isSelected;
  final int? categoryId;

  ProviderService({
    this.id,
    this.serviceName,
    this.instruction,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.isSpecialOffer,
    this.isSelected,
    this.categoryId,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) =>
      _$ProviderServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderServiceToJson(this);

  // Helper getter to keep existing code working
  bool? get hasSpecialOffer => isSpecialOffer;

  ProviderService withCategoryId(int? nextCategoryId) => ProviderService(
    id: id,
    serviceName: serviceName,
    instruction: instruction,
    priceBefore: priceBefore,
    priceAfter: priceAfter,
    discountPercentage: discountPercentage,
    isSpecialOffer: isSpecialOffer,
    isSelected: isSelected,
    categoryId: categoryId ?? nextCategoryId,
  );

  ProviderService copyWith({bool? isSelected}) => ProviderService(
    id: id,
    serviceName: serviceName,
    instruction: instruction,
    priceBefore: priceBefore,
    priceAfter: priceAfter,
    discountPercentage: discountPercentage,
    isSpecialOffer: isSpecialOffer,
    isSelected: isSelected ?? this.isSelected,
    categoryId: categoryId,
  );
}

class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
