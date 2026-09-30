import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/app_language_manager.dart';
import 'app_refresh_cubit.dart';

part 'localization_state.dart';
part 'localization_cubit.freezed.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  final AppLanguageManager _languageManager;
  final AppRefreshCubit _appRefreshCubit;

  LocalizationCubit({
    required AppLanguageManager languageManager,
    required AppRefreshCubit appRefreshCubit,
  })  : _languageManager = languageManager,
        _appRefreshCubit = appRefreshCubit,
        super(LocalizationState.initial(languageManager.currentLanguage));

  Future<void> changeLanguage(BuildContext context, String language) async {
    debugPrint('🌍 LocalizationCubit.changeLanguage called with: $language');
    emit(const LocalizationState.loading());
    debugPrint('🌍 LocalizationState.loading emitted');
    try {
      await _languageManager.setLanguage(language);
      if (isClosed) return;
      if (context.mounted) {
        debugPrint('🌍 Calling context.setLocale(Locale($language))');
        await context.setLocale(Locale(language));
        debugPrint('🌍 context.setLocale completed');
      }
      if (isClosed) return;
      emit(LocalizationState.loaded(language));
      debugPrint('🌍 LocalizationState.loaded emitted');
      _appRefreshCubit.triggerLanguageRefresh();
      debugPrint('🌍 AppRefreshCubit.triggerLanguageRefresh called');
    } catch (e) {
      debugPrint('🌍 Error changing language: $e');
      if (isClosed) return;
      emit(LocalizationState.error(e.toString()));
    }
  }
}
