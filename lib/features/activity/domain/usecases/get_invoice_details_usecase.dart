import '../../../../core/constants/api_result.dart';
import '../models/invoice_details.dart';
import '../repositories/invoice_repository.dart';

class GetInvoiceDetailsUseCase {
  final InvoiceRepository _repository;

  GetInvoiceDetailsUseCase(this._repository);

  Future<ApiResult<InvoiceDetails>> call(int invoiceId) =>
      _repository.getInvoiceDetails(invoiceId);
}
