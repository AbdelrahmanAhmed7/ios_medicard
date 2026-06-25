import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/api_result.dart';
import '../../core/services/app_language_manager.dart';
import '../../network/data/provider_services_response_model.dart';
import '../repository/medicard_network_repository.dart';
import 'provider_page_state.dart';

class ProviderPageCubit extends Cubit<ProviderPageState> {
  final MedicardNetworkRepository _repository;
  final int providerId;

  ProviderPageCubit(this._repository, this.providerId)
      : super(const ProviderPageState.initial());

  static const int _pageSize = 20;
  int _currentPage = 1;
  String? _searchQuery;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<ProviderService> _services = [];
  Timer? _debounceTimer;

  Future<void> init() async {
    await Future.wait([loadProviderPage(), loadServices()]);
  }

  Future<void> loadProviderPage() async {
    emit(const ProviderPageState.providerLoading());
    final lang = AppLanguageManager.instance.currentLanguage;
    final result = await _repository.getProviderPage(
      lang: lang,
      providerId: providerId,
    );
    result.when(
      success: (response) {
        if (response.data != null) {
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
      _currentPage = 1;
      _services = [];
      _hasMore = true;
    }
    if (_isLoadingMore || !_hasMore) return;

    if (_currentPage == 1) {
      emit(const ProviderPageState.servicesLoading());
    } else {
      _isLoadingMore = true;
      emit(ProviderPageState.servicesSuccess(
        services: _services,
        hasMore: _hasMore,
        isLoadingMore: _isLoadingMore,
      ));
    }

    final lang = AppLanguageManager.instance.currentLanguage;
    final result = await _repository.getProviderServices(
      lang: lang,
      providerId: providerId,
      search: _searchQuery,
      pageNumber: _currentPage,
      pageSize: _pageSize,
    );

    result.when(
      success: (response) {
        if (response.data?.services != null) {
          _services.addAll(response.data!.services!);
          _hasMore = response.data?.pagination?.hasNextPage ??
              response.data!.services!.length >= _pageSize;
          _currentPage++;
        }
        _isLoadingMore = false;
        emit(ProviderPageState.servicesSuccess(
          services: _services,
          hasMore: _hasMore,
          isLoadingMore: _isLoadingMore,
        ));
      },
      failure: (error) {
        _isLoadingMore = false;
        emit(ProviderPageState.servicesFailed(error));
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

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
