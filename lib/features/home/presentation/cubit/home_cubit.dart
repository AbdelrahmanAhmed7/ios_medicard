import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:medicard/core/constants/api_result.dart';
import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/home_response_model.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../domain/models/home_failure.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final LocationRepository _locationRepository;
  final LocationService _locationService;
  Future<void>? _homeLoad;
  HomeResponseModel? _homeData;
  HomeFailureType _lastFailure = HomeFailureType.unknown;

  HomeCubit(
    this._getHomeDataUseCase,
    this._locationRepository,
    this._locationService,
  ) : super(const HomeState.initial());

  Future<void> getHomeData({bool refresh = false}) {
    if (isClosed) return Future.value();
    final ongoing = _homeLoad;
    if (ongoing != null) {
      if (kDebugMode) debugPrint('[HomeCubit] joined in-flight Home load');
      return ongoing;
    }

    final load = _performHomeLoad(refresh: refresh);
    _homeLoad = load;
    return load.whenComplete(() {
      if (identical(_homeLoad, load)) _homeLoad = null;
    });
  }

  Future<void> _performHomeLoad({required bool refresh}) async {
    if (isClosed) return;
    final previousData = _homeData;
    final isRetry =
        previousData == null &&
        state.maybeWhen(failed: (_, _) => true, orElse: () => false);
    if (kDebugMode) {
      debugPrint(
        '[HomeCubit] Home request started (retry=$isRetry, refresh=$refresh)',
      );
    }
    if (previousData != null) {
      emit(HomeState.refreshing(previousData));
    } else if (isRetry) {
      emit(HomeState.failed(_lastFailure, isRetrying: true));
    } else {
      emit(const HomeState.loading());
    }

    try {
      final location = _locationRepository.cached;
      double? lat = location?.latitude;
      double? lng = location?.longitude;

      if (lat == null || lng == null) {
        if (kDebugMode) debugPrint('[HomeCubit] waiting for shared location');
        final result = await _locationRepository.resolve(_locationService);
        if (isClosed) return;
        if (result.hasCoordinates) {
          lat = result.latitude;
          lng = result.longitude;
        }
        if (kDebugMode) {
          debugPrint(
            '[HomeCubit] location resolved (available=${result.hasCoordinates})',
          );
        }
      }

      if (isClosed) return;
      if (kDebugMode) {
        debugPrint(
          '[HomeCubit] sending Home API request (hasLocation=${lat != null && lng != null})',
        );
      }
      final result = await _getHomeDataUseCase.call(
        latitude: lat,
        longitude: lng,
      );

      if (isClosed) return;

      result.when(
        success: (data) {
          if (isClosed) return;
          _homeData = data;
          if (kDebugMode) {
            debugPrint(
              '[HomeCubit] Home loaded successfully (afterRetry=$isRetry)',
            );
          }
          emit(HomeState.success(data));
        },
        failure: (message) {
          if (isClosed) return;
          final failure = homeFailureFromCode(message);
          _lastFailure = failure;
          if (kDebugMode) {
            debugPrint(
              '[HomeCubit] Home request failed (category=${failure.name})',
            );
          }
          if (previousData != null) {
            emit(HomeState.refreshFailed(previousData, failure));
          } else {
            emit(HomeState.failed(failure));
          }
        },
      );
    } catch (e) {
      if (isClosed) return;
      _lastFailure = HomeFailureType.unknown;
      if (kDebugMode) {
        debugPrint('[HomeCubit] Home request failed (category=unknown)');
      }
      if (previousData != null) {
        emit(HomeState.refreshFailed(previousData, _lastFailure));
      } else {
        emit(HomeState.failed(_lastFailure));
      }
    }
  }
}
