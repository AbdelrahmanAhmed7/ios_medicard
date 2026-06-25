import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/services/location_repository.dart';
import '../../domain/usecases/get_guest_home_data_usecase.dart';
import 'guest_home_state.dart';

class GuestHomeCubit extends Cubit<GuestHomeState> {
  final GetGuestHomeDataUseCase _getGuestHomeDataUseCase;
  final LocationRepository _locationRepository;

  GuestHomeCubit(this._getGuestHomeDataUseCase, this._locationRepository)
      : super(const GuestHomeState.initial());

  Future<void> getGuestHomeData() async {
    emit(const GuestHomeState.loading());

    try {
      final location = _locationRepository.cached;
      final result = await _getGuestHomeDataUseCase.call(
        latitude: location?.latitude,
        longitude: location?.longitude,
      );

      result.when(
        success: (data) => emit(GuestHomeState.success(data)),
        failure: (message) => emit(GuestHomeState.failed(message)),
      );
    } catch (e) {
      emit(GuestHomeState.failed(e.toString()));
    }
  }
}
