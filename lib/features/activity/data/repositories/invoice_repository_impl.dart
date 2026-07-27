import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../data_source/invoice_remote_data_source.dart';
import '../dto/create_cart_invoice_request_dto.dart';
import '../dto/create_package_invoice_request_dto.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _dataSource;

  InvoiceRepositoryImpl(this._dataSource);

  String _failureMessage({
    dynamic errors,
    String? message,
    required String fallback,
  }) {
    final raw = errors != null
        ? errors.toString()
        : message?.isNotEmpty == true
        ? message!
        : fallback;
    return parseApiError(raw);
  }

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
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to load invoices.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<String>> createFromPackage({
    required int packageId,
    required int providerBranchId,
    bool isCash = true,
    String? cardNumber,
  }) async {
    try {
      final response = await _dataSource.createFromPackage(
        CreatePackageInvoiceRequestDto(
          packageId: packageId,
          providerBranchId: providerBranchId,
          isCash: isCash,
          cardNumber: cardNumber,
        ),
      );

      if (response.succeeded == true && response.data != null) {
        return ApiResult.success(response.data.toString());
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to create invoice.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<String>> createFromCart({
    required int providerId,
    required int providerBranchId,
    required bool isCash,
    int? familyId,
    String? cardNumber,
  }) async {
    try {
      final response = await _dataSource.createFromCart(
        CreateCartInvoiceRequestDto(
          providerId: providerId,
          providerBranchId: providerBranchId,
          isCash: isCash,
          familyId: familyId,
          cardNumber: cardNumber,
        ),
      );

      if (response.succeeded == true && response.data != null) {
        return ApiResult.success(response.data.toString());
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to create invoice.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}
