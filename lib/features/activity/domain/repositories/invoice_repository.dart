import '../../../../core/constants/api_result.dart';
import '../models/created_invoice.dart';
import '../models/invoice_details.dart';
import '../models/invoices_page.dart';

const invoiceOutcomeUnknownFailure = '__invoice_outcome_unknown__';

/// Backend limitation (documented, no client workaround): invoice creation
/// has no idempotency key or request correlation. A network timeout therefore
/// cannot distinguish "lost before reaching the server" from "created but
/// the response was lost". Callers must treat transport failures as
/// AMBIGUOUS ([invoiceOutcomeUnknownFailure]), must never auto-retry the
/// POST, and must reconcile via fresh reads before resubmitting.
///
/// Current reconciliation (see CartCubit.reconcileUnknownInvoiceOutcome)
/// corroborates a fresh cart read with a matching `my-invoices` entry. It
/// cannot fully close the race where an invoice lands between those two
/// reads. Fully reliable reconciliation requires ONE backend capability:
/// an idempotency key on invoice POST, or a lookup of invoice status by a
/// client-supplied request id.
abstract class InvoiceRepository {
  Future<ApiResult<InvoicesPage>> getMyInvoices({
    int pageNumber = 1,
    int pageSize = 10,
    int? tab,
  });

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
    int? rating,
    String? ratingText,
  });

  Future<ApiResult<void>> cancelInvoice(int invoiceId);
}
