part of 'app_refresh_cubit.dart';

@freezed
abstract class AppRefreshState with _$AppRefreshState {
  const factory AppRefreshState.initial() = _Initial;
  const factory AppRefreshState.languageChanged() = LanguageChanged;
  const factory AppRefreshState.sessionExpired() = SessionExpired;
}
