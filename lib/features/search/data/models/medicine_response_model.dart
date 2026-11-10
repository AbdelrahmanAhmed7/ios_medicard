class MedicineResponseModel {
  final int? httpStatusCode;
  final dynamic errors;
  final bool? succeeded;
  final String? message;
  final MedicinePage? data;

  const MedicineResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory MedicineResponseModel.fromJson(Map<String, dynamic> json) =>
      MedicineResponseModel(
        httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
        errors: json['errors'],
        succeeded: json['succeeded'] as bool?,
        message: json['message'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? MedicinePage.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class MedicinePage {
  final List<MedicineModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const MedicinePage({
    this.items = const [],
    this.pageNumber = 1,
    this.pageSize = 15,
    this.totalCount = 0,
    this.totalPages = 1,
  });

  factory MedicinePage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return MedicinePage(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(MedicineModel.fromJson)
                .toList(growable: false)
          : const [],
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 15,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class MedicineModel {
  final int id;
  final String? arName;
  final String? enName;
  final double? medicinePrice;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final String? medicineImageUrl;
  final String? medicineForm;
  final String? unit;

  const MedicineModel({
    required this.id,
    this.arName,
    this.enName,
    this.medicinePrice,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.medicineImageUrl,
    this.medicineForm,
    this.unit,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    arName: json['arName'] as String?,
    enName: json['enName'] as String?,
    medicinePrice: (json['medicinePrice'] as num?)?.toDouble(),
    priceBefore: (json['priceBefore'] as num?)?.toDouble(),
    priceAfter: (json['priceAfter'] as num?)?.toDouble(),
    discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    medicineImageUrl: json['medicineImageUrl'] as String?,
    medicineForm: json['medicineForm'] as String?,
    unit: json['unit'] as String?,
  );
}
