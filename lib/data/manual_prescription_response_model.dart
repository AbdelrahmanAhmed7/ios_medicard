class ManualPrescriptionResponseModel {
  final bool succeeded;
  final String? message;

  const ManualPrescriptionResponseModel({
    required this.succeeded,
    this.message,
  });

  factory ManualPrescriptionResponseModel.fromJson(Map<String, dynamic> json) =>
      ManualPrescriptionResponseModel(
        succeeded: json['succeeded'] == true,
        message: json['message']?.toString(),
      );
}

class ManualPrescriptionPageResponseModel {
  final bool succeeded;
  final String? message;
  final List<ManualPrescriptionItemModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const ManualPrescriptionPageResponseModel({
    required this.succeeded,
    this.message,
    this.items = const [],
    this.pageNumber = 1,
    this.pageSize = 10,
    this.totalCount = 0,
    this.totalPages = 0,
  });

  factory ManualPrescriptionPageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const <String, dynamic>{};
    final rawItems = data['items'] is List ? data['items'] as List : const [];
    return ManualPrescriptionPageResponseModel(
      succeeded: json['succeeded'] == true,
      message: json['message']?.toString(),
      items: rawItems
          .whereType<Map>()
          .map(
            (item) => ManualPrescriptionItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      pageNumber: _asInt(data['pageNumber'], 1),
      pageSize: _asInt(data['pageSize'], 10),
      totalCount: _asInt(data['totalCount'], 0),
      totalPages: _asInt(data['totalPages'], 0),
    );
  }
}

class ManualPrescriptionItemModel {
  final int id;
  final String status;
  final String? imageUrl;
  final String? text;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final List<ManualPrescriptionEntryModel> items;

  const ManualPrescriptionItemModel({
    required this.id,
    required this.status,
    this.imageUrl,
    this.text,
    this.createdAt,
    this.reviewedAt,
    this.rejectionReason,
    this.items = const [],
  });

  factory ManualPrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    return ManualPrescriptionItemModel(
      id: _asInt(json['id'], 0),
      status: json['status']?.toString() ?? 'Pending',
      imageUrl: json['imageUrl']?.toString(),
      text: json['text']?.toString(),
      createdAt: parseDate(json['createdAt']),
      reviewedAt: parseDate(json['reviewedAt']),
      rejectionReason: json['rejectionReason']?.toString(),
      items: (json['items'] is List ? json['items'] as List : const [])
          .whereType<Map>()
          .map(
            (item) => ManualPrescriptionEntryModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class ManualPrescriptionEntryModel {
  final int serviceId;
  final String? serviceArName;
  final String? serviceEnName;
  final bool isMedicine;
  final String? providerArName;
  final String? providerEnName;
  final int quantityAdded;

  const ManualPrescriptionEntryModel({
    required this.serviceId,
    this.serviceArName,
    this.serviceEnName,
    required this.isMedicine,
    this.providerArName,
    this.providerEnName,
    required this.quantityAdded,
  });

  factory ManualPrescriptionEntryModel.fromJson(Map<String, dynamic> json) =>
      ManualPrescriptionEntryModel(
        serviceId: _asInt(json['serviceId'], 0),
        serviceArName: json['serviceArName']?.toString(),
        serviceEnName: json['serviceEnName']?.toString(),
        isMedicine: json['isMedicine'] == true,
        providerArName: json['providerArName']?.toString(),
        providerEnName: json['providerEnName']?.toString(),
        quantityAdded: _asInt(json['quantityAdded'], 0),
      );
}

int _asInt(Object? value, int fallback) =>
    value is int ? value : int.tryParse('$value') ?? fallback;
