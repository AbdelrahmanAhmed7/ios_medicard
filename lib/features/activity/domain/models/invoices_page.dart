import 'invoice_item.dart';

class InvoicesPage {
  final List<InvoiceItem> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const InvoicesPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasMore => pageNumber < totalPages;
}
