import '../../../../core/constants/api_result.dart';
import '../models/invoice_item.dart';

abstract class InvoiceRepository {
  Future<ApiResult<List<InvoiceItem>>> getMyInvoices();

  Future<ApiResult<String>> createFromPackage({
    required int packageId,
    required int providerBranchId,
    bool isCash = true,
    String? cardNumber,
  });

  Future<ApiResult<String>> createFromCart({
    required int providerId,
    required int providerBranchId,
    required bool isCash,
    int? familyId,
    String? cardNumber,
  });
}
