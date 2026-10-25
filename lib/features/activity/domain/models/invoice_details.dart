class InvoiceDetails {
  final int? invoiceId;
  final String? status;
  final DateTime? date;
  final String? apiDate;
  final double? totalBefore;
  final double? totalAfter;
  final double? discountPercentage;
  final String? paymentLink;
  final int? familyId;
  final String? familyFirstName;
  final String? familyLastName;
  final String? beneficiaryName;
  final List<InvoiceServiceItem> services;

  const InvoiceDetails({
    required this.invoiceId,
    required this.status,
    required this.date,
    this.apiDate,
    required this.totalBefore,
    required this.totalAfter,
    required this.discountPercentage,
    this.paymentLink,
    this.familyId,
    this.familyFirstName,
    this.familyLastName,
    this.beneficiaryName,
    required this.services,
  });

  bool get canContinuePayment {
    final normalizedStatus = status?.trim().toLowerCase();
    final isFinished =
        normalizedStatus == 'paid' ||
        normalizedStatus == 'used' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'canceled' ||
        normalizedStatus == 'cancelled';
    return !isFinished && paymentLink?.trim().isNotEmpty == true;
  }
}

class InvoiceServiceItem {
  final int? id;
  final String? serviceName;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;

  /// Uses the backend percentage when available. Some service items return
  /// zero, so only that value falls back to the item's backend prices.
  double? get displayedDiscountPercentage {
    if (discountPercentage != 0) return discountPercentage;
    if (priceBefore == null || priceAfter == null || priceBefore == 0) {
      return discountPercentage;
    }
    return (priceBefore! - priceAfter!) * 100 / priceBefore!;
  }

  const InvoiceServiceItem({
    required this.id,
    required this.serviceName,
    this.serviceNameAr,
    this.serviceNameEn,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercentage,
  });
}
