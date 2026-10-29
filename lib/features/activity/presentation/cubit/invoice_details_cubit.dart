import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_result.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/usecases/cancel_invoice_usecase.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/get_invoice_details_usecase.dart';

part 'invoice_details_state.dart';

class InvoiceDetailsCubit extends Cubit<InvoiceDetailsState> {
  final GetInvoiceDetailsUseCase _getInvoiceDetails;
  final CancelInvoiceUseCase _cancelInvoice;
  final CreateReviewUseCase _createReview;

  InvoiceDetailsCubit(
    this._getInvoiceDetails,
    this._cancelInvoice,
    this._createReview,
  ) : super(const InvoiceDetailsInitial());

  void emitLoaded(InvoiceDetails details) {
    if (isClosed) return;
    emit(InvoiceDetailsLoaded(details));
  }

  Future<void> loadDetails(int invoiceId) async {
    if (isClosed) return;
    emit(const InvoiceDetailsLoading());

    final result = await _getInvoiceDetails(invoiceId);
    if (isClosed) return;

    result.when(
      success: (details) => emit(InvoiceDetailsLoaded(details)),
      failure: (message) {
        if (kDebugMode) debugPrint('[InvoiceDetails] load failed: $message');
        emit(InvoiceDetailsLoadFailure(message));
      },
    );
  }

  /// Returns the backend failure message, or null on success.
  ///
  /// Cancel/review deliberately do not emit: they would replace the loaded
  /// details state and blank the screen. The caller owns the transient spinner
  /// and the toast, so these stay pure business results.
  Future<String?> cancelInvoice(int invoiceId) async {
    final result = await _cancelInvoice(invoiceId);

    if (isClosed) {
      if (kDebugMode) {
        debugPrint('[InvoiceDetails] cancel completed after close');
      }
      return null;
    }

    return result.when(
      success: (_) => null,
      failure: (message) {
        if (kDebugMode) debugPrint('[InvoiceDetails] cancel failed: $message');
        return message;
      },
    );
  }

  /// Returns the backend failure message, or null on success.
  Future<String?> submitReview({
    required int invoiceId,
    int? rating,
    String? ratingText,
  }) async {
    final result = await _createReview(
      invoiceId: invoiceId,
      rating: rating,
      ratingText: ratingText,
    );

    if (isClosed) {
      if (kDebugMode) {
        debugPrint('[InvoiceDetails] review completed after close');
      }
      return null;
    }

    return result.when(
      success: (_) => null,
      failure: (message) {
        if (kDebugMode) debugPrint('[InvoiceDetails] review failed: $message');
        return message;
      },
    );
  }
}
