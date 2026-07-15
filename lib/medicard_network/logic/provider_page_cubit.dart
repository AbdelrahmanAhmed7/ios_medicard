import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/api_result.dart';
import '../../features/cart/domain/repository/cart_repository.dart';
import '../../network/data/provider_page_response_model.dart';
import '../repository/medicard_network_repository.dart';
import 'provider_page_state.dart';

class ProviderPageCubit extends Cubit<ProviderPageState> {
  final MedicardNetworkRepository _medicardRepository;
  final CartRepository _cartRepository;
  final int providerId;

  List<ProviderPackage> _fullPackages = [];
  static const int _pageSize = 20;
  int _packagesCurrentPage = 1;
  Timer? _debounceTimer;

  ProviderPageCubit(
    this._medicardRepository,
    this._cartRepository,
    // SearchRemoteDataSource is no longer needed — categories come from the
    // Cart/category endpoint, not from Lookups.
    dynamic _unused,
    this.providerId,
  ) : super(const ProviderPageState());

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await Future.wait([loadProviderPage(), getCart()]);
  }

  // ── Cart ───────────────────────────────────────────────────────────────────

  Future<void> getCart() async {
    if (isClosed) return;
    emit(state.copyWith(isCartLoading: true));
    final result = await _cartRepository.getCart();
    if (isClosed) return;
    result.when(
      success: (cart) {
        if (isClosed) return;
        emit(state.copyWith(cartItems: cart.items, isCartLoading: false));
        // Refresh selectedCount badges on all loaded tabs after cart changes.
        _refreshAllTabSelectedCounts();
      },
      failure: (_) {
        if (isClosed) return;
        emit(state.copyWith(isCartLoading: false));
      },
    );
  }

  Future<void> addToCart(int serviceId) async {
    final categoryId = state.selectedTab?.categoryId;
    if (categoryId == null || isClosed) return;

    emit(
      state.copyWith(
        pendingCartActionIds: {...state.pendingCartActionIds, serviceId},
      ),
    );

    final result = await _cartRepository.addToCart(
      serviceId: serviceId,
      categoryId: categoryId,
    );

    if (isClosed) return;
    final updatedPending = Set<int>.from(state.pendingCartActionIds)
      ..remove(serviceId);

    result.when(
      success: (_) async {
        if (isClosed) return;
        emit(state.copyWith(pendingCartActionIds: updatedPending));
        // Refresh cart items AND reload the current tab to get updated
        // totalSelectedCount + isSelected flags.
        await Future.wait([getCart(), _reloadTab(state.selectedCategoryIndex)]);
      },
      failure: (_) {
        if (isClosed) return;
        emit(state.copyWith(pendingCartActionIds: updatedPending));
      },
    );
  }

  Future<void> removeFromCart(int serviceId) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        pendingCartActionIds: {...state.pendingCartActionIds, serviceId},
      ),
    );

    final result = await _cartRepository.removeFromCart(serviceId);
    if (isClosed) return;
    final updatedPending = Set<int>.from(state.pendingCartActionIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        if (isClosed) return;
        final updatedItems = state.cartItems
            .where((item) => item.serviceId != serviceId)
            .toList();
        emit(
          state.copyWith(
            cartItems: updatedItems,
            pendingCartActionIds: updatedPending,
          ),
        );
        // Reload current tab so totalSelectedCount badge updates.
        _reloadTab(state.selectedCategoryIndex);
      },
      failure: (_) {
        if (isClosed) return;
        emit(state.copyWith(pendingCartActionIds: updatedPending));
      },
    );
  }

  // ── Provider page ──────────────────────────────────────────────────────────

  Future<void> loadProviderPage() async {
    if (isClosed) return;
    emit(state.copyWith(isProviderLoading: true, resetProviderError: true));

    final result = await _medicardRepository.getProviderPage(
      providerId: providerId,
    );

    if (isClosed) return;
    result.when(
      success: (response) async {
        if (response.data == null) {
          if (isClosed) return;
          emit(
            state.copyWith(
              isProviderLoading: false,
              providerError: response.message ?? 'No data',
            ),
          );
          return;
        }

        final data = response.data!;
        if (isClosed) return;
        emit(state.copyWith(isProviderLoading: false, providerData: data));

        // Build the initial tab list from the provider's categoryId.
        // Each tab is loaded on demand via _loadTabServices().
        if (data.categoryId != null) {
          final initialTab = CategoryTab(
            categoryId: data.categoryId!,
            categoryName: data.categoryName,
            isLoading: true,
          );
          emit(state.copyWith(categoryTabs: [initialTab]));
          await _loadTabServices(0, data.categoryId!);
        }
      },
      failure: (error) {
        if (isClosed) return;
        emit(state.copyWith(isProviderLoading: false, providerError: error));
      },
    );
  }

  // ── Category tabs ──────────────────────────────────────────────────────────

  /// Loads `GET /Cart/category/{categoryId}/services` for tab at [index].
  /// Updates the tab in-place with services + totalSelectedCount.
  Future<void> _loadTabServices(int index, int categoryId) async {
    if (isClosed) return;

    // Mark the tab as loading.
    _updateTab(index, (tab) => tab.copyWith(isLoading: true, clearError: true));

    final result = await _cartRepository.getCategoryServices(categoryId);

    if (isClosed) return;
    result.when(
      success: (categoryServices) {
        _updateTab(
          index,
          (tab) => tab.copyWith(
            services: categoryServices,
            isLoading: false,
            clearError: true,
          ),
        );
      },
      failure: (error) {
        _updateTab(
          index,
          (tab) => tab.copyWith(isLoading: false, error: error),
        );
      },
    );
  }

  /// Reloads the tab at [index] — used after add/remove to refresh
  /// `totalSelectedCount` and `isSelected` on each service row.
  Future<void> _reloadTab(int index) async {
    if (index >= state.categoryTabs.length) return;
    final categoryId = state.categoryTabs[index].categoryId;
    await _loadTabServices(index, categoryId);
  }

  /// Refreshes totalSelectedCount on every tab that has already been loaded
  /// (triggered after cart changes from outside this screen).
  void _refreshAllTabSelectedCounts() {
    for (int i = 0; i < state.categoryTabs.length; i++) {
      if (state.categoryTabs[i].services != null) {
        _reloadTab(i);
      }
    }
  }

  /// Selects a different category tab; loads its services if not yet loaded.
  Future<void> selectCategoryTab(int index) async {
    if (index == state.selectedCategoryIndex) return;
    if (isClosed) return;
    emit(state.copyWith(selectedCategoryIndex: index));

    // Load services for this tab if not loaded yet.
    if (state.categoryTabs[index].services == null &&
        !state.categoryTabs[index].isLoading) {
      await _loadTabServices(index, state.categoryTabs[index].categoryId);
    }
  }

  /// Retries loading the services for tab at [index] after an error.
  Future<void> retryTabLoad(int index) async {
    if (index >= state.categoryTabs.length) return;
    await _loadTabServices(index, state.categoryTabs[index].categoryId);
  }

  // ── Helper: immutably update one tab in the list ───────────────────────────

  void _updateTab(int index, CategoryTab Function(CategoryTab) updater) {
    if (isClosed) return;
    final tabs = List<CategoryTab>.from(state.categoryTabs);
    if (index >= tabs.length) return;
    tabs[index] = updater(tabs[index]);
    emit(state.copyWith(categoryTabs: tabs));
  }

  // ── Packages ───────────────────────────────────────────────────────────────

  Future<void> loadPackages({bool reset = false}) async {
    if (isClosed) return;
    if (reset) {
      _packagesCurrentPage = 1;
      _fullPackages = [];
      emit(
        state.copyWith(
          packages: [],
          fullPackages: [],
          packagesHasMore: true,
          isPackagesLoadingMore: false,
        ),
      );
    }
    if (state.isPackagesLoading || (state.isPackagesLoadingMore && !reset)) {
      return;
    }

    if (_packagesCurrentPage == 1) {
      emit(state.copyWith(isPackagesLoading: true, resetPackagesError: true));
    } else {
      emit(state.copyWith(isPackagesLoadingMore: true));
    }

    final result = await _medicardRepository.getProviderPackages(
      providerId: providerId,
      pageNumber: _packagesCurrentPage,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (response) {
        if (isClosed) return;
        final newPackages = response.data?.items ?? [];
        final allPackages = [..._fullPackages, ...newPackages];
        _fullPackages = allPackages;
        final hasMore = _packagesCurrentPage < (response.data?.totalPages ?? 1);
        _packagesCurrentPage++;
        emit(
          state.copyWith(
            fullPackages: allPackages,
            packages: _filterPackages(allPackages, state.searchQuery),
            packagesHasMore: hasMore,
            isPackagesLoading: false,
            isPackagesLoadingMore: false,
          ),
        );
      },
      failure: (error) {
        if (isClosed) return;
        emit(
          state.copyWith(
            packagesError: error,
            isPackagesLoading: false,
            isPackagesLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> loadMorePackages() async => loadPackages();

  Future<void> togglePackageDetails(int packageId) async {
    if (isClosed) return;

    final expandedIds = Set<int>.from(state.expandedPackageIds);
    final willExpand = !expandedIds.contains(packageId);
    if (willExpand) {
      expandedIds.add(packageId);
    } else {
      expandedIds.remove(packageId);
    }
    emit(state.copyWith(expandedPackageIds: expandedIds));

    if (!willExpand ||
        state.packageDetailsById.containsKey(packageId) ||
        state.loadingPackageDetailsIds.contains(packageId)) {
      return;
    }

    final loadingIds = Set<int>.from(state.loadingPackageDetailsIds)
      ..add(packageId);
    final errors = Map<int, String>.from(state.packageDetailsErrors)
      ..remove(packageId);
    emit(
      state.copyWith(
        loadingPackageDetailsIds: loadingIds,
        packageDetailsErrors: errors,
      ),
    );

    final result = await _medicardRepository.getPackageDetails(
      packageId: packageId,
    );
    if (isClosed) return;

    final updatedLoadingIds = Set<int>.from(state.loadingPackageDetailsIds)
      ..remove(packageId);

    result.when(
      success: (response) {
        final details = response.data;
        if (details == null) {
          final nextErrors = Map<int, String>.from(state.packageDetailsErrors)
            ..[packageId] = 'No package details found';
          emit(
            state.copyWith(
              loadingPackageDetailsIds: updatedLoadingIds,
              packageDetailsErrors: nextErrors,
            ),
          );
          return;
        }

        final detailsById = Map<int, PackageDetailsData>.from(
          state.packageDetailsById,
        )..[packageId] = details;
        emit(
          state.copyWith(
            packageDetailsById: detailsById,
            loadingPackageDetailsIds: updatedLoadingIds,
          ),
        );
      },
      failure: (error) {
        final nextErrors = Map<int, String>.from(state.packageDetailsErrors)
          ..[packageId] = error;
        emit(
          state.copyWith(
            loadingPackageDetailsIds: updatedLoadingIds,
            packageDetailsErrors: nextErrors,
          ),
        );
      },
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void updateSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      emit(
        state.copyWith(
          searchQuery: query.isEmpty ? null : query,
          resetSearchQuery: query.isEmpty,
          packages: _filterPackages(
            state.fullPackages,
            query.isEmpty ? null : query,
          ),
        ),
      );
    });
  }

  List<ProviderPackage> _filterPackages(
    List<ProviderPackage> packages,
    String? query,
  ) {
    if (query == null || query.isEmpty) return packages;
    final q = query.toLowerCase();
    return packages
        .where((p) => p.name?.toLowerCase().contains(q) ?? false)
        .toList();
  }

  // ── View switch ────────────────────────────────────────────────────────────

  Future<void> switchView(ProviderViewType view) async {
    if (isClosed) return;
    emit(state.copyWith(currentView: view));
    if (view == ProviderViewType.packages && state.packages.isEmpty) {
      await loadPackages(reset: true);
    }
  }

  // ── No-ops kept for API compatibility ──────────────────────────────────────

  Future<void> loadProviderServices({bool reset = false}) async {}
  Future<void> loadServices({bool reset = false}) async {}
  Future<void> loadMoreServices() async {}

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
