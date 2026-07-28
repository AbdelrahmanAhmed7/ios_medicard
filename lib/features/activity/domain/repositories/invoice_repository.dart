import '../../../../core/constants/api_result.dart';
import '../models/created_invoice.dart';
import '../models/invoice_details.dart';
import '../models/invoice_item.dart';

abstract class InvoiceRepository {
  Future<ApiResult<List<InvoiceItem>>> getMyInvoices();

  Future<ApiResult<CreatedInvoice>> createFromPackage({
    required int packageId,
    required int providerBranchId,
    bool isCash = true,
    String? cardNumber,
  });

  Future<ApiResult<CreatedInvoice>> createFromCart({
    required int providerId,
    required int providerBranchId,
    required bool isCash,
    int? familyId,
    String? cardNumber,
  });

  Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId);

  Future<ApiResult<void>> createReview({
    required int invoiceId,
    required int rating,
    required String ratingText,
  });
}
