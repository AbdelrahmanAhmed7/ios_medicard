class InvoiceItem {
  final int invoiceId;
  final String providerName;
  final String branchName;
  final String status;
  final DateTime date;
  final String? providerImageUrl;
  final bool isReviewed;
  final bool isFromPackage;
  final double? priceAfter;
  final double? packagePrice;
  final String? beneficiaryName;

  bool get isPending {
    final normalized = status.toLowerCase();
    return normalized == 'pending';
  }

  bool get isPaid {
    final normalized = status.toLowerCase();
    return normalized == 'paid';
  }

  bool get isUsed {
    final normalized = status.toLowerCase();
    return normalized == 'used' || normalized == 'completed';
  }

  bool get isCancelled {
    final normalized = status.toLowerCase();
    return normalized == 'canceled' || normalized == 'cancelled';
  }

  const InvoiceItem({
    required this.invoiceId,
    required this.providerName,
    required this.branchName,
    required this.status,
    required this.date,
    this.providerImageUrl,
    this.isReviewed = false,
    this.isFromPackage = false,
    this.priceAfter,
    this.packagePrice,
    this.beneficiaryName,
  });
}
