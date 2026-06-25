import 'package:freezed_annotation/freezed_annotation.dart';
import '../../network/data/provider_page_response_model.dart';
import '../../network/data/provider_services_response_model.dart';

part 'provider_page_state.freezed.dart';

@freezed
class ProviderPageState with _$ProviderPageState {
  const factory ProviderPageState.initial() = _Initial;
  const factory ProviderPageState.providerLoading() = _ProviderLoading;
  const factory ProviderPageState.providerSuccess(ProviderPageData data) = _ProviderSuccess;
  const factory ProviderPageState.providerFailed(String error) = _ProviderFailed;
  const factory ProviderPageState.servicesLoading() = _ServicesLoading;
  const factory ProviderPageState.servicesSuccess({
    required List<ProviderService> services,
    required bool hasMore,
    required bool isLoadingMore,
  }) = _ServicesSuccess;
  const factory ProviderPageState.servicesFailed(String error) = _ServicesFailed;
}
