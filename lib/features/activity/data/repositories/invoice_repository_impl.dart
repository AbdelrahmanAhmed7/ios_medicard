import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/network/app_failure.dart';
import '../../../../core/services/app_language_manager.dart';
import '../../../../core/utils/api_error_parser.dart';
import '../../domain/models/created_invoice.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/invoices_page.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../data_source/invoice_remote_data_source.dart';
import '../dto/create_cart_invoice_request_dto.dart';
import '../dto/create_review_request_dto.dart';
import '../dto/create_package_invoice_request_dto.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource _dataSource;

  InvoiceRepositoryImpl(this._dataSource);

  bool _isAmbiguousCreationError(Object error) {
    if (error is AppFailure) {
      return error.type == AppFailureType.network ||
          error.type == AppFailureType.timeout ||
          error.type == AppFailureType.connectionTimeout ||
          error.type == AppFailureType.transferTimeout;
    }
    if (error is! DioException || error.response != null) return false;
    final mapped = error.error;
    if (mapped is AppFailure && _isAmbiguousCreationError(mapped)) return true;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown;
  }

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
  Future<ApiResult<InvoicesPage>> getMyInvoices({
    int pageNumber = 1,
    int pageSize = 10,
    int? tab,
  }) async {
    try {
      final response = await _dataSource.getMyInvoices(
        language: AppLanguageManager.instance.currentLanguage,
        pageNumber: pageNumber,
        pageSize: pageSize,
        tab: tab,
      );

      if (response.succeeded == true) {
        final page = response.data;
        final items = (page?.items ?? const [])
            .map(
              (dto) => InvoiceItem(
                invoiceId: dto.invoiceId ?? 0,
                providerName: dto.providerName ?? '',
                branchName: dto.branchName ?? '',
                status: dto.status ?? '',
                date: DateTime.tryParse(dto.date ?? '') ?? DateTime.now(),
                providerImageUrl: dto.providerImageUrl,
                isReviewed: dto.isReviewed ?? false,
                points: dto.points,
                isFromPackage: dto.isFromPackage ?? false,
                priceAfter: dto.priceAfter,
                priceBefore: dto.priceBefore,
                discountPercentage: dto.discountPercentage,
                isMedicineInvoice: dto.isMedicineInvoice ?? false,
                itemsCount: dto.itemsCount,
                totalQuantity: dto.totalQuantity,
                familyId: dto.familyId,
                beneficiaryName: _beneficiaryName(
                  firstName: dto.familyFirstName,
                  lastName: dto.familyLastName,
                ),
              ),
            )
            .toList();

        // TEMP-STATUS-DEBUG: remove after diagnosing Arabic status issue.
        debugPrint(
          '[TEMP] my-invoices tab=$tab lang=${AppLanguageManager.instance.currentLanguage} '
          'statuses=${items.map((e) => '${e.invoiceId}:${e.status}').join(', ')}',
        );

        final invoicesPage = InvoicesPage(
          items: items,
          pageNumber: page?.pageNumber ?? pageNumber,
          pageSize: page?.pageSize ?? pageSize,
          totalCount: page?.totalCount ?? items.length,
          totalPages: page?.totalPages ?? 1,
        );

        if (kDebugMode) {
          debugPrint(
            '[Activity] invoices loaded page=${invoicesPage.pageNumber}/'
            '${invoicesPage.totalPages} count=${items.length} '
            'total=${invoicesPage.totalCount}',
          );
        }
        return ApiResult.success(invoicesPage);
      }

      if (kDebugMode) {
        debugPrint(
          '[Activity] invoices failed succeeded=${response.succeeded} message=${response.message} errors=${response.errors}',
        );
      }
      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: '',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<CreatedInvoice>> createFromPackage({
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
        final invoice = _createdInvoiceFromData(response.data);
        if (invoice != null) return ApiResult.success(invoice);
        return ApiResult.failure(parseApiError('Invalid invoice response.'));
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: '',
        ),
      );
    } catch (error) {
      if (_isAmbiguousCreationError(error)) {
        return const ApiResult.failure(invoiceOutcomeUnknownFailure);
      }
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
        final invoice = _createdInvoiceFromData(response.data);
        if (invoice != null) return ApiResult.success(invoice);
        return ApiResult.failure(parseApiError('Invalid invoice response.'));
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: '',
        ),
      );
    } catch (error) {
      if (_isAmbiguousCreationError(error)) {
        return const ApiResult.failure(invoiceOutcomeUnknownFailure);
      }
      return ApiResult.failure(parseApiError(error));
    }
  }

  String? _beneficiaryName({String? firstName, String? lastName}) {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) return null;
    return '$first $last'.trim();
  }

  CreatedInvoice? _createdInvoiceFromData(dynamic data) {
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
      final normalizedInvoiceId = _validInvoiceId(invoiceId);
      if (normalizedInvoiceId == null) return null;
      return CreatedInvoice(
        invoiceId: normalizedInvoiceId,
        paymentLink: paymentLink?.toString(),
      );
    }

    final normalizedInvoiceId = _validInvoiceId(data);
    if (normalizedInvoiceId == null) return null;
    return CreatedInvoice(invoiceId: normalizedInvoiceId);
  }

  String? _validInvoiceId(dynamic value) {
    if (value is num) {
      if (!value.isFinite || value <= 0) return null;
      return value.toString();
    }
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId) async {
    try {
      final response = await _dataSource.getInvoiceDetails(invoiceId);
      final data = response.data;
      if (response.succeeded == true && data != null) {
        return ApiResult.success(
          InvoiceDetails(
            invoiceId: data.invoiceId,
            status: data.status,
            date: data.date == null ? null : DateTime.tryParse(data.date!),
            apiDate: data.date,
            totalBefore: data.totalBefore,
            totalAfter: data.totalAfter,
            discountPercentage: data.discountPercentage,
            paymentLink: data.paymentLink,
            familyId: data.familyId,
            familyFirstName: data.familyFirstName,
            familyLastName: data.familyLastName,
            beneficiaryName: _beneficiaryName(
              firstName: data.familyFirstName,
              lastName: data.familyLastName,
            ),
            review: data.review == null
                ? null
                : InvoiceReview(
                    userName: data.review!.userName,
                    userImageUrl: data.review!.userImageUrl,
                    rating: data.review!.rating,
                    ratingText: data.review!.ratingText,
                    createdAt: data.review!.createdAt == null
                        ? null
                        : DateTime.tryParse(data.review!.createdAt!),
                    apiCreatedAt: data.review!.createdAt,
                  ),
            services: (data.items?.items ?? const [])
                .map(
                  (item) => InvoiceServiceItem(
                    id: item.id,
                    serviceName: item.serviceName,
                    serviceNameAr: item.serviceNameAr,
                    serviceNameEn: item.serviceNameEn,
                    priceBefore: item.priceBefore,
                    priceAfter: item.priceAfter,
                    discountPercentage: item.discountPercentage,
                  ),
                )
                .toList(),
            providerName: data.providerName,
            branchName: data.branchName,
            providerImageUrl: data.providerImageUrl,
          ),
        );
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: '',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> createReview({
    required int invoiceId,
    int? rating,
    String? ratingText,
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
          fallback: '',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }

  @override
  Future<ApiResult<void>> cancelInvoice(int invoiceId) async {
    try {
      final response = await _dataSource.cancelInvoice(invoiceId);

      if (response.succeeded == true) {
        return const ApiResult.success(null);
      }

      return ApiResult.failure(
        _failureMessage(
          errors: response.errors,
          message: response.message,
          fallback: '',
        ),
      );
    } catch (error) {
      return ApiResult.failure(parseApiError(error));
    }
  }
}
