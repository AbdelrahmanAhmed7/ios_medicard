part of 'localization_cubit.dart';

@freezed
class LocalizationState with _$LocalizationState {
  const factory LocalizationState.initial(String language) = _Initial;
  const factory LocalizationState.loading() = _Loading;
  const factory LocalizationState.loaded(String language) = _Loaded;
  const factory LocalizationState.error(String message) = _Error;
}
