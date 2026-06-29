import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';
import '../../../../core/services/location_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';
import 'location_cubit.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final LocationRepository _locationRepository;
  final LocationService _locationService;
  final LocationCubit _locationCubit;

  HomeCubit(this._getHomeDataUseCase, this._locationRepository, this._locationService, this._locationCubit)
    : super(const HomeState.initial());

  Future<void> getHomeData() async {
    emit(const HomeState.loading());

    try {
      // Resolve location first if not cached
      final location = _locationRepository.cached;
      double? lat = location?.latitude;
      double? lng = location?.longitude;

      if (lat == null || lng == null) {
        final result = await _locationService.resolveLocation(
          requestIfNeeded: true,
        );
        if (result.hasCoordinates) {
          lat = result.latitude;
          lng = result.longitude;
          _locationRepository.cache(result);
        }
      }

      // Then fetch home data with coordinates
      final result = await _getHomeDataUseCase.call(
        latitude: lat,
        longitude: lng,
      );

      // After resolving location successfully, notify LocationCubit
      _locationCubit.loadLocation();

      result.when(
        success: (data) => emit(HomeState.success(data)),
        failure: (message) => emit(HomeState.failed(message)),
      );
    } catch (e) {
      emit(HomeState.failed(e.toString()));
    }
  }
}
