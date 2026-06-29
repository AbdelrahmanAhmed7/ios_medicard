import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import '../../core/constants/api_result.dart';
import '../../network/data/provider_services_response_model.dart';
import '../repository/medicard_network_repository.dart';
import 'provider_page_state.dart';

enum ProviderViewType { services, packages }

class ProviderPageCubit extends Cubit<ProviderPageState> {
  final MedicardNetworkRepository _repository;
  final int providerId;

  ProviderPageCubit(this._repository, this.providerId)
      : super(const ProviderPageState.initial());

  static const int _pageSize = 20;

  // Services state
  int _servicesCurrentPage = 1;
  String? _searchQuery;
  bool _servicesHasMore = true;
  bool _servicesIsLoadingMore = false;
  List<ProviderService> _services = [];

  // Packages state
  int _packagesCurrentPage = 1;
  bool _packagesHasMore = true;
  bool _packagesIsLoadingMore = false;
  List<ProviderPackage> _packages = [];

  Timer? _debounceTimer;
  ProviderPageData? _providerData;
  ProviderViewType _currentView = ProviderViewType.services;

  ProviderPageData? get providerData => _providerData;
  ProviderViewType get currentView => _currentView;

  Future<void> init() async {
    await Future.wait([loadProviderPage(), loadServices()]);
  }

  Future<void> loadProviderPage() async {
    emit(const ProviderPageState.providerLoading());
    final result = await _repository.getProviderPage(
      providerId: providerId,
    );
    result.when(
      success: (response) {
        if (response.data != null) {
          _providerData = response.data!;
          emit(ProviderPageState.providerSuccess(response.data!));
        } else {
          emit(const ProviderPageState.providerFailed('No data'));
        }
      },
      failure: (error) => emit(ProviderPageState.providerFailed(error)),
    );
  }

  Future<void> loadServices({bool reset = false}) async {
    if (reset) {
      _servicesCurrentPage = 1;
      _services = [];
      _servicesHasMore = true;
    }
    if (_servicesIsLoadingMore || !_servicesHasMore) return;

    if (_servicesCurrentPage == 1) {
      emit(const ProviderPageState.servicesLoading());
    } else {
      _servicesIsLoadingMore = true;
      emit(ProviderPageState.servicesSuccess(
        services: _services,
        hasMore: _servicesHasMore,
        isLoadingMore: _servicesIsLoadingMore,
      ));
    }

    final result = await _repository.getProviderServices(
      providerId: providerId,
      search: _searchQuery,
      pageNumber: _servicesCurrentPage,
      pageSize: _pageSize,
    );

    result.when(
      success: (response) {
        print('loadServices success! data: ${response.data}');
        print('loadServices items: ${response.data?.items}');
        if (response.data?.items != null) {
          _services.addAll(response.data!.items!);
          _servicesHasMore = (_servicesCurrentPage < (response.data?.totalPages ?? 1));
          _servicesCurrentPage++;
        }
        _servicesIsLoadingMore = false;
        print('loadServices emitting _servicesSuccess with ${_services.length} services');
        emit(ProviderPageState.servicesSuccess(
          services: _services,
          hasMore: _servicesHasMore,
          isLoadingMore: _servicesIsLoadingMore,
        ));
      },
      failure: (error) {
        print('loadServices failed: $error');
        _servicesIsLoadingMore = false;
        emit(ProviderPageState.servicesFailed(error));
      },
    );
  }

  Future<void> loadPackages({bool reset = false}) async {
    if (reset) {
      _packagesCurrentPage = 1;
      _packages = [];
      _packagesHasMore = true;
    }
    if (_packagesIsLoadingMore || !_packagesHasMore) return;

    if (_packagesCurrentPage == 1) {
      emit(const ProviderPageState.packagesLoading());
    } else {
      _packagesIsLoadingMore = true;
      emit(ProviderPageState.packagesSuccess(
        packages: _packages,
        hasMore: _packagesHasMore,
        isLoadingMore: _packagesIsLoadingMore,
      ));
    }

    final result = await _repository.getProviderPackages(
      providerId: providerId,
      pageNumber: _packagesCurrentPage,
      pageSize: _pageSize,
    );

    result.when(
      success: (response) {
        if (response.data?.items != null) {
          _packages.addAll(response.data!.items!);
          _packagesHasMore = (_packagesCurrentPage < (response.data?.totalPages ?? 1));
          _packagesCurrentPage++;
        }
        _packagesIsLoadingMore = false;
        emit(ProviderPageState.packagesSuccess(
          packages: _packages,
          hasMore: _packagesHasMore,
          isLoadingMore: _packagesIsLoadingMore,
        ));
      },
      failure: (error) {
        _packagesIsLoadingMore = false;
        emit(ProviderPageState.packagesFailed(error));
      },
    );
  }

  void updateSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.isEmpty ? null : query;
      loadServices(reset: true);
    });
  }

  Future<void> loadMoreServices() async {
    await loadServices();
  }

  Future<void> loadMorePackages() async {
    await loadPackages();
  }

  Future<void> switchView(ProviderViewType view) async {
    _currentView = view;
    if (view == ProviderViewType.services) {
      if (_services.isNotEmpty) {
        emit(ProviderPageState.servicesSuccess(
          services: _services,
          hasMore: _servicesHasMore,
          isLoadingMore: _servicesIsLoadingMore,
        ));
      } else {
        await loadServices(reset: true);
      }
    } else {
      if (_packages.isNotEmpty) {
        emit(ProviderPageState.packagesSuccess(
          packages: _packages,
          hasMore: _packagesHasMore,
          isLoadingMore: _packagesIsLoadingMore,
        ));
      } else {
        await loadPackages(reset: true);
      }
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
