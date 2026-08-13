class InvoiceItem {
  final int invoiceId;
  final String providerName;
  final String branchName;
  final String status;
  final DateTime date;
  final String? providerImageUrl;

  /// Returns true when the invoice has been used/consumed.
  bool get isUsed {
    final normalized = status.toLowerCase();
    return normalized == 'used' || normalized == 'completed';
  }

  const InvoiceItem({
    required this.invoiceId,
    required this.providerName,
    required this.branchName,
    required this.status,
    required this.date,
    this.providerImageUrl,
  });
}
