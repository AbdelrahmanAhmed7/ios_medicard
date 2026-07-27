class InvoiceDetailsResponseDto {
  final int? httpStatusCode;
  final dynamic errors;
  final bool? succeeded;
  final String? message;
  final InvoiceDetailsDto? data;

  const InvoiceDetailsResponseDto({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory InvoiceDetailsResponseDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsResponseDto(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: json['errors'],
      succeeded: json['succeeded'] as bool?,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? InvoiceDetailsDto.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class InvoiceDetailsDto {
  final int? invoiceId;
  final String? status;
  final String? date;
  final double? totalBefore;
  final double? totalAfter;
  final InvoiceServiceItemsPageDto? items;

  const InvoiceDetailsDto({
    this.invoiceId,
    this.status,
    this.date,
    this.totalBefore,
    this.totalAfter,
    this.items,
  });

  factory InvoiceDetailsDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsDto(
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      status: json['status'] as String?,
      date: json['date'] as String?,
      totalBefore: (json['totalBefore'] as num?)?.toDouble(),
      totalAfter: (json['totalAfter'] as num?)?.toDouble(),
      items: json['items'] is Map<String, dynamic>
          ? InvoiceServiceItemsPageDto.fromJson(
              json['items'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class InvoiceServiceItemsPageDto {
  final List<InvoiceServiceItemDto> items;

  const InvoiceServiceItemsPageDto({required this.items});

  factory InvoiceServiceItemsPageDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return InvoiceServiceItemsPageDto(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(InvoiceServiceItemDto.fromJson)
                .toList()
          : const [],
    );
  }
}

class InvoiceServiceItemDto {
  final int? id;
  final String? serviceName;
  final String? serviceNameEn;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;

  const InvoiceServiceItemDto({
    this.id,
    this.serviceName,
    this.serviceNameEn,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
  });

  factory InvoiceServiceItemDto.fromJson(Map<String, dynamic> json) {
    return InvoiceServiceItemDto(
      id: (json['id'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }
}
