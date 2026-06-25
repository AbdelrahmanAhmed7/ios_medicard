import 'dart:async';
import 'package:flutter/widgets.dart';
import '../constants/constants.dart';
import '../helpers/shared_pref_helper.dart';

class AppLanguageManager {
  String? _currentLanguage;
  bool _isInitialized = false;

  final Completer<void> _initializationCompleter = Completer<void>();
  Future<void> get initializationFuture => _initializationCompleter.future;

  final StreamController<String> _languageStreamController = StreamController<String>.broadcast();
  Stream<String> get languageStream => _languageStreamController.stream;

  AppLanguageManager._();
  static final AppLanguageManager instance = AppLanguageManager._();

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🚀 AppLanguageManager already initialized');
      return;
    }

    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    debugPrint('🚀 Device locale: ${deviceLocale.languageCode}');

    final savedLanguage = await SharedPrefHelper.getString(SharedPrefKeys.appLanguage);
    debugPrint('🚀 Saved language: ${savedLanguage.isEmpty ? 'none' : savedLanguage}');

    if (savedLanguage.isNotEmpty) {
      _currentLanguage = savedLanguage;
    } else {
      _currentLanguage = deviceLocale.languageCode == 'ar' ? 'ar' : 'en';
    }

    debugPrint('🚀 Current language: $_currentLanguage');

    _isInitialized = true;
    _initializationCompleter.complete();
    _languageStreamController.add(_currentLanguage!);
  }

  String get currentLanguage {
    if (!_isInitialized) {
      throw StateError('AppLanguageManager not initialized. Call initialize() first.');
    }
    return _currentLanguage!;
  }

  bool get isInitialized => _isInitialized;

  Future<void> setLanguage(String language) async {
    debugPrint('🚀 AppLanguageManager.setLanguage called with: $language');
    if (!_isInitialized) {
      throw StateError('AppLanguageManager not initialized. Call initialize() first.');
    }
    if (language == _currentLanguage) {
      debugPrint('🚀 Language is the same, skipping');
      return;
    }
    _currentLanguage = language;
    await SharedPrefHelper.setData(SharedPrefKeys.appLanguage, language);
    debugPrint('🚀 Language saved to SharedPref');
    _languageStreamController.add(language);
    debugPrint('🚀 Language added to stream');
  }

  void dispose() {
    _languageStreamController.close();
  }
}
