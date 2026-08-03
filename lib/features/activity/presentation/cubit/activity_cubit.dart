import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final InvoiceRepository _repository;

  static const int _pageSize = 10;

  Future<void>? _invoicesLoad;
  Future<void>? _loadMore;
  int _currentPage = 0;

  ActivityCubit(this._repository) : super(const ActivityState.initial());

  Future<void> loadInvoices() {
    if (isClosed) return Future.value();
    final ongoing = _invoicesLoad;
    if (ongoing != null) return ongoing;

    final load = _performLoadInvoices();
    _invoicesLoad = load;
    return load.whenComplete(() {
      if (identical(_invoicesLoad, load)) {
        _invoicesLoad = null;
      }
    });
  }

  Future<void> loadMore() {
    if (isClosed) return Future.value();

    final canLoadMore = state.maybeWhen(
      success: (_, isLoadingMore, hasMore) => hasMore && !isLoadingMore,
      orElse: () => false,
    );
    if (!canLoadMore) return Future.value();

    final ongoing = _loadMore;
    if (ongoing != null) return ongoing;

    final load = _performLoadMore();
    _loadMore = load;
    return load.whenComplete(() {
      if (identical(_loadMore, load)) {
        _loadMore = null;
      }
    });
  }

  Future<void> _performLoadInvoices() async {
    if (isClosed) return;
    emit(const ActivityState.loading());
    _currentPage = 0;

    final result = await _repository.getMyInvoices(
      pageNumber: 1,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (page) {
        if (isClosed) return;
        _currentPage = page.pageNumber;
        if (kDebugMode) {
          debugPrint(
            '[ActivityCubit] page ${page.pageNumber}/${page.totalPages} '
            'items=${page.items.length}',
          );
        }
        emit(
          ActivityState.success(
            invoices: page.items,
            hasMore: page.hasMore,
          ),
        );
      },
      failure: (message) {
        if (isClosed) return;
        emit(ActivityState.failure(message));
      },
    );
  }

  Future<void> _performLoadMore() async {
    if (isClosed) return;

    final currentInvoices = state.maybeWhen(
      success: (invoices, _, _) => invoices,
      orElse: () => const <InvoiceItem>[],
    );

    emit(
      ActivityState.success(
        invoices: currentInvoices,
        isLoadingMore: true,
        hasMore: true,
      ),
    );

    final nextPage = _currentPage + 1;
    final result = await _repository.getMyInvoices(
      pageNumber: nextPage,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (page) {
        if (isClosed) return;
        _currentPage = page.pageNumber;

        final existingIds = currentInvoices.map((e) => e.invoiceId).toSet();
        final newItems = page.items
            .where((item) => !existingIds.contains(item.invoiceId))
            .toList();
        final merged = [...currentInvoices, ...newItems];

        emit(
          ActivityState.success(
            invoices: merged,
            isLoadingMore: false,
            hasMore: page.hasMore,
          ),
        );
      },
      failure: (message) {
        if (isClosed) return;
        if (kDebugMode) {
          debugPrint('[ActivityCubit] loadMore failed: $message');
        }
        emit(
          ActivityState.success(
            invoices: currentInvoices,
            isLoadingMore: false,
            hasMore: true,
          ),
        );
      },
    );
  }
}
