import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'activity_state.dart';

class TabInvoicesData {
  final List<InvoiceItem>? items;
  final int pageNumber;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const TabInvoicesData({
    this.items,
    this.pageNumber = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  TabInvoicesData copyWith({
    List<InvoiceItem>? items,
    int? pageNumber,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return TabInvoicesData(
      items: items ?? this.items,
      pageNumber: pageNumber ?? this.pageNumber,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ActivityCubit extends Cubit<ActivityState> {
  final InvoiceRepository _repository;

  static const int _pageSize = 10;

  final Map<int, TabInvoicesData> _tabData = {
    1: const TabInvoicesData(),
    2: const TabInvoicesData(),
    3: const TabInvoicesData(),
    4: const TabInvoicesData(),
  };

  int _currentTab = 1;
  final Map<int, Future<void>> _invoicesLoads = {};
  final Map<int, Future<void>> _loadMores = {};
  int _requestVersion = 0;

  ActivityCubit(this._repository) : super(const ActivityState.initial());

  int get currentTab => _currentTab;

  TabInvoicesData getTabData(int tab) {
    final data = _tabData[tab];
    if (data != null &&
        (data.items != null || data.isLoading || data.error != null)) {
      return data;
    }
    return state.maybeWhen(
      loading: () => const TabInvoicesData(isLoading: true),
      failure: (err) => TabInvoicesData(error: err),
      success: (inv, loadingMore, more) {
        if (tab == _currentTab) {
          return TabInvoicesData(
            items: inv,
            isLoadingMore: loadingMore,
            hasMore: more,
          );
        }
        return data ?? const TabInvoicesData();
      },
      orElse: () => data ?? const TabInvoicesData(),
    );
  }

  /// Loads invoices for a specific tab (1=Pending, 2=Paid, 3=Used, 4=Canceled).
  Future<void> loadInvoices({int tab = 1, bool forceRefresh = false}) {
    if (isClosed) return Future.value();
    _currentTab = tab;

    if (forceRefresh) {
      // Clear data for other tabs so they refresh when visited
      for (final key in _tabData.keys) {
        if (key != tab) {
          _tabData[key] = const TabInvoicesData();
        }
      }
    }

    final existing = _tabData[tab];
    if (!forceRefresh &&
        existing != null &&
        existing.items != null &&
        !existing.isLoading) {
      emit(
        ActivityState.success(
          invoices: existing.items!,
          hasMore: existing.hasMore,
          isLoadingMore: existing.isLoadingMore,
        ),
      );
      return Future.value();
    }

    final ongoing = _invoicesLoads[tab];
    if (!forceRefresh && ongoing != null) return ongoing;

    final requestVersion = ++_requestVersion;
    final load = _performLoadInvoices(tab: tab, requestVersion: requestVersion);
    _invoicesLoads[tab] = load;
    return load.whenComplete(() {
      if (identical(_invoicesLoads[tab], load)) {
        _invoicesLoads.remove(tab);
      }
    });
  }

  Future<void> loadMore({int? tab}) {
    if (isClosed) return Future.value();
    final targetTab = tab ?? _currentTab;
    final targetData = _tabData[targetTab] ?? const TabInvoicesData();

    if (!targetData.hasMore ||
        targetData.isLoadingMore ||
        targetData.isLoading) {
      return Future.value();
    }

    final ongoing = _loadMores[targetTab];
    if (ongoing != null) return ongoing;

    final load = _performLoadMore(
      tab: targetTab,
      requestVersion: _requestVersion,
    );
    _loadMores[targetTab] = load;
    return load.whenComplete(() {
      if (identical(_loadMores[targetTab], load)) {
        _loadMores.remove(targetTab);
      }
    });
  }

  Future<void> _performLoadInvoices({
    required int tab,
    required int requestVersion,
  }) async {
    if (isClosed) return;
    final prev = _tabData[tab] ?? const TabInvoicesData();
    _tabData[tab] = prev.copyWith(isLoading: true, error: null);

    if (tab == _currentTab && prev.items == null) {
      emit(const ActivityState.loading());
    } else if (tab == _currentTab && prev.items != null) {
      emit(ActivityState.success(invoices: prev.items!, hasMore: prev.hasMore));
    }

    final result = await _repository.getMyInvoices(
      pageNumber: 1,
      pageSize: _pageSize,
      tab: tab,
    );

    if (isClosed) return;

    result.when(
      success: (page) {
        if (isClosed) return;
        _tabData[tab] = TabInvoicesData(
          items: page.items,
          pageNumber: page.pageNumber,
          hasMore: page.hasMore,
          isLoading: false,
        );
        if (kDebugMode) {
          debugPrint(
            '[ActivityCubit] tab=$tab page ${page.pageNumber}/${page.totalPages} '
            'items=${page.items.length}',
          );
        }
        if (tab == _currentTab) {
          emit(
            ActivityState.success(invoices: page.items, hasMore: page.hasMore),
          );
        } else {
          final activeData = _tabData[_currentTab];
          if (activeData != null && activeData.items != null) {
            emit(
              ActivityState.success(
                invoices: activeData.items!,
                hasMore: activeData.hasMore,
              ),
            );
          }
        }
      },
      failure: (message) {
        if (isClosed) return;
        _tabData[tab] = (_tabData[tab] ?? const TabInvoicesData()).copyWith(
          isLoading: false,
          error: message,
        );
        if (tab == _currentTab && (_tabData[tab]?.items == null)) {
          emit(ActivityState.failure(message));
        }
      },
    );
  }

  Future<void> _performLoadMore({
    required int tab,
    required int requestVersion,
  }) async {
    if (isClosed) return;
    final prev = _tabData[tab] ?? const TabInvoicesData();
    _tabData[tab] = prev.copyWith(isLoadingMore: true);

    if (tab == _currentTab && prev.items != null) {
      emit(
        ActivityState.success(
          invoices: prev.items!,
          isLoadingMore: true,
          hasMore: true,
        ),
      );
    }

    final nextPage = prev.pageNumber + 1;
    final result = await _repository.getMyInvoices(
      pageNumber: nextPage,
      pageSize: _pageSize,
      tab: tab,
    );

    if (isClosed) return;

    result.when(
      success: (page) {
        if (isClosed) return;
        final currentItems = _tabData[tab]?.items ?? const [];
        final existingIds = currentItems.map((e) => e.invoiceId).toSet();
        final newItems = page.items
            .where((item) => !existingIds.contains(item.invoiceId))
            .toList();
        final updatedItems = [...currentItems, ...newItems];

        _tabData[tab] = TabInvoicesData(
          items: updatedItems,
          pageNumber: page.pageNumber,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );

        if (tab == _currentTab) {
          emit(
            ActivityState.success(
              invoices: updatedItems,
              isLoadingMore: false,
              hasMore: page.hasMore,
            ),
          );
        }
      },
      failure: (message) {
        if (isClosed) return;
        if (kDebugMode) {
          debugPrint('[ActivityCubit] loadMore failed: $message');
        }
        _tabData[tab] = (_tabData[tab] ?? const TabInvoicesData()).copyWith(
          isLoadingMore: false,
        );
        if (tab == _currentTab && prev.items != null) {
          emit(
            ActivityState.success(
              invoices: prev.items!,
              isLoadingMore: false,
              hasMore: true,
            ),
          );
        }
      },
    );
  }
}
