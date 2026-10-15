import 'package:medicard/features/search/data/models/lookup_model.dart';

class AddressFormState {
  final bool isLoadingGovernorates;
  final List<LookupModel> governorates;
  final bool isLoadingCities;
  final List<LookupModel> cities;
  final bool isSaving;
  final bool saved;
  final String? error;

  const AddressFormState({
    this.isLoadingGovernorates = false,
    this.governorates = const [],
    this.isLoadingCities = false,
    this.cities = const [],
    this.isSaving = false,
    this.saved = false,
    this.error,
  });

  AddressFormState copyWith({
    bool? isLoadingGovernorates,
    List<LookupModel>? governorates,
    bool? isLoadingCities,
    List<LookupModel>? cities,
    bool? isSaving,
    bool? saved,
    String? error,
    bool clearError = false,
  }) {
    return AddressFormState(
      isLoadingGovernorates:
          isLoadingGovernorates ?? this.isLoadingGovernorates,
      governorates: governorates ?? this.governorates,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      cities: cities ?? this.cities,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
