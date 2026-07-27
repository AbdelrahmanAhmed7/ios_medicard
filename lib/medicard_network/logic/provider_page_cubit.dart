import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/api_result.dart';
import '../../features/activity/domain/repositories/invoice_repository.dart';
import '../../features/cart/domain/repository/cart_repository.dart';
import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';
import '../repository/medicard_network_repository.dart';
import 'provider_page_state.dart';

class ProviderPageCubit extends Cubit<ProviderPageState> {
  final MedicardNetworkRepository _medicardRepository;
  final InvoiceRepository _invoiceRepository;
  final CartRepository _cartRepository;
  final int providerId;

  static const int _pageSize = 12;
  final List<ProviderPackage> _fullPackages = [];
  final List<ProviderReview> _fullReviews = [];
  List<ProviderService> _fullServices = [];
  int _packagesCurrentPage = 1;
  int _reviewsCurrentPage = 1;
  Timer? _debounceTimer;

  ProviderPageCubit(
    this._medicardRepository,
    this._invoiceRepository,
    this._cartRepository,
    this.providerId,
  ) : super(const ProviderPageState());

  Future<void> init() async => loadProviderPage();

  Future<void> loadProviderPage() async {
    if (isClosed) return;
    emit(state.copyWith(isProviderLoading: true, resetProviderError: true));

    final result = await _medicardRepository.getProviderPage(
      providerId: providerId,
    );

    if (isClosed) return;
    result.when(
      success: (response) {
        final data = response.data;
        if (data == null) {
          emit(
            state.copyWith(
              isProviderLoading: false,
              providerError: response.message ?? 'No provider data found.',
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            isProviderLoading: false,
            providerData: data,
            resetProviderError: true,
            resetServicesError: true,
          ),
        );
        loadServices(reset: true);
      },
      failure: (error) {
        emit(state.copyWith(isProviderLoading: false, providerError: error));
      },
    );
  }

  Future<void> loadPackages({bool reset = false}) async {
    if (isClosed) return;
    if (reset) {
      _packagesCurrentPage = 1;
      _fullPackages.clear();
      emit(
        state.copyWith(
          packages: const [],
          fullPackages: const [],
          packagesHasMore: true,
          isPackagesLoadingMore: false,
          resetPackagesError: true,
        ),
      );
    }

    if (state.isPackagesLoading || (state.isPackagesLoadingMore && !reset)) {
      return;
    }
    if (!reset && !state.packagesHasMore) return;

    emit(
      state.copyWith(
        isPackagesLoading: _packagesCurrentPage == 1,
        isPackagesLoadingMore: _packagesCurrentPage > 1,
        resetPackagesError: true,
      ),
    );

    final result = await _medicardRepository.getProviderPackages(
      providerId: providerId,
      pageNumber: _packagesCurrentPage,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (response) {
        final newPackages = response.data?.items ?? const <ProviderPackage>[];
        _fullPackages.addAll(newPackages);
        final totalPages = response.data?.totalPages ?? _packagesCurrentPage;
        final hasMore = _packagesCurrentPage < totalPages;
        if (hasMore) _packagesCurrentPage++;

        emit(
          state.copyWith(
            fullPackages: List<ProviderPackage>.from(_fullPackages),
            packages: _filterPackages(_fullPackages, state.searchQuery),
            packagesHasMore: hasMore,
            isPackagesLoading: false,
            isPackagesLoadingMore: false,
          ),
        );
      },
      failure: (error) {
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

  Future<void> loadReviews({bool reset = false}) async {
    if (isClosed) return;
    if (reset) {
      _reviewsCurrentPage = 1;
      _fullReviews.clear();
      emit(
        state.copyWith(
          reviews: const [],
          fullReviews: const [],
          reviewsHasMore: true,
          isReviewsLoadingMore: false,
          resetReviewsError: true,
        ),
      );
    }

    if (state.isReviewsLoading || (state.isReviewsLoadingMore && !reset)) {
      return;
    }
    if (!reset && !state.reviewsHasMore) return;

    emit(
      state.copyWith(
        isReviewsLoading: _reviewsCurrentPage == 1,
        isReviewsLoadingMore: _reviewsCurrentPage > 1,
        resetReviewsError: true,
      ),
    );

    final result = await _medicardRepository.getProviderReviews(
      providerId: providerId,
      pageNumber: _reviewsCurrentPage,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (response) {
        final newReviews = response.data?.items ?? const <ProviderReview>[];
        _fullReviews.addAll(newReviews);
        final totalPages = response.data?.totalPages ?? _reviewsCurrentPage;
        final hasMore = _reviewsCurrentPage < totalPages;
        if (hasMore) _reviewsCurrentPage++;

        emit(
          state.copyWith(
            fullReviews: List<ProviderReview>.from(_fullReviews),
            reviews: _filterReviews(_fullReviews, state.searchQuery),
            reviewsHasMore: hasMore,
            isReviewsLoading: false,
            isReviewsLoadingMore: false,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            reviewsError: error,
            isReviewsLoading: false,
            isReviewsLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> loadMoreReviews() async => loadReviews();

  Future<void> loadProviderServices({bool reset = false}) async =>
      loadServices(reset: reset);

  Future<void> loadServices({bool reset = false}) async {
    if (isClosed) return;
    emit(state.copyWith(isServicesLoading: true, resetServicesError: true));

    final result = await _medicardRepository.getProviderServices(
      providerId: providerId,
      search: state.searchQuery,
      pageNumber: 1,
      pageSize: _pageSize,
    );

    if (isClosed) return;
    result.when(
      success: (response) {
        _fullServices = response.data?.services ?? const [];
        emit(
          state.copyWith(
            fullServices: _fullServices,
            services: _filterServices(_fullServices, state.searchQuery),
            isServicesLoading: false,
            resetServicesError: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(servicesError: error, isServicesLoading: false));
      },
    );
  }

  Future<void> loadMoreServices() async {}
  Future<void> selectCategoryTab(int index) async {}
  Future<void> retryTabLoad(int index) async {}
  Future<void> addToCart(int serviceId, {int? categoryId}) async {
    if (isClosed || state.pendingCartActionIds.contains(serviceId)) return;

    final resolvedCategoryId =
        categoryId ??
        _fullServices
            .where((service) => service.id == serviceId)
            .firstOrNull
            ?.categoryId;

    if (resolvedCategoryId == null) {
      emit(state.copyWith(servicesError: 'Unable to add this service.'));
      return;
    }

    emit(
      state.copyWith(
        pendingCartActionIds: {...state.pendingCartActionIds, serviceId},
        resetServicesError: true,
      ),
    );

    final result = await _cartRepository.addToCart(
      serviceId: serviceId,
      categoryId: resolvedCategoryId,
      providerId: providerId,
      cardNumber: null,
      price: null,
    );

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingCartActionIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        _setServiceSelected(
          serviceId: serviceId,
          isSelected: true,
          pendingCartActionIds: pending,
        );
      },
      failure: (message) {
        final alreadyInCart =
            message.contains('ServiceAlreadyInCart') ||
            message.toLowerCase().contains('already');
        if (alreadyInCart) {
          _setServiceSelected(
            serviceId: serviceId,
            isSelected: true,
            pendingCartActionIds: pending,
          );
          return;
        }

        emit(
          state.copyWith(pendingCartActionIds: pending, servicesError: message),
        );
      },
    );
  }

  Future<void> removeFromCart(int serviceId) async {
    if (isClosed || state.pendingCartActionIds.contains(serviceId)) return;

    emit(
      state.copyWith(
        pendingCartActionIds: {...state.pendingCartActionIds, serviceId},
        resetServicesError: true,
      ),
    );

    final result = await _cartRepository.removeFromCart(serviceId);

    if (isClosed) return;
    final pending = Set<int>.from(state.pendingCartActionIds)
      ..remove(serviceId);

    result.when(
      success: (_) {
        _setServiceSelected(
          serviceId: serviceId,
          isSelected: false,
          pendingCartActionIds: pending,
        );
      },
      failure: (message) {
        emit(
          state.copyWith(pendingCartActionIds: pending, servicesError: message),
        );
      },
    );
  }

  Future<void> togglePackageDetails(int packageId) async {}

  Future<ApiResult<String>> createInvoiceFromPackage({
    required int packageId,
    required int providerBranchId,
    bool isCash = true,
    String? cardNumber,
  }) async {
    if (isClosed) {
      return const ApiResult.failure('Screen is no longer available.');
    }

    emit(
      state.copyWith(
        pendingPackageInvoiceIds: {
          ...state.pendingPackageInvoiceIds,
          packageId,
        },
      ),
    );

    final result = await _invoiceRepository.createFromPackage(
      packageId: packageId,
      providerBranchId: providerBranchId,
      isCash: isCash,
      cardNumber: cardNumber,
    );

    if (!isClosed) {
      final updatedPending = Set<int>.from(state.pendingPackageInvoiceIds)
        ..remove(packageId);
      emit(state.copyWith(pendingPackageInvoiceIds: updatedPending));
    }

    return result;
  }

  void updateSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      final nextQuery = query.isEmpty ? null : query;
      emit(
        state.copyWith(
          searchQuery: nextQuery,
          resetSearchQuery: query.isEmpty,
          services: _filterServices(_fullServices, nextQuery),
          packages: _filterPackages(_fullPackages, nextQuery),
          reviews: _filterReviews(_fullReviews, nextQuery),
        ),
      );
    });
  }

  Future<void> switchView(ProviderViewType view) async {
    if (isClosed) return;
    emit(state.copyWith(currentView: view));
    if (view == ProviderViewType.packages && state.packages.isEmpty) {
      await loadPackages(reset: true);
    } else if (view == ProviderViewType.reviews && state.reviews.isEmpty) {
      await loadReviews(reset: true);
    }
  }

  List<ProviderService> _filterServices(
    List<ProviderService> services,
    String? query,
  ) {
    if (query == null || query.isEmpty) return List.from(services);
    final q = query.toLowerCase();
    return services
        .where(
          (service) => service.serviceName?.toLowerCase().contains(q) ?? false,
        )
        .toList();
  }

  void _setServiceSelected({
    required int serviceId,
    required bool isSelected,
    required Set<int> pendingCartActionIds,
  }) {
    _fullServices = _fullServices
        .map(
          (service) => service.id == serviceId
              ? service.copyWith(isSelected: isSelected)
              : service,
        )
        .toList();

    emit(
      state.copyWith(
        fullServices: _fullServices,
        services: _filterServices(_fullServices, state.searchQuery),
        pendingCartActionIds: pendingCartActionIds,
        resetServicesError: true,
      ),
    );
  }

  List<ProviderPackage> _filterPackages(
    List<ProviderPackage> packages,
    String? query,
  ) {
    if (query == null || query.isEmpty) return List.from(packages);
    final q = query.toLowerCase();
    return packages
        .where((package) => package.name?.toLowerCase().contains(q) ?? false)
        .toList();
  }

  List<ProviderReview> _filterReviews(
    List<ProviderReview> reviews,
    String? query,
  ) {
    if (query == null || query.isEmpty) return List.from(reviews);
    final q = query.toLowerCase();
    return reviews
        .where(
          (review) =>
              (review.userName?.toLowerCase().contains(q) ?? false) ||
              (review.ratingText?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
