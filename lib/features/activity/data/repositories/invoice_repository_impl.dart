import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../data_source/invoice_remote_data_source.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _dataSource;

  InvoiceRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<InvoiceItem>>> getMyInvoices() async {
    try {
      final response = await _dataSource.getMyInvoices();

      if (response.succeeded == true && response.data != null) {
        final items = response.data!
            .map(
              (dto) => InvoiceItem(
                invoiceId: dto.invoiceId ?? 0,
                providerName: dto.providerName ?? '',
                branchName: dto.branchName ?? '',
                status: dto.status ?? '',
                date: DateTime.tryParse(dto.date ?? '') ?? DateTime.now(),
                providerImageUrl: dto.providerImageUrl,
              ),
            )
            .toList();
        return ApiResult.success(items);
      }

      return ApiResult.failure(
        (response.errors != null)
            ? response.errors.toString()
            : response.message?.isNotEmpty == true
            ? response.message!
            : 'Failed to load invoices.',
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}
