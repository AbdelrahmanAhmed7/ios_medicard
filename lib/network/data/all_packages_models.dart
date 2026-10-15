/// `GET Package` — all packages across providers (paged).
class AllPackagesResponse {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final AllPackagesData? data;

  const AllPackagesResponse({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory AllPackagesResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    final rawData = json['data'];
    return AllPackagesResponse(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: rawErrors is List
          ? rawErrors.map((e) => e.toString()).toList()
          : null,
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: rawData is Map<String, dynamic>
          ? AllPackagesData.fromJson(rawData)
          : null,
    );
  }
}

class AllPackagesData {
  final List<AllPackage>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const AllPackagesData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory AllPackagesData.fromJson(Map<String, dynamic> json) {
    return AllPackagesData(
      items: (json['items'] as List?)
          ?.map((e) => AllPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }
}

class AllPackage {
  final int? id;
  final String? name;
  final int? providerId;
  final String? providerNameAr;
  final String? providerNameEn;
  final String? description;
  final String? image;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final List<String>? serviceNames;

  const AllPackage({
    this.id,
    this.name,
    this.providerId,
    this.providerNameAr,
    this.providerNameEn,
    this.description,
    this.image,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.serviceNames,
  });

  factory AllPackage.fromJson(Map<String, dynamic> json) {
    double? asDouble(Object? value) => (value as num?)?.toDouble();
    return AllPackage(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      providerId: (json['providerId'] as num?)?.toInt(),
      providerNameAr: json['providerNameAr'] as String?,
      providerNameEn: json['providerNameEn'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      priceBefore: asDouble(json['priceBefore']),
      priceAfter: asDouble(json['priceAfter']),
      discountPercentage: asDouble(json['discountPercentage']),
      serviceNames: (json['serviceNames'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  /// Localized provider name with English fallback.
  String providerName(bool isArabic) {
    final localized = isArabic ? providerNameAr : providerNameEn;
    if (localized != null && localized.trim().isNotEmpty) return localized;
    final fallback = isArabic ? providerNameEn : providerNameAr;
    return fallback?.trim() ?? '';
  }
}
