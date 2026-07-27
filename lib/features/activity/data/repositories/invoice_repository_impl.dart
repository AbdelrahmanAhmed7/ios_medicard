import '../../../../core/constants/api_result.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../domain/models/created_invoice.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../data_source/invoice_remote_data_source.dart';
import '../dto/create_cart_invoice_request_dto.dart';
import '../dto/create_review_request_dto.dart';
import '../dto/create_package_invoice_request_dto.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _dataSource;

  InvoiceRepositoryImpl(this._dataSource);

  String _failureMessage({
    dynamic errors,
    String? message,
    required String fallback,
  }) {
    final raw =
        _readableError(errors) ??
        (message?.isNotEmpty == true ? message! : fallback);
    return parseApiError(raw);
  }

  String? _readableError(dynamic errors) {
    if (errors == null) return null;
    if (errors is String && errors.trim().isNotEmpty) return errors.trim();
    if (errors is List && errors.isNotEmpty) {
      return _readableError(errors.first);
    }
    if (errors is Map) {
      for (final key in const ['message', 'error', 'description']) {
        final value = errors[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      for (final value in errors.values) {
        final parsed = _readableError(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
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
  Future<ApiResult<CreatedInvoice>> createFromCart({
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
        return ApiResult.success(_createdInvoiceFromData(response.data));
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

  CreatedInvoice _createdInvoiceFromData(dynamic data) {
    if (data is Map) {
      final invoiceId =
          data['invoiceId'] ??
          data['id'] ??
          data['invoiceNumber'] ??
          data['orderNumber'] ??
          data['invoice'];
      final paymentLink =
          data['paymentLink'] ??
          data['paymentUrl'] ??
          data['url'] ??
          data['redirectUrl'];
      return CreatedInvoice(
        invoiceId: invoiceId?.toString() ?? data.toString(),
        paymentLink: paymentLink?.toString(),
      );
    }

    return CreatedInvoice(invoiceId: data.toString());
  }

  @override
  Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId) async {
    try {
      final response = await _dataSource.getInvoiceDetails(invoiceId);
      final data = response.data;
      if (response.succeeded == true && data != null) {
        return ApiResult.success(
          InvoiceDetails(
            invoiceId: data.invoiceId ?? invoiceId,
            status: data.status ?? '',
            date: DateTime.tryParse(data.date ?? '') ?? DateTime.now(),
            totalBefore: data.totalBefore ?? 0,
            totalAfter: data.totalAfter ?? 0,
            services: (data.items?.items ?? const [])
                .map(
                  (item) => InvoiceServiceItem(
                    id: item.id ?? 0,
                    serviceName: item.serviceNameEn ?? item.serviceName ?? '',
                    priceBefore: item.priceBefore ?? 0,
                    priceAfter: item.priceAfter ?? 0,
                    discountPercentage: item.discountPercentage ?? 0,
                  ),
                )
                .toList(),
          ),
        );
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to load invoice details.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> createReview({
    required int invoiceId,
    required int rating,
    required String ratingText,
  }) async {
    try {
      final response = await _dataSource.createReview(
        CreateReviewRequestDto(
          invoiceId: invoiceId,
          rating: rating,
          ratingText: ratingText,
        ),
      );

      if (response.succeeded == true) {
        return const ApiResult.success(null);
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: 'Failed to submit review.',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}
