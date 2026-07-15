import '../../../../core/constants/api_result.dart';
import '../models/invoice_item.dart';

abstract class InvoiceRepository {
  Future<ApiResult<List<InvoiceItem>>> getMyInvoices();
}
