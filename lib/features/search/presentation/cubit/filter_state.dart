import '../../data/models/lookup_model.dart';

class FilterState {
  final List<LookupModel> governorates;
  final List<LookupModel> cities;
  final bool isLoadingGovernorates;
  final bool isLoadingCities;
  final int? selectedGovernorateId;
  final int? selectedCityId;
  final int? selectedSortBy;
  final String? error;

  const FilterState({
    this.governorates = const [],
    this.cities = const [],
    this.isLoadingGovernorates = false,
    this.isLoadingCities = false,
    this.selectedGovernorateId,
    this.selectedCityId,
    this.selectedSortBy,
    this.error,
  });

  FilterState copyWith({
    List<LookupModel>? governorates,
    List<LookupModel>? cities,
    bool? isLoadingGovernorates,
    bool? isLoadingCities,
    int? selectedGovernorateId,
    bool clearGovernorate = false,
    int? selectedCityId,
    bool clearCity = false,
    int? selectedSortBy,
    bool clearSortBy = false,
    String? error,
    bool clearError = false,
  }) {
    return FilterState(
      governorates: governorates ?? this.governorates,
      cities: cities ?? this.cities,
      isLoadingGovernorates:
          isLoadingGovernorates ?? this.isLoadingGovernorates,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      selectedGovernorateId: clearGovernorate
          ? null
          : (selectedGovernorateId ?? this.selectedGovernorateId),
      selectedCityId: clearCity
          ? null
          : (selectedCityId ?? this.selectedCityId),
      selectedSortBy: clearSortBy
          ? null
          : (selectedSortBy ?? this.selectedSortBy),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
