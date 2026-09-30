import '../../../../core/constants/api_result.dart';
import '../repositories/invoice_repository.dart';

class CancelInvoiceUseCase {
  final InvoiceRepository _repository;

  CancelInvoiceUseCase(this._repository);

  Future<ApiResult<void>> call(int invoiceId) =>
      _repository.cancelInvoice(invoiceId);
}
