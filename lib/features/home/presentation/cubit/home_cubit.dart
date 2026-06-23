import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';
import '../../../../core/services/location_repository.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase _getHomeDataUseCase;
  final LocationRepository _locationRepository;

  HomeCubit(this._getHomeDataUseCase, this._locationRepository)
    : super(const HomeState.initial());

  Future<void> getHomeData() async {
    emit(const HomeState.loading());

    try {
      final location = _locationRepository.cached;
      final result = await _getHomeDataUseCase.call(
        latitude: location?.latitude,
        longitude: location?.longitude,
      );

      result.when(
        success: (data) => emit(HomeState.success(data)),
        failure: (message) => emit(HomeState.failed(message)),
      );
    } catch (e) {
      emit(HomeState.failed(e.toString()));
    }
  }
}
