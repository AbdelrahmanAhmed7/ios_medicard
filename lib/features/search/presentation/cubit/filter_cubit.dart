import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/api_result.dart';

import '../../domain/use_cases/get_cities_use_case.dart';
import '../../domain/use_cases/get_governorates_use_case.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  final GetGovernoratesUseCase _getGovernoratesUseCase;
  final GetCitiesUseCase _getCitiesUseCase;

  FilterCubit(this._getGovernoratesUseCase, this._getCitiesUseCase)
    : super(const FilterState());

  Future<void> loadGovernorates() async {
    if (isClosed) return;
    emit(state.copyWith(isLoadingGovernorates: true, clearError: true));
    final result = await _getGovernoratesUseCase.call();
    if (isClosed) return;
    result.when(
      success: (governorates) {
        if (isClosed) return;
        emit(
          state.copyWith(
            governorates: governorates,
            isLoadingGovernorates: false,
          ),
        );
      },
      failure: (message) {
        if (isClosed) return;
        emit(state.copyWith(isLoadingGovernorates: false, error: message));
      },
    );
  }

  Future<void> selectGovernorate(int? governorateId) async {
    if (isClosed) return;
    if (governorateId == null) {
      emit(state.copyWith(clearGovernorate: true, clearCity: true, cities: []));
      return;
    }
    emit(
      state.copyWith(
        selectedGovernorateId: governorateId,
        clearCity: true,
        cities: [],
        isLoadingCities: true,
      ),
    );
    final result = await _getCitiesUseCase.call(governorateId);
    if (isClosed) return;
    result.when(
      success: (cities) {
        if (isClosed) return;
        emit(state.copyWith(cities: cities, isLoadingCities: false));
      },
      failure: (message) {
        if (isClosed) return;
        emit(state.copyWith(isLoadingCities: false, error: message));
      },
    );
  }

  void selectCity(int? cityId) {
    if (isClosed) return;
    if (cityId == null) {
      emit(state.copyWith(clearCity: true));
    } else {
      emit(state.copyWith(selectedCityId: cityId));
    }
  }

  void selectSortBy(int? sortBy) {
    if (isClosed) return;
    if (sortBy == null) {
      emit(state.copyWith(clearSortBy: true));
    } else {
      // Toggle off if same value is tapped again
      if (state.selectedSortBy == sortBy) {
        emit(state.copyWith(clearSortBy: true));
      } else {
        emit(state.copyWith(selectedSortBy: sortBy));
      }
    }
  }

  void resetFilters() {
    if (isClosed) return;
    emit(
      state.copyWith(
        clearGovernorate: true,
        clearCity: true,
        clearSortBy: true,
        cities: [],
      ),
    );
  }
}
