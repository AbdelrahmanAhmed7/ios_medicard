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
  final double? discountPercentage;
  final String? paymentLink;
  final int? familyId;
  final String? familyFirstName;
  final String? familyLastName;
  final InvoiceReviewDto? review;
  final InvoiceServiceItemsPageDto? items;
  final String? providerName;
  final String? branchName;
  final String? providerImageUrl;

  const InvoiceDetailsDto({
    this.invoiceId,
    this.status,
    this.date,
    this.totalBefore,
    this.totalAfter,
    this.discountPercentage,
    this.paymentLink,
    this.familyId,
    this.familyFirstName,
    this.familyLastName,
    this.review,
    this.items,
    this.providerName,
    this.branchName,
    this.providerImageUrl,
  });

  factory InvoiceDetailsDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsDto(
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      status: json['status'] as String?,
      date: json['date'] as String?,
      totalBefore: (json['totalBefore'] as num?)?.toDouble(),
      totalAfter: (json['totalAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      paymentLink: json['paymentLink']?.toString(),
      familyId: (json['familyId'] as num?)?.toInt(),
      familyFirstName: json['familyFirstName'] as String?,
      familyLastName: json['familyLastName'] as String?,
      providerName: json['providerName'] as String?,
      branchName: json['branchName'] as String?,
      providerImageUrl: json['providerImageUrl'] as String?,
      review: json['review'] is Map<String, dynamic>
          ? InvoiceReviewDto.fromJson(json['review'] as Map<String, dynamic>)
          : null,
      items: json['items'] is Map<String, dynamic>
          ? InvoiceServiceItemsPageDto.fromJson(
              json['items'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class InvoiceReviewDto {
  final String? userName;
  final String? userImageUrl;
  final int? rating;
  final String? ratingText;
  final String? createdAt;

  const InvoiceReviewDto({
    this.userName,
    this.userImageUrl,
    this.rating,
    this.ratingText,
    this.createdAt,
  });

  factory InvoiceReviewDto.fromJson(Map<String, dynamic> json) {
    return InvoiceReviewDto(
      userName: json['userName'] as String?,
      userImageUrl: json['userImageUrl'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      ratingText: json['ratingText'] as String?,
      createdAt: json['createdAt'] as String?,
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
  final String? serviceNameAr;
  final String? serviceNameEn;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;

  const InvoiceServiceItemDto({
    this.id,
    this.serviceName,
    this.serviceNameAr,
    this.serviceNameEn,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
  });

  factory InvoiceServiceItemDto.fromJson(Map<String, dynamic> json) {
    return InvoiceServiceItemDto(
      id: (json['id'] as num?)?.toInt(),
      serviceName: json['serviceName'] as String?,
      serviceNameAr: json['serviceNameAr'] as String?,
      serviceNameEn: json['serviceNameEn'] as String?,
      priceBefore: (json['priceBefore'] as num?)?.toDouble(),
      priceAfter: (json['priceAfter'] as num?)?.toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }
}
