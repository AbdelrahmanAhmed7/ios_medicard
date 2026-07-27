class InvoiceDetails {
  final int invoiceId;
  final String status;
  final DateTime date;
  final double totalBefore;
  final double totalAfter;
  final List<InvoiceServiceItem> services;

  const InvoiceDetails({
    required this.invoiceId,
    required this.status,
    required this.date,
    required this.totalBefore,
    required this.totalAfter,
    required this.services,
  });

  double get discount => totalBefore - totalAfter;
}

class InvoiceServiceItem {
  final int id;
  final String serviceName;
  final double priceBefore;
  final double priceAfter;
  final double discountPercentage;

  const InvoiceServiceItem({
    required this.id,
    required this.serviceName,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercentage,
  });
}
