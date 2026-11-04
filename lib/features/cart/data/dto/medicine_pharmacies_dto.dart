class MedicinePharmaciesDto {
  final bool? succeeded;
  final String? message;
  final MedicinePharmaciesDataDto? data;

  const MedicinePharmaciesDto({this.succeeded, this.message, this.data});

  factory MedicinePharmaciesDto.fromJson(Map<String, dynamic> json) =>
      MedicinePharmaciesDto(
        succeeded: json['succeeded'] as bool?,
        message: json['message']?.toString(),
        data: json['data'] is Map<String, dynamic>
            ? MedicinePharmaciesDataDto.fromJson(
                json['data'] as Map<String, dynamic>,
              )
            : null,
      );
}

class MedicinePharmaciesDataDto {
  final List<MedicinePharmacyDto> items;
  const MedicinePharmaciesDataDto(this.items);

  factory MedicinePharmaciesDataDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return MedicinePharmaciesDataDto(
      raw is List
          ? raw
                .whereType<Map<String, dynamic>>()
                .map(MedicinePharmacyDto.fromJson)
                .toList()
          : const [],
    );
  }
}

class MedicinePharmacyDto {
  final int providerId;
  final String providerName;
  final String? providerImageUrl;
  final int medicineCount;
  final int totalQuantity;
  final double totalPriceBefore;
  final double totalPriceAfter;

  const MedicinePharmacyDto({
    required this.providerId,
    required this.providerName,
    this.providerImageUrl,
    this.medicineCount = 0,
    this.totalQuantity = 0,
    this.totalPriceBefore = 0,
    this.totalPriceAfter = 0,
  });

  factory MedicinePharmacyDto.fromJson(Map<String, dynamic> json) =>
      MedicinePharmacyDto(
        providerId: (json['providerId'] as num?)?.toInt() ?? 0,
        providerName: (json['providerName'] ?? json['providerNameEn'] ?? '')
            .toString(),
        providerImageUrl: json['providerImageUrl'] as String?,
        medicineCount: (json['medicineCount'] as num?)?.toInt() ?? 0,
        totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
        totalPriceBefore: (json['totalPriceBefore'] as num?)?.toDouble() ?? 0,
        totalPriceAfter: (json['totalPriceAfter'] as num?)?.toDouble() ?? 0,
      );
}
