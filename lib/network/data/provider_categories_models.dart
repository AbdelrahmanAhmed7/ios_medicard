import 'provider_services_response_model.dart';

/// `GET CategoryService/providerCategories?providerId=`
/// `data` is a bare list of categories.
class ProviderCategoriesResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final List<ProviderCategory>? data;

  const ProviderCategoriesResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProviderCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return ProviderCategoriesResponse(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: rawErrors is List
          ? rawErrors.map((e) => e.toString()).toList()
          : null,
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List?)
          ?.map((e) => ProviderCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProviderCategory {
  final String? imageUrl;
  final int? id;
  final String? name;

  const ProviderCategory({this.imageUrl, this.id, this.name});

  factory ProviderCategory.fromJson(Map<String, dynamic> json) {
    return ProviderCategory(
      imageUrl: json['imageUrl'] as String?,
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );
  }
}

/// `GET ProviderPage/servicesByCategory?categoryId=&providerId=`
/// Paged envelope mirroring the backend response.
class ServicesByCategoryResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ServicesByCategoryData? data;

  const ServicesByCategoryResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ServicesByCategoryResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    final rawData = json['data'];
    return ServicesByCategoryResponse(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: rawErrors is List
          ? rawErrors.map((e) => e.toString()).toList()
          : null,
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: rawData is Map<String, dynamic>
          ? ServicesByCategoryData.fromJson(rawData)
          : null,
    );
  }
}

class ServicesByCategoryData {
  final List<ProviderCategoryService>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const ServicesByCategoryData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory ServicesByCategoryData.fromJson(Map<String, dynamic> json) {
    return ServicesByCategoryData(
      items: (json['items'] as List?)
          ?.map(
            (e) => ProviderCategoryService.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }
}

class ProviderCategoryService {
  final int? id;
  final String? serviceName;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final String? instruction;
  final double? priceBefore;
  final double? discountPercentage;
  final double? priceAfter;
  final bool? isSpecialOffer;

  const ProviderCategoryService({
    this.id,
    this.serviceName,
    this.serviceNameAr,
    this.serviceNameEn,
    this.instruction,
    this.priceBefore,
    this.discountPercentage,
    this.priceAfter,
    this.isSpecialOffer,
  });

  factory ProviderCategoryService.fromJson(Map<String, dynamic> json) {
    double? asDouble(Object? value) => (value as num?)?.toDouble();
    final instruction = json['instruction'] as String?;
    return ProviderCategoryService(
      id: (json['id'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      instruction: instruction?.trim().isEmpty == true ? null : instruction,
      priceBefore: asDouble(json['priceBefore']),
      discountPercentage: asDouble(json['discountPercentage']),
      priceAfter: asDouble(json['priceAfter']),
      isSpecialOffer: json['isSpecialOffer'] as bool?,
    );
  }

  /// Backend display name: localized variant first, combined fallback.
  String displayName(bool isArabic) {
    final localized = isArabic ? serviceNameAr : serviceNameEn;
    if (localized != null && localized.trim().isNotEmpty) return localized;
    if (serviceName != null && serviceName!.trim().isNotEmpty) {
      return serviceName!;
    }
    return '';
  }

  /// Adapts to the catalog [ProviderService] used by the cart flow.
  ProviderService toProviderService({
    required int categoryId,
    required bool isArabic,
    bool? isSelected,
  }) {
    return ProviderService(
      id: id,
      serviceName: displayName(isArabic),
      instruction: instruction,
      priceBefore: priceBefore,
      priceAfter: priceAfter,
      discountPercentage: discountPercentage,
      isSpecialOffer: isSpecialOffer,
      isSelected: isSelected,
      categoryId: categoryId,
    );
  }
}
