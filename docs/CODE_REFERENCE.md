# مرجع الكود الكامل

> هذا الملف مولّد آليًا من شجرة بناء Dart. لا تعدّله يدويًا؛ شغّل `dart run tool/generate_code_reference.dart` بعد تغيير الواجهات أو الدوال.

## طريقة قراءة المرجع

- يغطي كل ملفات Dart المكتوبة يدويًا داخل `lib/`، بما فيها الدوال الخاصة.
- يستبعد ملفات `*.g.dart` و`*.freezed.dart` لأنها ناتج توليد وليست مصدرًا يُعدّل يدويًا.
- اضغط على أي توقيع للانتقال إلى مكانه في المصدر. وسم **خاص** يعني أن الاسم يبدأ بـ `_`.
- الوصف المختصر يوضح غرض الدالة من اسمها وسياق ملفها؛ المصدر المرتبط هو المرجع النهائي للتفاصيل التنفيذية.

## الفهرس

- [Core: auth](#core-auth)
- [Core: cache](#core-cache)
- [Core: constants](#core-constants)
- [Core: cubit](#core-cubit)
- [Core: di](#core-di)
- [Core: helpers](#core-helpers)
- [Core: network](#core-network)
- [Core: routing](#core-routing)
- [Core: services](#core-services)
- [Core: theming](#core-theming)
- [Core: utils](#core-utils)
- [Core: widgets](#core-widgets)
- [Module: data](#module-data)
- [Module: domain](#module-domain)
- [Feature: activate_card](#feature-activatecard)
- [Feature: activity](#feature-activity)
- [Feature: auth](#feature-auth)
- [Feature: cart](#feature-cart)
- [Feature: content](#feature-content)
- [Feature: ecard](#feature-ecard)
- [Feature: family_members](#feature-familymembers)
- [Feature: guest_home](#feature-guesthome)
- [Feature: help_center](#feature-helpcenter)
- [Feature: home](#feature-home)
- [Feature: notifications](#feature-notifications)
- [Feature: packages](#feature-packages)
- [Feature: profile](#feature-profile)
- [Feature: search](#feature-search)
- [Module: firebase_options.dart](#module-firebaseoptionsdart)
- [Module: main.dart](#module-maindart)
- [Module: medicard_network](#module-medicardnetwork)
- [Module: network](#module-network)
- [Module: presentation](#module-presentation)
- [Module: repository](#module-repository)
- [Module: service](#module-service)

## Core: auth

### `core/auth/auth_refresh_service.dart`

- [`class AuthRefreshService`](../lib/core/auth/auth_refresh_service.dart#L9) — الكلاس الذي يجمع مسؤوليات `auth refresh service`.
- [`AuthRefreshService({required AuthSessionStorage sessionStorage, required Dio refreshDio})`](../lib/core/auth/auth_refresh_service.dart#L14) — ينشئ كائنًا من `AuthRefreshService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<AuthSession?> refreshToken()`](../lib/core/auth/auth_refresh_service.dart#L24) — يعيد تحميل أو محاولة `refresh token` داخل `AuthRefreshService`.
- [`Future<AuthSession?> _performRefresh()`](../lib/core/auth/auth_refresh_service.dart#L33) — **خاص** — ينفّذ منطق `perform refresh` داخل `AuthRefreshService`.

### `core/auth/auth_session.dart`

- [`class AuthSession`](../lib/core/auth/auth_session.dart#L1) — الكلاس الذي يجمع مسؤوليات `auth session`.
- [`const AuthSession({required this.accessToken, required this.refreshToken, this.accessTokenExpiresAt, this.refreshTokenExpiresAt})`](../lib/core/auth/auth_session.dart#L11) — ينشئ كائنًا من `AuthSession` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get hasAccessToken`](../lib/core/auth/auth_session.dart#L20) — يفحص شرط `has access token` ويعيد النتيجة داخل `AuthSession`.
- [`bool get hasRefreshToken`](../lib/core/auth/auth_session.dart#L21) — يفحص شرط `has refresh token` ويعيد النتيجة داخل `AuthSession`.
- [`bool get isRefreshTokenExpired`](../lib/core/auth/auth_session.dart#L23) — يفحص شرط `is refresh token expired` ويعيد النتيجة داخل `AuthSession`.
- [`bool get isAccessTokenExpiredOrAboutToExpire`](../lib/core/auth/auth_session.dart#L34) — يفحص شرط `is access token expired or about to expire` ويعيد النتيجة داخل `AuthSession`.
- [`AuthSession copyWith({String? accessToken, String? refreshToken, DateTime? accessTokenExpiresAt, DateTime? refreshTokenExpiresAt})`](../lib/core/auth/auth_session.dart#L45) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `core/auth/auth_session_storage.dart`

- [`class AuthSessionStorage`](../lib/core/auth/auth_session_storage.dart#L7) — الكلاس الذي يجمع مسؤوليات `auth session storage`.
- [`const AuthSessionStorage()`](../lib/core/auth/auth_session_storage.dart#L14) — ينشئ كائنًا من `AuthSessionStorage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> saveSession(AuthSession session)`](../lib/core/auth/auth_session_storage.dart#L18) — ينفّذ منطق `save session` داخل `AuthSessionStorage`.
- [`Future<void> updateTokens({required String accessToken, required String refreshToken, required DateTime? accessTokenExpiresAt, required DateTime? refreshTokenExpiresAt})`](../lib/core/auth/auth_session_storage.dart#L44) — يحدّث `update tokens` داخل `AuthSessionStorage`.
- [`Future<AuthSession?> getSession()`](../lib/core/auth/auth_session_storage.dart#L62) — يجلب `get session` من مصدر البيانات المناسب داخل `AuthSessionStorage`.
- [`Future<String?> getAccessToken()`](../lib/core/auth/auth_session_storage.dart#L143) — يجلب `get access token` من مصدر البيانات المناسب داخل `AuthSessionStorage`.
- [`Future<String?> getRefreshToken()`](../lib/core/auth/auth_session_storage.dart#L156) — يجلب `get refresh token` من مصدر البيانات المناسب داخل `AuthSessionStorage`.
- [`Future<void> clearSession()`](../lib/core/auth/auth_session_storage.dart#L165) — يحذف أو يمسح `clear session` داخل `AuthSessionStorage`.

### `core/auth/jwt_helper.dart`

- [`DateTime? getJwtExpiryDate(String token)`](../lib/core/auth/jwt_helper.dart#L3) — يجلب `get jwt expiry date` من مصدر البيانات المناسب داخل هذا الملف.

### `core/auth/refresh_token_dto.dart`

- [`class RefreshTokenRequestDto`](../lib/core/auth/refresh_token_dto.dart#L1) — الكلاس الذي يجمع مسؤوليات `refresh token request dto`.
- [`const RefreshTokenRequestDto({required this.refreshToken})`](../lib/core/auth/refresh_token_dto.dart#L5) — ينشئ كائنًا من `RefreshTokenRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/core/auth/refresh_token_dto.dart#L7) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class RefreshTokenResponseDto`](../lib/core/auth/refresh_token_dto.dart#L10) — الكلاس الذي يجمع مسؤوليات `refresh token response dto`.
- [`const RefreshTokenResponseDto({this.token, this.refreshToken, this.refreshTokenExpiresAt, this.expiresAt})`](../lib/core/auth/refresh_token_dto.dart#L28) — ينشئ كائنًا من `RefreshTokenResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json)`](../lib/core/auth/refresh_token_dto.dart#L35) — ينشئ كائنًا من `RefreshTokenResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static DateTime? _parseDate(dynamic value)`](../lib/core/auth/refresh_token_dto.dart#L44) — **خاص** — يحلّل `parse date` ويحوّله لصيغة قابلة للاستخدام داخل `RefreshTokenResponseDto`.
- [`class RefreshTokenEnvelopeDto`](../lib/core/auth/refresh_token_dto.dart#L50) — الكلاس الذي يجمع مسؤوليات `refresh token envelope dto`.
- [`const RefreshTokenEnvelopeDto({this.httpStatusCode, this.succeeded, this.message, this.data})`](../lib/core/auth/refresh_token_dto.dart#L66) — ينشئ كائنًا من `RefreshTokenEnvelopeDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory RefreshTokenEnvelopeDto.fromJson(Map<String, dynamic> json)`](../lib/core/auth/refresh_token_dto.dart#L73) — ينشئ كائنًا من `RefreshTokenEnvelopeDto` ويهيّئ الاعتماديات والقيم المطلوبة.


## Core: cache

### `core/cache/cache_service.dart`

- [`class CacheService`](../lib/core/cache/cache_service.dart#L3) — الكلاس الذي يجمع مسؤوليات `cache service`.
- [`static Future<void> cacheSupportContactsData(dynamic data)`](../lib/core/cache/cache_service.dart#L5) — ينفّذ منطق `cache support contacts data` داخل `CacheService`.
- [`static Future<dynamic> getCachedSupportContactsData()`](../lib/core/cache/cache_service.dart#L10) — يجلب `get cached support contacts data` من مصدر البيانات المناسب داخل `CacheService`.
- [`static Future<void> clearSupportContactsCache()`](../lib/core/cache/cache_service.dart#L15) — يحذف أو يمسح `clear support contacts cache` داخل `CacheService`.

### `core/cache/network_cache_service.dart`

- [`class NetworkCacheService`](../lib/core/cache/network_cache_service.dart#L4) — الكلاس الذي يجمع مسؤوليات `network cache service`.
- [`static Future<void> cacheSupportContactsData(dynamic data)`](../lib/core/cache/network_cache_service.dart#L12) — ينفّذ منطق `cache support contacts data` داخل `NetworkCacheService`.
- [`static Future<dynamic> getCachedSupportContactsData()`](../lib/core/cache/network_cache_service.dart#L22) — يجلب `get cached support contacts data` من مصدر البيانات المناسب داخل `NetworkCacheService`.
- [`static Future<void> clearSupportContactsCache()`](../lib/core/cache/network_cache_service.dart#L48) — يحذف أو يمسح `clear support contacts cache` داخل `NetworkCacheService`.


## Core: constants

### `core/constants/api_result.dart`

- [`class ApiResult`](../lib/core/constants/api_result.dart#L5) — الكلاس الذي يجمع مسؤوليات `api result`.
- [`const factory ApiResult.success(T data)`](../lib/core/constants/api_result.dart#L7) — ينشئ كائنًا من `ApiResult` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ApiResult.failure(String message)`](../lib/core/constants/api_result.dart#L8) — ينشئ كائنًا من `ApiResult` ويهيّئ الاعتماديات والقيم المطلوبة.

### `core/constants/app_assets.dart`

- [`class AppAssets`](../lib/core/constants/app_assets.dart#L1) — الكلاس الذي يجمع مسؤوليات `app assets`.

### `core/constants/constants.dart`

- [`class SharedPrefKeys`](../lib/core/constants/constants.dart#L6) — الكلاس الذي يجمع مسؤوليات `shared pref keys`.


## Core: cubit

### `core/cubit/app_refresh_cubit.dart`

- [`class AppRefreshCubit`](../lib/core/cubit/app_refresh_cubit.dart#L8) — الكلاس الذي يجمع مسؤوليات `app refresh cubit`.
- [`AppRefreshCubit()`](../lib/core/cubit/app_refresh_cubit.dart#L9) — ينشئ كائنًا من `AppRefreshCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void triggerLanguageRefresh()`](../lib/core/cubit/app_refresh_cubit.dart#L15) — ينفّذ منطق `trigger language refresh` داخل `AppRefreshCubit`.
- [`void triggerSessionExpired()`](../lib/core/cubit/app_refresh_cubit.dart#L22) — ينفّذ منطق `trigger session expired` داخل `AppRefreshCubit`.
- [`void triggerProfileSummaryRefresh()`](../lib/core/cubit/app_refresh_cubit.dart#L37) — ينفّذ منطق `trigger profile summary refresh` داخل `AppRefreshCubit`.
- [`void triggerInvoicesRefresh()`](../lib/core/cubit/app_refresh_cubit.dart#L47) — ينفّذ منطق `trigger invoices refresh` داخل `AppRefreshCubit`.

### `core/cubit/app_refresh_state.dart`

- [`class AppRefreshState`](../lib/core/cubit/app_refresh_state.dart#L3) — الكلاس الذي يجمع مسؤوليات `app refresh state`.
- [`const factory AppRefreshState.initial()`](../lib/core/cubit/app_refresh_state.dart#L5) — ينشئ كائنًا من `AppRefreshState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory AppRefreshState.languageChanged()`](../lib/core/cubit/app_refresh_state.dart#L6) — ينشئ كائنًا من `AppRefreshState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory AppRefreshState.sessionExpired()`](../lib/core/cubit/app_refresh_state.dart#L7) — ينشئ كائنًا من `AppRefreshState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `core/cubit/localization_cubit.dart`

- [`class LocalizationCubit`](../lib/core/cubit/localization_cubit.dart#L11) — الكلاس الذي يجمع مسؤوليات `localization cubit`.
- [`LocalizationCubit({required AppLanguageManager languageManager, required AppRefreshCubit appRefreshCubit})`](../lib/core/cubit/localization_cubit.dart#L15) — ينشئ كائنًا من `LocalizationCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> changeLanguage(BuildContext context, String language)`](../lib/core/cubit/localization_cubit.dart#L22) — يحدّث `change language` داخل `LocalizationCubit`.

### `core/cubit/localization_state.dart`

- [`class LocalizationState`](../lib/core/cubit/localization_state.dart#L3) — الكلاس الذي يجمع مسؤوليات `localization state`.
- [`const factory LocalizationState.initial(String language)`](../lib/core/cubit/localization_state.dart#L5) — ينشئ كائنًا من `LocalizationState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory LocalizationState.loading()`](../lib/core/cubit/localization_state.dart#L6) — ينشئ كائنًا من `LocalizationState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory LocalizationState.loaded(String language)`](../lib/core/cubit/localization_state.dart#L7) — ينشئ كائنًا من `LocalizationState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory LocalizationState.error(String message)`](../lib/core/cubit/localization_state.dart#L8) — ينشئ كائنًا من `LocalizationState` ويهيّئ الاعتماديات والقيم المطلوبة.


## Core: di

### `core/di/service_locator.dart`

- [`Future<void> setupServiceLocator()`](../lib/core/di/service_locator.dart#L94) — يحدّث `setup service locator` داخل هذا الملف.


## Core: helpers

### `core/helpers/shared_pref_helper.dart`

- [`class SharedPrefHelper`](../lib/core/helpers/shared_pref_helper.dart#L6) — الكلاس الذي يجمع مسؤوليات `shared pref helper`.
- [`SharedPrefHelper._()`](../lib/core/helpers/shared_pref_helper.dart#L7) — ينشئ كائنًا من `SharedPrefHelper` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static Future<SharedPreferences> _getPrefs()`](../lib/core/helpers/shared_pref_helper.dart#L12) — **خاص** — يجلب `get prefs` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<void> setData(String key, dynamic value)`](../lib/core/helpers/shared_pref_helper.dart#L16) — يحدّث `set data` داخل `SharedPrefHelper`.
- [`static Future<String> getString(String key)`](../lib/core/helpers/shared_pref_helper.dart#L38) — يجلب `get string` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<bool> getBool(String key)`](../lib/core/helpers/shared_pref_helper.dart#L44) — يجلب `get bool` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<int> getInt(String key)`](../lib/core/helpers/shared_pref_helper.dart#L50) — يجلب `get int` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<double> getDouble(String key)`](../lib/core/helpers/shared_pref_helper.dart#L56) — يجلب `get double` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<void> removeData(String key)`](../lib/core/helpers/shared_pref_helper.dart#L62) — يحذف أو يمسح `remove data` داخل `SharedPrefHelper`.
- [`static Future<void> clearAllData()`](../lib/core/helpers/shared_pref_helper.dart#L67) — يحذف أو يمسح `clear all data` داخل `SharedPrefHelper`.
- [`static Future<void> setSecuredString(String key, String value)`](../lib/core/helpers/shared_pref_helper.dart#L79) — يحدّث `set secured string` داخل `SharedPrefHelper`.
- [`static Future<String> getSecuredString(String key)`](../lib/core/helpers/shared_pref_helper.dart#L98) — يجلب `get secured string` من مصدر البيانات المناسب داخل `SharedPrefHelper`.
- [`static Future<void> clearAllSecuredData()`](../lib/core/helpers/shared_pref_helper.dart#L119) — يحذف أو يمسح `clear all secured data` داخل `SharedPrefHelper`.
- [`static Future<void> removeSecuredData(String key)`](../lib/core/helpers/shared_pref_helper.dart#L132) — يحذف أو يمسح `remove secured data` داخل `SharedPrefHelper`.


## Core: network

### `core/network/api_error_handler.dart`

- [`class ErrorHandler`](../lib/core/network/api_error_handler.dart#L6) — الكلاس الذي يجمع مسؤوليات `error handler`.
- [`static String handle(dynamic error, [BuildContext? context])`](../lib/core/network/api_error_handler.dart#L7) — يعالج حدث `handle` داخل `ErrorHandler`.

### `core/network/app_failure.dart`

- [`enum AppFailureType`](../lib/core/network/app_failure.dart#L1) — يعرّف القيم الثابتة الخاصة بـ `app failure type`.
- [`class AppFailure`](../lib/core/network/app_failure.dart#L14) — الكلاس الذي يجمع مسؤوليات `app failure`.
- [`const AppFailure(this.type, {this.message, this.statusCode})`](../lib/core/network/app_failure.dart#L19) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.network()`](../lib/core/network/app_failure.dart#L21) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.timeout()`](../lib/core/network/app_failure.dart#L22) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.connectionTimeout()`](../lib/core/network/app_failure.dart#L23) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.transferTimeout()`](../lib/core/network/app_failure.dart#L24) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.unauthorized()`](../lib/core/network/app_failure.dart#L25) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.forbidden()`](../lib/core/network/app_failure.dart#L26) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.notFound()`](../lib/core/network/app_failure.dart#L27) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.server({int? statusCode})`](../lib/core/network/app_failure.dart#L28) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.cancelled()`](../lib/core/network/app_failure.dart#L30) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const AppFailure.unexpected([String? message])`](../lib/core/network/app_failure.dart#L31) — ينشئ كائنًا من `AppFailure` ويهيّئ الاعتماديات والقيم المطلوبة.

### `core/network/auth_interceptor.dart`

- [`bool _isPublicPath(String path)`](../lib/core/network/auth_interceptor.dart#L21) — **خاص** — يفحص شرط `is public path` ويعيد النتيجة داخل هذا الملف.
- [`class AuthInterceptor`](../lib/core/network/auth_interceptor.dart#L28) — الكلاس الذي يجمع مسؤوليات `auth interceptor`.
- [`AuthInterceptor({required AuthSessionStorage sessionStorage, required AuthRefreshService refreshService, required this.onSessionExpired})`](../lib/core/network/auth_interceptor.dart#L42) — ينشئ كائنًا من `AuthInterceptor` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler)`](../lib/core/network/auth_interceptor.dart#L51) — يعالج حدث `on request` داخل `AuthInterceptor`.
- [`void onResponse(Response response, ResponseInterceptorHandler handler)`](../lib/core/network/auth_interceptor.dart#L117) — يعالج حدث `on response` داخل `AuthInterceptor`.
- [`Future<void> onError(DioException err, ErrorInterceptorHandler handler)`](../lib/core/network/auth_interceptor.dart#L129) — يعالج حدث `on error` داخل `AuthInterceptor`.

### `core/network/connectivity_service.dart`

- [`class ConnectivityService`](../lib/core/network/connectivity_service.dart#L4) — الكلاس الذي يجمع مسؤوليات `connectivity service`.
- [`ConnectivityService._()`](../lib/core/network/connectivity_service.dart#L6) — ينشئ كائنًا من `ConnectivityService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get isOnline`](../lib/core/network/connectivity_service.dart#L16) — يفحص شرط `is online` ويعيد النتيجة داخل `ConnectivityService`.
- [`Stream<bool> get connectivityStream`](../lib/core/network/connectivity_service.dart#L18) — ينفّذ منطق `connectivity stream` داخل `ConnectivityService`.
- [`Future<void> initialize()`](../lib/core/network/connectivity_service.dart#L24) — ينفّذ منطق `initialize` داخل `ConnectivityService`.
- [`Future<bool> checkConnectivity()`](../lib/core/network/connectivity_service.dart#L37) — ينفّذ منطق `check connectivity` داخل `ConnectivityService`.
- [`bool _updateConnectivityStatus(List<ConnectivityResult> results)`](../lib/core/network/connectivity_service.dart#L50) — **خاص** — يحدّث `update connectivity status` داخل `ConnectivityService`.
- [`void dispose()`](../lib/core/network/connectivity_service.dart#L67) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.

### `core/network/dio_factory.dart`

- [`class DioFactory`](../lib/core/network/dio_factory.dart#L12) — الكلاس الذي يجمع مسؤوليات `dio factory`.
- [`DioFactory._()`](../lib/core/network/dio_factory.dart#L13) — ينشئ كائنًا من `DioFactory` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static Interceptor get _acceptLanguageInterceptor`](../lib/core/network/dio_factory.dart#L19) — **خاص** — ينفّذ منطق `accept language interceptor` داخل `DioFactory`.
- [`static Interceptor get _logger`](../lib/core/network/dio_factory.dart#L32) — **خاص** — ينفّذ منطق `logger` داخل `DioFactory`.
- [`static Future<Dio> getDio()`](../lib/core/network/dio_factory.dart#L52) — يجلب `get dio` من مصدر البيانات المناسب داخل `DioFactory`.
- [`static Dio createRefreshDio()`](../lib/core/network/dio_factory.dart#L73) — ينشئ أو يضيف `create refresh dio` داخل `DioFactory`.
- [`static Future<Dio> getDioForMedicard()`](../lib/core/network/dio_factory.dart#L92) — يجلب `get dio for medicard` من مصدر البيانات المناسب داخل `DioFactory`.
- [`static Future<Dio> getDioForLogin()`](../lib/core/network/dio_factory.dart#L108) — يجلب `get dio for login` من مصدر البيانات المناسب داخل `DioFactory`.
- [`static void setTokenIntoHeaderAfterLogin(String token)`](../lib/core/network/dio_factory.dart#L124) — يحدّث `set token into header after login` داخل `DioFactory`.
- [`static void clearTokenFromHeader()`](../lib/core/network/dio_factory.dart#L130) — يحذف أو يمسح `clear token from header` داخل `DioFactory`.
- [`static Future<void> setAcceptLanguage(String language)`](../lib/core/network/dio_factory.dart#L135) — يحدّث `set accept language` داخل `DioFactory`.
- [`static void _addCommonInterceptors(Dio dio)`](../lib/core/network/dio_factory.dart#L141) — **خاص** — ينشئ أو يضيف `add common interceptors` داخل `DioFactory`.

### `core/network/error_mapper.dart`

- [`AppFailure mapDioException(DioException exception)`](../lib/core/network/error_mapper.dart#L5) — يحوّل `map dio exception` بين طبقات أو صيغ البيانات داخل هذا الملف.

### `core/network/error_mapping_interceptor.dart`

- [`class ErrorMappingInterceptor`](../lib/core/network/error_mapping_interceptor.dart#L6) — الكلاس الذي يجمع مسؤوليات `error mapping interceptor`.
- [`void onError(DioException err, ErrorInterceptorHandler handler)`](../lib/core/network/error_mapping_interceptor.dart#L8) — يعالج حدث `on error` داخل `ErrorMappingInterceptor`.

### `core/network/retry_inceptor.dart`

- [`class RetryInterceptor`](../lib/core/network/retry_inceptor.dart#L9) — الكلاس الذي يجمع مسؤوليات `retry interceptor`.
- [`RetryInterceptor({this.maxRetries = 3, this.baseDelay = const Duration(seconds: 2)})`](../lib/core/network/retry_inceptor.dart#L14) — ينشئ كائنًا من `RetryInterceptor` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void onError(DioException err, ErrorInterceptorHandler handler)`](../lib/core/network/retry_inceptor.dart#L19) — يعالج حدث `on error` داخل `RetryInterceptor`.
- [`bool _shouldRetry(DioException err)`](../lib/core/network/retry_inceptor.dart#L80) — **خاص** — يفحص شرط `should retry` ويعيد النتيجة داخل `RetryInterceptor`.
- [`bool _isIdempotent(String method)`](../lib/core/network/retry_inceptor.dart#L100) — **خاص** — يفحص شرط `is idempotent` ويعيد النتيجة داخل `RetryInterceptor`.
- [`Future<Dio> _getDioInstance()`](../lib/core/network/retry_inceptor.dart#L105) — **خاص** — يجلب `get dio instance` من مصدر البيانات المناسب داخل `RetryInterceptor`.


## Core: routing

### `core/routing/app_router.dart`

- [`class AppRouter`](../lib/core/routing/app_router.dart#L57) — الكلاس الذي يجمع مسؤوليات `app router`.
- [`static Future<String> getInitialLocation()`](../lib/core/routing/app_router.dart#L67) — يجلب `get initial location` من مصدر البيانات المناسب داخل `AppRouter`.
- [`static Future<String> _loginOrOnboarding()`](../lib/core/routing/app_router.dart#L133) — **خاص** — ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة داخل `AppRouter`.
- [`static String normalizeLocation(String location)`](../lib/core/routing/app_router.dart#L140) — ينفّذ منطق `normalize location` داخل `AppRouter`.
- [`static GoRouter createRouter(String initialLocation)`](../lib/core/routing/app_router.dart#L166) — ينشئ أو يضيف `create router` داخل `AppRouter`.
- [`class _LocationObserver`](../lib/core/routing/app_router.dart#L623) — **خاص** — الكلاس الذي يجمع مسؤوليات `location observer`.
- [`void _update()`](../lib/core/routing/app_router.dart#L626) — **خاص** — يحدّث `update` داخل `_LocationObserver`.
- [`void didPush(Route<dynamic> route, Route<dynamic>? previousRoute)`](../lib/core/routing/app_router.dart#L636) — **خاص** — ينفّذ منطق `did push` داخل `_LocationObserver`.
- [`void didPop(Route<dynamic> route, Route<dynamic>? previousRoute)`](../lib/core/routing/app_router.dart#L640) — **خاص** — ينفّذ منطق `did pop` داخل `_LocationObserver`.
- [`void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute})`](../lib/core/routing/app_router.dart#L643) — **خاص** — ينفّذ منطق `did replace` داخل `_LocationObserver`.
- [`void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute)`](../lib/core/routing/app_router.dart#L647) — **خاص** — ينفّذ منطق `did remove` داخل `_LocationObserver`.


## Core: services

### `core/services/app_language_manager.dart`

- [`class AppLanguageManager`](../lib/core/services/app_language_manager.dart#L6) — الكلاس الذي يقدّم خدمة `app language manager` لباقي التطبيق.
- [`Future<void> get initializationFuture`](../lib/core/services/app_language_manager.dart#L11) — ينفّذ منطق `initialization future` داخل `AppLanguageManager`.
- [`Stream<String> get languageStream`](../lib/core/services/app_language_manager.dart#L14) — ينفّذ منطق `language stream` داخل `AppLanguageManager`.
- [`AppLanguageManager._()`](../lib/core/services/app_language_manager.dart#L16) — ينشئ كائنًا من `AppLanguageManager` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> initialize()`](../lib/core/services/app_language_manager.dart#L19) — ينفّذ منطق `initialize` داخل `AppLanguageManager`.
- [`String get currentLanguage`](../lib/core/services/app_language_manager.dart#L44) — ينفّذ منطق `current language` داخل `AppLanguageManager`.
- [`bool get isInitialized`](../lib/core/services/app_language_manager.dart#L51) — يفحص شرط `is initialized` ويعيد النتيجة داخل `AppLanguageManager`.
- [`Future<void> setLanguage(String language)`](../lib/core/services/app_language_manager.dart#L53) — يحدّث `set language` داخل `AppLanguageManager`.
- [`void dispose()`](../lib/core/services/app_language_manager.dart#L69) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.

### `core/services/haptic_feedback_service.dart`

- [`class HapticFeedbackService`](../lib/core/services/haptic_feedback_service.dart#L3) — الكلاس الذي يقدّم خدمة `haptic feedback service` لباقي التطبيق.
- [`const HapticFeedbackService._()`](../lib/core/services/haptic_feedback_service.dart#L6) — ينشئ كائنًا من `HapticFeedbackService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void lightImpact()`](../lib/core/services/haptic_feedback_service.dart#L8) — ينفّذ منطق `light impact` داخل `HapticFeedbackService`.
- [`void mediumImpact()`](../lib/core/services/haptic_feedback_service.dart#L13) — ينفّذ منطق `medium impact` داخل `HapticFeedbackService`.
- [`void heavyImpact()`](../lib/core/services/haptic_feedback_service.dart#L18) — ينفّذ منطق `heavy impact` داخل `HapticFeedbackService`.
- [`void selectionClick()`](../lib/core/services/haptic_feedback_service.dart#L23) — يغيّر الاختيار الخاص بـ `selection click` داخل `HapticFeedbackService`.
- [`void vibrate()`](../lib/core/services/haptic_feedback_service.dart#L28) — ينفّذ منطق `vibrate` داخل `HapticFeedbackService`.
- [`void success()`](../lib/core/services/haptic_feedback_service.dart#L33) — ينفّذ منطق `success` داخل `HapticFeedbackService`.
- [`void error()`](../lib/core/services/haptic_feedback_service.dart#L38) — ينفّذ منطق `error` داخل `HapticFeedbackService`.
- [`void warning()`](../lib/core/services/haptic_feedback_service.dart#L43) — ينفّذ منطق `warning` داخل `HapticFeedbackService`.

### `core/services/location_repository.dart`

- [`class LocationRepository`](../lib/core/services/location_repository.dart#L3) — الكلاس الذي يقدّم خدمة `location repository` لباقي التطبيق.
- [`LocationResult? get cached`](../lib/core/services/location_repository.dart#L12) — ينفّذ منطق `cached` داخل `LocationRepository`.
- [`bool get hasLocation`](../lib/core/services/location_repository.dart#L14) — يفحص شرط `has location` ويعيد النتيجة داخل `LocationRepository`.
- [`Future<LocationResult> resolve(LocationService service, {Future<bool> Function()? showRationaleDialog})`](../lib/core/services/location_repository.dart#L16) — ينفّذ منطق `resolve` داخل `LocationRepository`.
- [`void cache(LocationResult result)`](../lib/core/services/location_repository.dart#L40) — ينفّذ منطق `cache` داخل `LocationRepository`.
- [`void clear()`](../lib/core/services/location_repository.dart#L44) — يحذف أو يمسح `clear` داخل `LocationRepository`.

### `core/services/location_service.dart`

- [`enum LocationAccessStatus`](../lib/core/services/location_service.dart#L9) — يعرّف القيم الثابتة الخاصة بـ `location access status`.
- [`class LocationResult`](../lib/core/services/location_service.dart#L26) — الكلاس الذي يقدّم خدمة `location result` لباقي التطبيق.
- [`const LocationResult({required this.status, this.latitude, this.longitude})`](../lib/core/services/location_service.dart#L31) — ينشئ كائنًا من `LocationResult` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get hasCoordinates`](../lib/core/services/location_service.dart#L33) — يفحص شرط `has coordinates` ويعيد النتيجة داخل `LocationResult`.
- [`factory LocationResult.granted(double lat, double lng)`](../lib/core/services/location_service.dart#L35) — ينشئ كائنًا من `LocationResult` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory LocationResult.status(LocationAccessStatus s)`](../lib/core/services/location_service.dart#L41) — ينشئ كائنًا من `LocationResult` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class LocationService`](../lib/core/services/location_service.dart#L46) — الكلاس الذي يقدّم خدمة `location service` لباقي التطبيق.
- [`Future<LocationResult> resolveLocation({bool requestIfNeeded = false, Future<bool> Function()? showRationaleDialog})`](../lib/core/services/location_service.dart#L61) — ينفّذ منطق `resolve location` داخل `LocationService`.
- [`Future<LocationResult> tryGetLocationSilently()`](../lib/core/services/location_service.dart#L124) — ينفّذ منطق `try get location silently` داخل `LocationService`.
- [`Future<LocationResult> retryWithPermissionRequest()`](../lib/core/services/location_service.dart#L148) — يعيد تحميل أو محاولة `retry with permission request` داخل `LocationService`.
- [`Future<bool> openAppSettings()`](../lib/core/services/location_service.dart#L152) — يعرض أو يفتح `open app settings` داخل `LocationService`.
- [`Future<_GpsEnableResult> _requestGpsEnable()`](../lib/core/services/location_service.dart#L157) — **خاص** — ينفّذ منطق `request gps enable` داخل `LocationService`.
- [`bool _isGranted(LocationPermission p)`](../lib/core/services/location_service.dart#L183) — **خاص** — يفحص شرط `is granted` ويعيد النتيجة داخل `LocationService`.
- [`Future<LocationResult> _fetchCoordinates()`](../lib/core/services/location_service.dart#L186) — **خاص** — يجلب `fetch coordinates` من مصدر البيانات المناسب داخل `LocationService`.
- [`enum _GpsEnableResult`](../lib/core/services/location_service.dart#L204) — **خاص** — يعرّف القيم الثابتة الخاصة بـ `gps enable result`.

### `core/services/url_launcher_service.dart`

- [`class UrlLauncherService`](../lib/core/services/url_launcher_service.dart#L3) — الكلاس الذي يقدّم خدمة `url launcher service` لباقي التطبيق.
- [`Future<bool> launchURL(String url)`](../lib/core/services/url_launcher_service.dart#L4) — ينفّذ الانتقال أو الفتح الخاص بـ `launch url` داخل `UrlLauncherService`.
- [`Future<bool> launchEmail(String email, {String? subject, String? body})`](../lib/core/services/url_launcher_service.dart#L20) — ينفّذ الانتقال أو الفتح الخاص بـ `launch email` داخل `UrlLauncherService`.
- [`Future<bool> launchWhatsApp(String phone, {String? message})`](../lib/core/services/url_launcher_service.dart#L45) — ينفّذ الانتقال أو الفتح الخاص بـ `launch whats app` داخل `UrlLauncherService`.
- [`Future<bool> makePhoneCall(String phone)`](../lib/core/services/url_launcher_service.dart#L66) — ينفّذ منطق `make phone call` داخل `UrlLauncherService`.
- [`Future<bool> launchSMS(String phone, {String? message})`](../lib/core/services/url_launcher_service.dart#L78) — ينفّذ الانتقال أو الفتح الخاص بـ `launch sms` داخل `UrlLauncherService`.
- [`Future<bool> launchFacebook(String url)`](../lib/core/services/url_launcher_service.dart#L91) — ينفّذ الانتقال أو الفتح الخاص بـ `launch facebook` داخل `UrlLauncherService`.


## Core: theming

### `core/theming/app_colors.dart`

- [`class AppColors`](../lib/core/theming/app_colors.dart#L3) — الكلاس الذي يجمع مسؤوليات `app colors`.

### `core/theming/app_snack_bar.dart`

- [`enum SnackBarType`](../lib/core/theming/app_snack_bar.dart#L9) — يعرّف القيم الثابتة الخاصة بـ `snack bar type`.
- [`void showAppSnackBar(BuildContext context, String message, {bool isError = false, Duration duration = const Duration(seconds: 3), SnackBarType? type, VoidCallback? onAction, String? actionLabel})`](../lib/core/theming/app_snack_bar.dart#L11) — يعرض أو يفتح `show app snack bar` داخل هذا الملف.
- [`class _SnackBarConfig`](../lib/core/theming/app_snack_bar.dart#L178) — **خاص** — الكلاس الذي يجمع مسؤوليات `snack bar config`.
- [`const _SnackBarConfig({required this.gradient, required this.icon, required this.title, required this.shadowColor})`](../lib/core/theming/app_snack_bar.dart#L184) — **خاص** — ينشئ كائنًا من `SnackBarConfig` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`_SnackBarConfig _getSnackBarConfig(SnackBarType type)`](../lib/core/theming/app_snack_bar.dart#L192) — **خاص** — يجلب `get snack bar config` من مصدر البيانات المناسب داخل هذا الملف.
- [`void showSimpleToast(BuildContext context, String message)`](../lib/core/theming/app_snack_bar.dart#L225) — يعرض أو يفتح `show simple toast` داخل هذا الملف.

### `core/theming/app_text_styles.dart`

- [`class AppFontSizes`](../lib/core/theming/app_text_styles.dart#L7) — الكلاس الذي يجمع مسؤوليات `app font sizes`.
- [`class AppTextStyles`](../lib/core/theming/app_text_styles.dart#L28) — الكلاس الذي يجمع مسؤوليات `app text styles`.
- [`static TextStyle _baseStyle(BuildContext context, {required double fontSize, required FontWeight fontWeight, required Color color})`](../lib/core/theming/app_text_styles.dart#L30) — **خاص** — ينفّذ منطق `base style` داخل `AppTextStyles`.
- [`static TextStyle custom(BuildContext context, {required double fontSize, FontWeight fontWeight = FontWeight.w400, Color color = AppColors.blackClr})`](../lib/core/theming/app_text_styles.dart#L45) — ينفّذ منطق `custom` داخل `AppTextStyles`.
- [`static TextStyle of({double? fontSize, FontWeight? fontWeight, Color? color, double? height, double? letterSpacing, TextDecoration? decoration, FontStyle? fontStyle, Color? decorationColor, double? decorationThickness})`](../lib/core/theming/app_text_styles.dart#L59) — ينفّذ منطق `of` داخل `AppTextStyles`.
- [`static TextStyle font20BlackSemiBold(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L91) — ينفّذ منطق `font20 black semi bold` داخل `AppTextStyles`.
- [`static TextStyle font20WhiteSemiBold(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L98) — ينفّذ منطق `font20 white semi bold` داخل `AppTextStyles`.
- [`static TextStyle font18BlackSemiBold(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L106) — ينفّذ منطق `font18 black semi bold` داخل `AppTextStyles`.
- [`static TextStyle font18BlackMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L113) — ينفّذ منطق `font18 black medium` داخل `AppTextStyles`.
- [`static TextStyle font16BlackRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L121) — ينفّذ منطق `font16 black regular` داخل `AppTextStyles`.
- [`static TextStyle font16BlackMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L124) — ينفّذ منطق `font16 black medium` داخل `AppTextStyles`.
- [`static TextStyle font16GreyRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L131) — ينفّذ منطق `font16 grey regular` داخل `AppTextStyles`.
- [`static TextStyle font16WhiteRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L134) — ينفّذ منطق `font16 white regular` داخل `AppTextStyles`.
- [`static TextStyle font16WhiteMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L137) — ينفّذ منطق `font16 white medium` داخل `AppTextStyles`.
- [`static TextStyle font16BlueMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L144) — ينفّذ منطق `font16 blue medium` داخل `AppTextStyles`.
- [`static TextStyle font16GreenMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L151) — ينفّذ منطق `font16 green medium` داخل `AppTextStyles`.
- [`static TextStyle font14BlackRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L159) — ينفّذ منطق `font14 black regular` داخل `AppTextStyles`.
- [`static TextStyle font14BlackMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L162) — ينفّذ منطق `font14 black medium` داخل `AppTextStyles`.
- [`static TextStyle font14GreyRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L169) — ينفّذ منطق `font14 grey regular` داخل `AppTextStyles`.
- [`static TextStyle font14WhiteRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L172) — ينفّذ منطق `font14 white regular` داخل `AppTextStyles`.
- [`static TextStyle font14WhiteMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L175) — ينفّذ منطق `font14 white medium` داخل `AppTextStyles`.
- [`static TextStyle font14PrimaryMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L182) — ينفّذ منطق `font14 primary medium` داخل `AppTextStyles`.
- [`static TextStyle font14BlueRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L189) — ينفّذ منطق `font14 blue regular` داخل `AppTextStyles`.
- [`static TextStyle font14BlueMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L192) — ينفّذ منطق `font14 blue medium` داخل `AppTextStyles`.
- [`static TextStyle font14GreenRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L199) — ينفّذ منطق `font14 green regular` داخل `AppTextStyles`.
- [`static TextStyle font12BlackRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L203) — ينفّذ منطق `font12 black regular` داخل `AppTextStyles`.
- [`static TextStyle font12BlackMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L206) — ينفّذ منطق `font12 black medium` داخل `AppTextStyles`.
- [`static TextStyle font12GreyRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L213) — ينفّذ منطق `font12 grey regular` داخل `AppTextStyles`.
- [`static TextStyle font12WhiteRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L216) — ينفّذ منطق `font12 white regular` داخل `AppTextStyles`.
- [`static TextStyle font12BlueRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L219) — ينفّذ منطق `font12 blue regular` داخل `AppTextStyles`.
- [`static TextStyle font12BlueMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L222) — ينفّذ منطق `font12 blue medium` داخل `AppTextStyles`.
- [`static TextStyle font10BlackRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L230) — ينفّذ منطق `font10 black regular` داخل `AppTextStyles`.
- [`static TextStyle font10BlackMedium(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L233) — ينفّذ منطق `font10 black medium` داخل `AppTextStyles`.
- [`static TextStyle font10GreyRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L240) — ينفّذ منطق `font10 grey regular` داخل `AppTextStyles`.
- [`static TextStyle font10WhiteRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L243) — ينفّذ منطق `font10 white regular` داخل `AppTextStyles`.
- [`static TextStyle font8WhiteRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L247) — ينفّذ منطق `font8 white regular` داخل `AppTextStyles`.
- [`static TextStyle font8GreyRegular(BuildContext context)`](../lib/core/theming/app_text_styles.dart#L250) — ينفّذ منطق `font8 grey regular` داخل `AppTextStyles`.
- [`extension TextStyleExtensions`](../lib/core/theming/app_text_styles.dart#L255) — يضيف وظائف مساعدة إلى نوع موجود دون تعديل تعريفه.
- [`TextStyle get bold`](../lib/core/theming/app_text_styles.dart#L256) — ينفّذ منطق `bold` داخل `TextStyleExtensions`.
- [`TextStyle get semiBold`](../lib/core/theming/app_text_styles.dart#L257) — ينفّذ منطق `semi bold` داخل `TextStyleExtensions`.
- [`TextStyle get medium`](../lib/core/theming/app_text_styles.dart#L258) — ينفّذ منطق `medium` داخل `TextStyleExtensions`.
- [`TextStyle withColor(Color color)`](../lib/core/theming/app_text_styles.dart#L260) — ينفّذ منطق `with color` داخل `TextStyleExtensions`.
- [`TextStyle withSize(double size)`](../lib/core/theming/app_text_styles.dart#L261) — ينفّذ منطق `with size` داخل `TextStyleExtensions`.
- [`TextStyle withValues({double? opacity})`](../lib/core/theming/app_text_styles.dart#L262) — ينفّذ منطق `with values` داخل `TextStyleExtensions`.

### `core/theming/app_toast.dart`

- [`enum ToastType`](../lib/core/theming/app_toast.dart#L9) — يعرّف القيم الثابتة الخاصة بـ `toast type`.
- [`Color _backgroundColorFor(ToastType type)`](../lib/core/theming/app_toast.dart#L14) — **خاص** — ينفّذ منطق `background color for` داخل هذا الملف.
- [`IconData _iconFor(ToastType type)`](../lib/core/theming/app_toast.dart#L27) — **خاص** — ينفّذ منطق `icon for` داخل هذا الملف.
- [`void showToast(String message, {ToastType type = ToastType.info, bool isError = false})`](../lib/core/theming/app_toast.dart#L40) — يعرض أو يفتح `show toast` داخل هذا الملف.
- [`void showSuccessToast(String message)`](../lib/core/theming/app_toast.dart#L71) — يعرض أو يفتح `show success toast` داخل هذا الملف.
- [`void showErrorToast(String message)`](../lib/core/theming/app_toast.dart#L75) — يعرض أو يفتح `show error toast` داخل هذا الملف.
- [`void showInfoToast(String message)`](../lib/core/theming/app_toast.dart#L78) — يعرض أو يفتح `show info toast` داخل هذا الملف.
- [`void showWarningToast(String message)`](../lib/core/theming/app_toast.dart#L80) — يعرض أو يفتح `show warning toast` داخل هذا الملف.
- [`void showLoginRequiredMessage(BuildContext context)`](../lib/core/theming/app_toast.dart#L83) — يعرض أو يفتح `show login required message` داخل هذا الملف.
- [`class _LoginRequiredToast`](../lib/core/theming/app_toast.dart#L109) — **خاص** — الكلاس الذي يجمع مسؤوليات `login required toast`.
- [`const _LoginRequiredToast({required this.onDismiss, required this.onLoginTap})`](../lib/core/theming/app_toast.dart#L113) — **خاص** — ينشئ كائنًا من `LoginRequiredToast` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_LoginRequiredToast> createState()`](../lib/core/theming/app_toast.dart#L118) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _LoginRequiredToastState`](../lib/core/theming/app_toast.dart#L122) — **خاص** — الكلاس الذي يجمع مسؤوليات `login required toast state`.
- [`void initState()`](../lib/core/theming/app_toast.dart#L128) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _dismiss()`](../lib/core/theming/app_toast.dart#L145) — **خاص** — ينفّذ منطق `dismiss` داخل `_LoginRequiredToastState`.
- [`void dispose()`](../lib/core/theming/app_toast.dart#L152) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/core/theming/app_toast.dart#L158) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ToastWidget`](../lib/core/theming/app_toast.dart#L238) — **خاص** — الكلاس الذي يجمع مسؤوليات `toast widget`.
- [`const _ToastWidget({required this.message, required this.type, required this.backgroundColor, required this.icon, required this.onDismiss})`](../lib/core/theming/app_toast.dart#L245) — **خاص** — ينشئ كائنًا من `ToastWidget` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_ToastWidget> createState()`](../lib/core/theming/app_toast.dart#L253) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ToastWidgetState`](../lib/core/theming/app_toast.dart#L257) — **خاص** — الكلاس الذي يجمع مسؤوليات `toast widget state`.
- [`void initState()`](../lib/core/theming/app_toast.dart#L263) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _dismiss()`](../lib/core/theming/app_toast.dart#L282) — **خاص** — ينفّذ منطق `dismiss` داخل `_ToastWidgetState`.
- [`void dispose()`](../lib/core/theming/app_toast.dart#L289) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/core/theming/app_toast.dart#L295) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `core/theming/font_manager.dart`

- [`class FontManager`](../lib/core/theming/font_manager.dart#L4) — الكلاس الذي يجمع مسؤوليات `font manager`.
- [`static String getFontFamily(BuildContext context)`](../lib/core/theming/font_manager.dart#L5) — يجلب `get font family` من مصدر البيانات المناسب داخل `FontManager`.


## Core: utils

### `core/utils/api_error_parser.dart`

- [`String parseApiError(dynamic error)`](../lib/core/utils/api_error_parser.dart#L7) — يحلّل `parse api error` ويحوّله لصيغة قابلة للاستخدام داخل هذا الملف.
- [`String _extractMessages(dynamic value)`](../lib/core/utils/api_error_parser.dart#L90) — **خاص** — ينفّذ منطق `extract messages` داخل هذا الملف.
- [`String _pickRelevantFieldError(dynamic errors)`](../lib/core/utils/api_error_parser.dart#L108) — **خاص** — ينفّذ منطق `pick relevant field error` داخل هذا الملف.
- [`String friendlyApiMessage(String message)`](../lib/core/utils/api_error_parser.dart#L140) — ينفّذ منطق `friendly api message` داخل هذا الملف.
- [`bool _isGenericMessage(String message)`](../lib/core/utils/api_error_parser.dart#L202) — **خاص** — يفحص شرط `is generic message` ويعيد النتيجة داخل هذا الملف.
- [`String? _messageForStatusCode(int? statusCode)`](../lib/core/utils/api_error_parser.dart#L216) — **خاص** — ينفّذ منطق `message for status code` داخل هذا الملف.
- [`String? _messageForAppFailure(AppFailure failure)`](../lib/core/utils/api_error_parser.dart#L231) — **خاص** — ينفّذ منطق `message for app failure` داخل هذا الملف.

### `core/utils/app_button.dart`

- [`class AppButton`](../lib/core/utils/app_button.dart#L9) — الكلاس الذي يجمع مسؤوليات `app button`.
- [`const AppButton({super.key, required this.text, required this.onPressed, this.width = 343, this.height = 48, this.isEnabled = true, this.isLoading = false, this.backgroundColor, this.textColor, this.useGradient = false, this.gradient, this.icon, this.iconSize})`](../lib/core/utils/app_button.dart#L23) — ينشئ كائنًا من `AppButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AppButton> createState()`](../lib/core/utils/app_button.dart#L39) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AppButtonState`](../lib/core/utils/app_button.dart#L43) — **خاص** — الكلاس الذي يجمع مسؤوليات `app button state`.
- [`void initState()`](../lib/core/utils/app_button.dart#L48) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/core/utils/app_button.dart#L65) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _handleTapDown(TapDownDetails details)`](../lib/core/utils/app_button.dart#L71) — **خاص** — يعالج حدث `handle tap down` داخل `_AppButtonState`.
- [`void _handleTapUp(TapUpDetails details)`](../lib/core/utils/app_button.dart#L77) — **خاص** — يعالج حدث `handle tap up` داخل `_AppButtonState`.
- [`void _handleTapCancel()`](../lib/core/utils/app_button.dart#L81) — **خاص** — يعالج حدث `handle tap cancel` داخل `_AppButtonState`.
- [`Widget build(BuildContext context)`](../lib/core/utils/app_button.dart#L85) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class AppOutlineButton`](../lib/core/utils/app_button.dart#L208) — الكلاس الذي يجمع مسؤوليات `app outline button`.
- [`const AppOutlineButton({super.key, required this.text, required this.onPressed, this.width = 343, this.height = 48, this.isEnabled = true, this.isLoading = false, this.borderColor, this.textColor, this.icon})`](../lib/core/utils/app_button.dart#L220) — ينشئ كائنًا من `AppOutlineButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AppOutlineButton> createState()`](../lib/core/utils/app_button.dart#L233) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AppOutlineButtonState`](../lib/core/utils/app_button.dart#L237) — **خاص** — الكلاس الذي يجمع مسؤوليات `app outline button state`.
- [`void initState()`](../lib/core/utils/app_button.dart#L242) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/core/utils/app_button.dart#L259) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _handleTapDown(TapDownDetails details)`](../lib/core/utils/app_button.dart#L265) — **خاص** — يعالج حدث `handle tap down` داخل `_AppOutlineButtonState`.
- [`void _handleTapUp(TapUpDetails details)`](../lib/core/utils/app_button.dart#L271) — **خاص** — يعالج حدث `handle tap up` داخل `_AppOutlineButtonState`.
- [`void _handleTapCancel()`](../lib/core/utils/app_button.dart#L275) — **خاص** — يعالج حدث `handle tap cancel` داخل `_AppOutlineButtonState`.
- [`Widget build(BuildContext context)`](../lib/core/utils/app_button.dart#L279) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `core/utils/app_date_formatter.dart`

- [`class AppDateFormatter`](../lib/core/utils/app_date_formatter.dart#L3) — الكلاس الذي يجمع مسؤوليات `app date formatter`.
- [`static DateTime? tryParse(String? value)`](../lib/core/utils/app_date_formatter.dart#L12) — ينفّذ منطق `try parse` داخل `AppDateFormatter`.
- [`static String _safe(String? value, String Function(DateTime) builder)`](../lib/core/utils/app_date_formatter.dart#L29) — **خاص** — ينفّذ منطق `safe` داخل `AppDateFormatter`.
- [`static String _localeCode(String? languageCode)`](../lib/core/utils/app_date_formatter.dart#L36) — **خاص** — ينفّذ منطق `locale code` داخل `AppDateFormatter`.
- [`static String formatDateTime(String? value, String? languageCode)`](../lib/core/utils/app_date_formatter.dart#L41) — ينسّق `format date time` للعرض أو الإرسال داخل `AppDateFormatter`.
- [`static String formatDate(String? value, String? languageCode)`](../lib/core/utils/app_date_formatter.dart#L56) — ينسّق `format date` للعرض أو الإرسال داخل `AppDateFormatter`.
- [`static String formatTime(String? value, String? languageCode)`](../lib/core/utils/app_date_formatter.dart#L71) — ينسّق `format time` للعرض أو الإرسال داخل `AppDateFormatter`.
- [`static String formatDateTimeShort(String? value, String? languageCode)`](../lib/core/utils/app_date_formatter.dart#L86) — ينسّق `format date time short` للعرض أو الإرسال داخل `AppDateFormatter`.

### `core/utils/app_error_handler.dart`

- [`class AppErrorHandler`](../lib/core/utils/app_error_handler.dart#L10) — الكلاس الذي يجمع مسؤوليات `app error handler`.
- [`static String messageFromFailure(AppFailure failure)`](../lib/core/utils/app_error_handler.dart#L11) — ينفّذ منطق `message from failure` داخل `AppErrorHandler`.
- [`static String getUserFriendlyMessage(String error)`](../lib/core/utils/app_error_handler.dart#L33) — يجلب `get user friendly message` من مصدر البيانات المناسب داخل `AppErrorHandler`.
- [`static bool _isTechnicalMessage(String message)`](../lib/core/utils/app_error_handler.dart#L93) — **خاص** — يفحص شرط `is technical message` ويعيد النتيجة داخل `AppErrorHandler`.
- [`static String _resolveMessage(Object error)`](../lib/core/utils/app_error_handler.dart#L105) — **خاص** — ينفّذ منطق `resolve message` داخل `AppErrorHandler`.
- [`static void showErrorSnackBar(BuildContext context, Object error, {VoidCallback? onRetry, Duration duration = const Duration(seconds: 4)})`](../lib/core/utils/app_error_handler.dart#L112) — يعرض أو يفتح `show error snack bar` داخل `AppErrorHandler`.
- [`static void showErrorDialog(BuildContext context, Object error, {VoidCallback? onRetry})`](../lib/core/utils/app_error_handler.dart#L122) — يعرض أو يفتح `show error dialog` داخل `AppErrorHandler`.
- [`static void logError(Object error, {StackTrace? stackTrace})`](../lib/core/utils/app_error_handler.dart#L161) — ينفّذ منطق `log error` داخل `AppErrorHandler`.
- [`static void handleApiResult(BuildContext context, ApiResult<T> result, {VoidCallback? onRetry, bool showDialog = false})`](../lib/core/utils/app_error_handler.dart#L168) — يعالج حدث `handle api result` داخل `AppErrorHandler`.
- [`static String? getErrorMessageFromResult(ApiResult<T> result)`](../lib/core/utils/app_error_handler.dart#L189) — يجلب `get error message from result` من مصدر البيانات المناسب داخل `AppErrorHandler`.
- [`static bool isFailure(ApiResult<T> result)`](../lib/core/utils/app_error_handler.dart#L194) — يفحص شرط `is failure` ويعيد النتيجة داخل `AppErrorHandler`.

### `core/utils/app_text_field.dart`

- [`class AppTextField`](../lib/core/utils/app_text_field.dart#L10) — الكلاس الذي يجمع مسؤوليات `app text field`.
- [`const AppTextField({super.key, this.controller, this.hintText, this.isPassword = false, this.prefixImagePath, this.prefixIcon, this.errorText, this.keyboardType = TextInputType.text, this.onChanged, this.enabled = true, this.validator, this.label, this.showSuccessState = false, this.maxLength, this.inputFormatters})`](../lib/core/utils/app_text_field.dart#L26) — ينشئ كائنًا من `AppTextField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AppTextField> createState()`](../lib/core/utils/app_text_field.dart#L44) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AppTextFieldState`](../lib/core/utils/app_text_field.dart#L48) — **خاص** — الكلاس الذي يجمع مسؤوليات `app text field state`.
- [`void initState()`](../lib/core/utils/app_text_field.dart#L61) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/core/utils/app_text_field.dart#L82) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onFocusChange()`](../lib/core/utils/app_text_field.dart#L90) — **خاص** — يعالج حدث `on focus change` داخل `_AppTextFieldState`.
- [`OutlineInputBorder _buildBorder(Color color, double width)`](../lib/core/utils/app_text_field.dart#L102) — **خاص** — ينفّذ منطق `build border` داخل `_AppTextFieldState`.
- [`Color _getBorderColor(bool hasError)`](../lib/core/utils/app_text_field.dart#L109) — **خاص** — يجلب `get border color` من مصدر البيانات المناسب داخل `_AppTextFieldState`.
- [`Widget build(BuildContext context)`](../lib/core/utils/app_text_field.dart#L120) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget? _buildPrefixIcon(bool hasError)`](../lib/core/utils/app_text_field.dart#L262) — **خاص** — ينفّذ منطق `build prefix icon` داخل `_AppTextFieldState`.
- [`Widget? _buildSuffixIcon(bool hasError)`](../lib/core/utils/app_text_field.dart#L292) — **خاص** — ينفّذ منطق `build suffix icon` داخل `_AppTextFieldState`.

### `core/utils/custom_showcase.dart`

- [`class CustomShowcase`](../lib/core/utils/custom_showcase.dart#L8) — الكلاس الذي يجمع مسؤوليات `custom showcase`.
- [`const CustomShowcase({super.key, required this.targetKey, required this.child})`](../lib/core/utils/custom_showcase.dart#L14) — ينشئ كائنًا من `CustomShowcase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/custom_showcase.dart#L20) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class CustomShowcaseOverlay`](../lib/core/utils/custom_showcase.dart#L26) — الكلاس الذي يجمع مسؤوليات `custom showcase overlay`.
- [`const CustomShowcaseOverlay({super.key, required this.targetKeys, required this.descriptions, required this.currentIndex, required this.child, this.onNext, this.onDismiss})`](../lib/core/utils/custom_showcase.dart#L35) — ينشئ كائنًا من `CustomShowcaseOverlay` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<CustomShowcaseOverlay> createState()`](../lib/core/utils/custom_showcase.dart#L45) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _CustomShowcaseOverlayState`](../lib/core/utils/custom_showcase.dart#L49) — **خاص** — الكلاس الذي يجمع مسؤوليات `custom showcase overlay state`.
- [`void initState()`](../lib/core/utils/custom_showcase.dart#L54) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void didUpdateWidget(CustomShowcaseOverlay oldWidget)`](../lib/core/utils/custom_showcase.dart#L68) — **خاص** — يتعامل مع تغيّر إعدادات الـ widget مع الاحتفاظ بالحالة.
- [`void dispose()`](../lib/core/utils/custom_showcase.dart#L77) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/core/utils/custom_showcase.dart#L83) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ShowcasePainter`](../lib/core/utils/custom_showcase.dart#L285) — **خاص** — الكلاس الذي يجمع مسؤوليات `showcase painter`.
- [`_ShowcasePainter({required this.targetPosition, required this.targetSize, required this.screenSize})`](../lib/core/utils/custom_showcase.dart#L291) — **خاص** — ينشئ كائنًا من `ShowcasePainter` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void paint(Canvas canvas, Size size)`](../lib/core/utils/custom_showcase.dart#L297) — **خاص** — ينفّذ منطق `paint` داخل `_ShowcasePainter`.
- [`bool shouldRepaint(_ShowcasePainter oldDelegate)`](../lib/core/utils/custom_showcase.dart#L369) — **خاص** — يفحص شرط `should repaint` ويعيد النتيجة داخل `_ShowcasePainter`.

### `core/utils/egyptian_phone_field.dart`

- [`class EgyptianPhoneField`](../lib/core/utils/egyptian_phone_field.dart#L9) — الكلاس الذي يجمع مسؤوليات `egyptian phone field`.
- [`const EgyptianPhoneField({super.key, required this.controller, this.validator, this.hintText, required this.phoneRequiredKey, required this.phoneInvalidKey, this.onChanged, this.maxLength})`](../lib/core/utils/egyptian_phone_field.dart#L19) — ينشئ كائنًا من `EgyptianPhoneField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<EgyptianPhoneField> createState()`](../lib/core/utils/egyptian_phone_field.dart#L30) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _EgyptianPhoneFieldState`](../lib/core/utils/egyptian_phone_field.dart#L34) — **خاص** — الكلاس الذي يجمع مسؤوليات `egyptian phone field state`.
- [`void initState()`](../lib/core/utils/egyptian_phone_field.dart#L38) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/core/utils/egyptian_phone_field.dart#L48) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`String? _defaultValidator(String? value)`](../lib/core/utils/egyptian_phone_field.dart#L54) — **خاص** — ينفّذ منطق `default validator` داخل `_EgyptianPhoneFieldState`.
- [`Widget build(BuildContext context)`](../lib/core/utils/egyptian_phone_field.dart#L71) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `core/utils/error_state_widget.dart`

- [`class ErrorStateWidget`](../lib/core/utils/error_state_widget.dart#L10) — الكلاس الذي يجمع مسؤوليات `error state widget`.
- [`const ErrorStateWidget({super.key, required this.error, this.title, this.onRetry, this.icon, this.showDetails = false})`](../lib/core/utils/error_state_widget.dart#L18) — ينشئ كائنًا من `ErrorStateWidget` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/error_state_widget.dart#L27) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _getErrorMessage(BuildContext context)`](../lib/core/utils/error_state_widget.dart#L95) — **خاص** — يجلب `get error message` من مصدر البيانات المناسب داخل `ErrorStateWidget`.
- [`class CompactErrorWidget`](../lib/core/utils/error_state_widget.dart#L107) — الكلاس الذي يجمع مسؤوليات `compact error widget`.
- [`const CompactErrorWidget({super.key, required this.error, this.onRetry})`](../lib/core/utils/error_state_widget.dart#L112) — ينشئ كائنًا من `CompactErrorWidget` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/error_state_widget.dart#L118) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _getErrorMessage(BuildContext context)`](../lib/core/utils/error_state_widget.dart#L148) — **خاص** — يجلب `get error message` من مصدر البيانات المناسب داخل `CompactErrorWidget`.

### `core/utils/image_url_resolver.dart`

- [`String? resolveImageUrl(String? url)`](../lib/core/utils/image_url_resolver.dart#L1) — ينفّذ منطق `resolve image url` داخل هذا الملف.

### `core/utils/language_helper.dart`

- [`class LanguageHelper`](../lib/core/utils/language_helper.dart#L4) — الكلاس الذي يجمع مسؤوليات `language helper`.
- [`static String getLanguageCode(BuildContext context)`](../lib/core/utils/language_helper.dart#L17) — يجلب `get language code` من مصدر البيانات المناسب داخل `LanguageHelper`.
- [`static String convertArabicToEnglishNumerals(String input)`](../lib/core/utils/language_helper.dart#L23) — ينفّذ منطق `convert arabic to english numerals` داخل `LanguageHelper`.

### `core/utils/platform_type.dart`

- [`enum PlatformType`](../lib/core/utils/platform_type.dart#L3) — يعرّف القيم الثابتة الخاصة بـ `platform type`.
- [`const PlatformType(this.value)`](../lib/core/utils/platform_type.dart#L15) — ينشئ كائنًا من `PlatformType` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static PlatformType get current`](../lib/core/utils/platform_type.dart#L17) — ينفّذ منطق `current` داخل `PlatformType`.

### `core/utils/relation_helper.dart`

- [`class RelationHelper`](../lib/core/utils/relation_helper.dart#L3) — الكلاس الذي يجمع مسؤوليات `relation helper`.
- [`static String getLocalizedRelation(int? relation)`](../lib/core/utils/relation_helper.dart#L4) — يجلب `get localized relation` من مصدر البيانات المناسب داخل `RelationHelper`.
- [`static List<Map<String, dynamic>> getRelationsList()`](../lib/core/utils/relation_helper.dart#L37) — يجلب `get relations list` من مصدر البيانات المناسب داخل `RelationHelper`.

### `core/utils/shimmer_card.dart`

- [`class SmoothShimmer`](../lib/core/utils/shimmer_card.dart#L7) — الكلاس الذي يجمع مسؤوليات `smooth shimmer`.
- [`const SmoothShimmer({super.key, required this.child, this.baseColor, this.highlightColor, this.period = const Duration(milliseconds: 1500), this.direction = ShimmerDirection.ltr})`](../lib/core/utils/shimmer_card.dart#L15) — ينشئ كائنًا من `SmoothShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L24) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ShimmerCard`](../lib/core/utils/shimmer_card.dart#L37) — الكلاس الذي يجمع مسؤوليات `shimmer card`.
- [`const ShimmerCard({super.key, this.width, required this.height, this.borderRadius, this.margin})`](../lib/core/utils/shimmer_card.dart#L44) — ينشئ كائنًا من `ShimmerCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L52) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ShimmerListItem`](../lib/core/utils/shimmer_card.dart#L73) — الكلاس الذي يجمع مسؤوليات `shimmer list item`.
- [`const ShimmerListItem({super.key, this.showAvatar = true, this.lines = 2, this.avatarSize, this.padding})`](../lib/core/utils/shimmer_card.dart#L80) — ينشئ كائنًا من `ShimmerListItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L88) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ShimmerApprovalCard`](../lib/core/utils/shimmer_card.dart#L138) — الكلاس الذي يجمع مسؤوليات `shimmer approval card`.
- [`const ShimmerApprovalCard({super.key})`](../lib/core/utils/shimmer_card.dart#L140) — ينشئ كائنًا من `ShimmerApprovalCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L142) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ShimmerGridItem`](../lib/core/utils/shimmer_card.dart#L246) — الكلاس الذي يجمع مسؤوليات `shimmer grid item`.
- [`const ShimmerGridItem({super.key, this.width, this.height})`](../lib/core/utils/shimmer_card.dart#L251) — ينشئ كائنًا من `ShimmerGridItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L257) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class PulseShimmer`](../lib/core/utils/shimmer_card.dart#L296) — الكلاس الذي يجمع مسؤوليات `pulse shimmer`.
- [`const PulseShimmer({super.key, required this.child, this.duration = const Duration(milliseconds: 1200)})`](../lib/core/utils/shimmer_card.dart#L301) — ينشئ كائنًا من `PulseShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<PulseShimmer> createState()`](../lib/core/utils/shimmer_card.dart#L307) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _PulseShimmerState`](../lib/core/utils/shimmer_card.dart#L311) — **خاص** — الكلاس الذي يجمع مسؤوليات `pulse shimmer state`.
- [`void initState()`](../lib/core/utils/shimmer_card.dart#L316) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/core/utils/shimmer_card.dart#L333) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/core/utils/shimmer_card.dart#L339) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Core: widgets

### `core/widgets/app_blue_header.dart`

- [`class AppBlueHeader`](../lib/core/widgets/app_blue_header.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AppBlueHeader({super.key, this.title, this.subtitle, this.showBack = true, this.onBack, this.actions, this.bottomChild, this.bottomRadius = 24, this.color = const Color(0xFF3872B1), this.padding, this.contentHeight})`](../lib/core/widgets/app_blue_header.dart#L79) — ينشئ كائنًا من `AppBlueHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/widgets/app_blue_header.dart#L93) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `core/widgets/app_simple_header.dart`

- [`class AppSimpleHeader`](../lib/core/widgets/app_simple_header.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AppSimpleHeader({super.key, this.title, this.subtitle, this.showBack = true, this.onBack, this.actions, this.bottomChild})`](../lib/core/widgets/app_simple_header.dart#L28) — ينشئ كائنًا من `AppSimpleHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void _handleBack(BuildContext context)`](../lib/core/widgets/app_simple_header.dart#L38) — **خاص** — يعالج حدث `handle back` داخل `AppSimpleHeader`.
- [`Widget build(BuildContext context)`](../lib/core/widgets/app_simple_header.dart#L48) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `core/widgets/auth_shared_widgets.dart`

- [`class AuthFieldLabel`](../lib/core/widgets/auth_shared_widgets.dart#L17) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AuthFieldLabel(this.text, {super.key, this.isRequired = false})`](../lib/core/widgets/auth_shared_widgets.dart#L21) — ينشئ كائنًا من `AuthFieldLabel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/widgets/auth_shared_widgets.dart#L23) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class AuthGenderOption`](../lib/core/widgets/auth_shared_widgets.dart#L52) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AuthGenderOption({super.key, required this.label, required this.selected, required this.onTap})`](../lib/core/widgets/auth_shared_widgets.dart#L57) — ينشئ كائنًا من `AuthGenderOption` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/widgets/auth_shared_widgets.dart#L64) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`InputDecoration authInputDecoration({required String hintText, Widget? suffixIcon})`](../lib/core/widgets/auth_shared_widgets.dart#L110) — ينفّذ منطق `auth input decoration` داخل هذا الملف.
- [`class AuthBlueHeader`](../lib/core/widgets/auth_shared_widgets.dart#L146) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AuthBlueHeader({super.key, this.showBackButton = false, this.onBack, this.logoAsset = AppAssets.mediLogo, required this.title})`](../lib/core/widgets/auth_shared_widgets.dart#L152) — ينشئ كائنًا من `AuthBlueHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/widgets/auth_shared_widgets.dart#L160) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class AuthPrimaryButton`](../lib/core/widgets/auth_shared_widgets.dart#L220) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const AuthPrimaryButton({super.key, required this.label, required this.isLoading, required this.onPressed})`](../lib/core/widgets/auth_shared_widgets.dart#L225) — ينشئ كائنًا من `AuthPrimaryButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/core/widgets/auth_shared_widgets.dart#L232) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Module: data

### `data/auth_login_request_model.dart`

- [`class AuthLoginRequestModel`](../lib/data/auth_login_request_model.dart#L5) — الكلاس الذي يمثل بيانات `auth login request model` وينقلها بين الطبقات.
- [`const AuthLoginRequestModel({this.cardNumber, this.phoneNumber, required this.password, this.platformType = 1})`](../lib/data/auth_login_request_model.dart#L16) — ينشئ كائنًا من `AuthLoginRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AuthLoginRequestModel.fromJson(Map<String, dynamic> json)`](../lib/data/auth_login_request_model.dart#L23) — ينشئ كائنًا من `AuthLoginRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/auth_login_request_model.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/auth_register_request_model.dart`

- [`class AuthRegisterRequestModel`](../lib/data/auth_register_request_model.dart#L5) — الكلاس الذي يمثل بيانات `auth register request model` وينقلها بين الطبقات.
- [`const AuthRegisterRequestModel({required this.firstName, required this.lastName, required this.phoneNumber, required this.isMale, required this.birthDate, required this.password, required this.confirmPassword, this.nationalId, this.passportNumber})`](../lib/data/auth_register_request_model.dart#L17) — ينشئ كائنًا من `AuthRegisterRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AuthRegisterRequestModel.fromJson(Map<String, dynamic> json)`](../lib/data/auth_register_request_model.dart#L29) — ينشئ كائنًا من `AuthRegisterRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/auth_register_request_model.dart#L32) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/auth_response_model.dart`

- [`class AuthResponseModel`](../lib/data/auth_response_model.dart#L5) — الكلاس الذي يمثل بيانات `auth response model` وينقلها بين الطبقات.
- [`const AuthResponseModel({this.httpStatusCode, this.errors, required this.succeeded, this.message, this.data})`](../lib/data/auth_response_model.dart#L14) — ينشئ كائنًا من `AuthResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AuthResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/auth_response_model.dart#L22) — ينشئ كائنًا من `AuthResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/auth_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`Object? _readSucceeded(Map<dynamic, dynamic> json, String key)`](../lib/data/auth_response_model.dart#L28) — **خاص** — ينفّذ منطق `read succeeded` داخل هذا الملف.
- [`class AuthTokenDataModel`](../lib/data/auth_response_model.dart#L32) — الكلاس الذي يمثل بيانات `auth token data model` وينقلها بين الطبقات.
- [`const AuthTokenDataModel({this.token, this.expiresAt, this.refreshToken, this.refreshTokenExpiresAt, this.success, this.message})`](../lib/data/auth_response_model.dart#L58) — ينشئ كائنًا من `AuthTokenDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AuthTokenDataModel.fromJson(Map<String, dynamic> json)`](../lib/data/auth_response_model.dart#L67) — ينشئ كائنًا من `AuthTokenDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/auth_response_model.dart#L70) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`static DateTime? _parseDateTimeOrNull(String? value)`](../lib/data/auth_response_model.dart#L74) — **خاص** — يحلّل `parse date time or null` ويحوّله لصيغة قابلة للاستخدام داخل `AuthTokenDataModel`.
- [`static String? _dateTimeToStringOrNull(DateTime? dt)`](../lib/data/auth_response_model.dart#L79) — **خاص** — ينفّذ منطق `date time to string or null` داخل `AuthTokenDataModel`.

### `data/card_home_info_response_model.dart`

- [`class CardHomeInfoResponseModel`](../lib/data/card_home_info_response_model.dart#L5) — الكلاس الذي يمثل بيانات `card home info response model` وينقلها بين الطبقات.
- [`const CardHomeInfoResponseModel({required this.success, required this.timestamp, required this.message, this.data})`](../lib/data/card_home_info_response_model.dart#L12) — ينشئ كائنًا من `CardHomeInfoResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardHomeInfoResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_home_info_response_model.dart#L19) — ينشئ كائنًا من `CardHomeInfoResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_home_info_response_model.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardHomeInfoDataModel`](../lib/data/card_home_info_response_model.dart#L25) — الكلاس الذي يمثل بيانات `card home info data model` وينقلها بين الطبقات.
- [`const CardHomeInfoDataModel({required this.cardId, required this.firstName, required this.lastName, required this.expireDate, this.memberPhoto})`](../lib/data/card_home_info_response_model.dart#L33) — ينشئ كائنًا من `CardHomeInfoDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardHomeInfoDataModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_home_info_response_model.dart#L41) — ينشئ كائنًا من `CardHomeInfoDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_home_info_response_model.dart#L44) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_login_request_model.dart`

- [`class CardLoginRequestModel`](../lib/data/card_login_request_model.dart#L5) — الكلاس الذي يمثل بيانات `card login request model` وينقلها بين الطبقات.
- [`const CardLoginRequestModel({required this.cardNo, required this.password})`](../lib/data/card_login_request_model.dart#L13) — ينشئ كائنًا من `CardLoginRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardLoginRequestModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_login_request_model.dart#L18) — ينشئ كائنًا من `CardLoginRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_login_request_model.dart#L21) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_login_response_model.dart`

- [`class CardLoginResponseModel`](../lib/data/card_login_response_model.dart#L5) — الكلاس الذي يمثل بيانات `card login response model` وينقلها بين الطبقات.
- [`const CardLoginResponseModel({required this.success, required this.timestamp, required this.message, this.data})`](../lib/data/card_login_response_model.dart#L12) — ينشئ كائنًا من `CardLoginResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardLoginResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_login_response_model.dart#L19) — ينشئ كائنًا من `CardLoginResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_login_response_model.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardLoginDataModel`](../lib/data/card_login_response_model.dart#L25) — الكلاس الذي يمثل بيانات `card login data model` وينقلها بين الطبقات.
- [`const CardLoginDataModel({required this.cardId, required this.firstName, required this.lasName})`](../lib/data/card_login_response_model.dart#L31) — ينشئ كائنًا من `CardLoginDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardLoginDataModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_login_response_model.dart#L37) — ينشئ كائنًا من `CardLoginDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_login_response_model.dart#L40) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_personal_info_response_model.dart`

- [`class CardPersonalInfoResponseModel`](../lib/data/card_personal_info_response_model.dart#L5) — الكلاس الذي يمثل بيانات `card personal info response model` وينقلها بين الطبقات.
- [`const CardPersonalInfoResponseModel({required this.success, required this.timestamp, required this.message, this.data})`](../lib/data/card_personal_info_response_model.dart#L12) — ينشئ كائنًا من `CardPersonalInfoResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardPersonalInfoResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_personal_info_response_model.dart#L19) — ينشئ كائنًا من `CardPersonalInfoResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_personal_info_response_model.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardPersonalInfoDataModel`](../lib/data/card_personal_info_response_model.dart#L25) — الكلاس الذي يمثل بيانات `card personal info data model` وينقلها بين الطبقات.
- [`const CardPersonalInfoDataModel({required this.firstName, required this.lastName, this.image, required this.cardId, required this.mobile, required this.birthdate, required this.isMale, this.passport, this.email, this.nationalId, required this.activatedDate, required this.expireDate})`](../lib/data/card_personal_info_response_model.dart#L40) — ينشئ كائنًا من `CardPersonalInfoDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardPersonalInfoDataModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_personal_info_response_model.dart#L55) — ينشئ كائنًا من `CardPersonalInfoDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_personal_info_response_model.dart#L58) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_support_contact_response_model.dart`

- [`class CardSupportContactResponseModel`](../lib/data/card_support_contact_response_model.dart#L1) — الكلاس الذي يمثل بيانات `card support contact response model` وينقلها بين الطبقات.
- [`const CardSupportContactResponseModel({required this.success, required this.timestamp, required this.message, required this.data})`](../lib/data/card_support_contact_response_model.dart#L7) — ينشئ كائنًا من `CardSupportContactResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardSupportContactResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_support_contact_response_model.dart#L14) — ينشئ كائنًا من `CardSupportContactResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_support_contact_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardSupportContactData`](../lib/data/card_support_contact_response_model.dart#L35) — الكلاس الذي يمثل بيانات `card support contact data` وينقلها بين الطبقات.
- [`const CardSupportContactData({required this.email, required this.hotLine, required this.whatsApp, required this.website, required this.linkedIn, required this.facebook, required this.instagram})`](../lib/data/card_support_contact_response_model.dart#L44) — ينشئ كائنًا من `CardSupportContactData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardSupportContactData.fromJson(Map<String, dynamic> json)`](../lib/data/card_support_contact_response_model.dart#L54) — ينشئ كائنًا من `CardSupportContactData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String valueOf(String key)`](../lib/data/card_support_contact_response_model.dart#L55) — ينفّذ منطق `value of` داخل `CardSupportContactData`.
- [`Map<String, dynamic> toJson()`](../lib/data/card_support_contact_response_model.dart#L67) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_update_profile_request_model.dart`

- [`class CardUpdateProfileRequestModel`](../lib/data/card_update_profile_request_model.dart#L5) — الكلاس الذي يمثل بيانات `card update profile request model` وينقلها بين الطبقات.
- [`const CardUpdateProfileRequestModel({required this.cardNo, this.firstName, this.lastName, this.phoneNumber, this.email, this.nationalId, this.passportNumber, this.birthdate, this.isMale, this.profileImage})`](../lib/data/card_update_profile_request_model.dart#L18) — ينشئ كائنًا من `CardUpdateProfileRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardUpdateProfileRequestModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_update_profile_request_model.dart#L31) — ينشئ كائنًا من `CardUpdateProfileRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_update_profile_request_model.dart#L34) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `data/card_update_profile_response_model.dart`

- [`class CardUpdateProfileResponseModel`](../lib/data/card_update_profile_response_model.dart#L5) — الكلاس الذي يمثل بيانات `card update profile response model` وينقلها بين الطبقات.
- [`const CardUpdateProfileResponseModel({required this.success, required this.timestamp, required this.message, this.data})`](../lib/data/card_update_profile_response_model.dart#L12) — ينشئ كائنًا من `CardUpdateProfileResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardUpdateProfileResponseModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_update_profile_response_model.dart#L19) — ينشئ كائنًا من `CardUpdateProfileResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_update_profile_response_model.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardUpdateProfileDataModel`](../lib/data/card_update_profile_response_model.dart#L26) — الكلاس الذي يمثل بيانات `card update profile data model` وينقلها بين الطبقات.
- [`const CardUpdateProfileDataModel({required this.cardId, required this.firstName, required this.lastName, required this.mobile, this.email, this.nationalId, this.passportNumber, required this.birthdate, required this.isMale, this.profileImage})`](../lib/data/card_update_profile_response_model.dart#L39) — ينشئ كائنًا من `CardUpdateProfileDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardUpdateProfileDataModel.fromJson(Map<String, dynamic> json)`](../lib/data/card_update_profile_response_model.dart#L52) — ينشئ كائنًا من `CardUpdateProfileDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/data/card_update_profile_response_model.dart#L55) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.


## Module: domain

### `domain/medicard_repository.dart`

- [`class MedicardRepository`](../lib/domain/medicard_repository.dart#L20) — الكلاس الذي يجمع مسؤوليات `medicard repository`.
- [`Future<ApiResult<AuthResponseModel>> register(AuthRegisterRequestModel request)`](../lib/domain/medicard_repository.dart#L21) — يسجّل `register` لدى النظام أو الخدمة داخل `MedicardRepository`.
- [`Future<ApiResult<AuthResponseModel>> login(AuthLoginRequestModel request)`](../lib/domain/medicard_repository.dart#L25) — ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة داخل `MedicardRepository`.
- [`Future<ApiResult<OtpResponseModel>> sendOtp(String phoneNumber)`](../lib/domain/medicard_repository.dart#L27) — يرسل `send otp` إلى الطبقة أو الخدمة المطلوبة داخل `MedicardRepository`.
- [`Future<ApiResult<OtpResponseModel>> verifyOtp({required String phoneNumber, required String otp})`](../lib/domain/medicard_repository.dart#L29) — ينفّذ منطق `verify otp` داخل `MedicardRepository`.
- [`Future<ApiResult<OtpResponseModel>> resetPassword({required String phoneNumber, required String password, required String confirmPassword})`](../lib/domain/medicard_repository.dart#L34) — ينفّذ منطق `reset password` داخل `MedicardRepository`.
- [`Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(String cardNo, String lang)`](../lib/domain/medicard_repository.dart#L40) — يجلب `get home info` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(String cardNo, String lang)`](../lib/domain/medicard_repository.dart#L45) — يجلب `get personal info` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(String lang)`](../lib/domain/medicard_repository.dart#L50) — يجلب `get support contacts` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(CardUpdateProfileRequestModel request, String lang)`](../lib/domain/medicard_repository.dart#L54) — يحدّث `update profile` داخل `MedicardRepository`.
- [`Future<ApiResult<HomeResponseModel>> getHomeData({double? latitude, double? longitude})`](../lib/domain/medicard_repository.dart#L59) — يجلب `get home data` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<ProfileResponseModel>> getProfile()`](../lib/domain/medicard_repository.dart#L64) — يجلب `get profile` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<ProfileSummaryResponseModel>> getProfileSummary()`](../lib/domain/medicard_repository.dart#L66) — يجلب `get profile summary` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<ProfileResponseModel>> deleteProfileImage()`](../lib/domain/medicard_repository.dart#L71) — يحذف أو يمسح `delete profile image` داخل `MedicardRepository`.
- [`Future<ApiResult<MemberCardActivationResponseModel>> activateMemberCard({required String cardNumber})`](../lib/domain/medicard_repository.dart#L73) — ينفّذ منطق `activate member card` داخل `MedicardRepository`.
- [`Future<ApiResult<CardDataResponseModel>> getCardData()`](../lib/domain/medicard_repository.dart#L77) — يجلب `get card data` من مصدر البيانات المناسب داخل `MedicardRepository`.
- [`Future<ApiResult<ProfileResponseModel>> updateProfileV2({required String firstName, required String lastName, required String phoneNumber, required String nationalId, String? passportNumber, required bool isMale, required String birthDate, String? imagePath, bool removeImage = false, String? currentImageUrl})`](../lib/domain/medicard_repository.dart#L79) — يحدّث `update profile v2` داخل `MedicardRepository`.
- [`Future<ApiResult<ChangePasswordResponseModel>> changePassword({required String currentPassword, required String newPassword, required String confirmNewPassword})`](../lib/domain/medicard_repository.dart#L92) — يحدّث `change password` داخل `MedicardRepository`.
- [`Future<ApiResult<ChangeLanguageResponseModel>> changeLanguage({required String language})`](../lib/domain/medicard_repository.dart#L98) — يحدّث `change language` داخل `MedicardRepository`.
- [`Future<ApiResult<GuestHomeResponseModel>> getGuestHomeData({double? latitude, double? longitude})`](../lib/domain/medicard_repository.dart#L102) — يجلب `get guest home data` من مصدر البيانات المناسب داخل `MedicardRepository`.

### `domain/usecases/get_home_info_usecase.dart`

- [`class GetHomeInfoUseCase`](../lib/domain/usecases/get_home_info_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `get home info use case`.
- [`GetHomeInfoUseCase(this._repository)`](../lib/domain/usecases/get_home_info_usecase.dart#L9) — ينشئ كائنًا من `GetHomeInfoUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CardHomeInfoResponseModel>> call(String cardNo, String lang)`](../lib/domain/usecases/get_home_info_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/get_personal_info_usecase.dart`

- [`class GetPersonalInfoUseCase`](../lib/domain/usecases/get_personal_info_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `get personal info use case`.
- [`GetPersonalInfoUseCase(this._repository)`](../lib/domain/usecases/get_personal_info_usecase.dart#L9) — ينشئ كائنًا من `GetPersonalInfoUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CardPersonalInfoResponseModel>> call(String cardNo, String lang)`](../lib/domain/usecases/get_personal_info_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/get_support_contacts_usecase.dart`

- [`class GetSupportContactsUseCase`](../lib/domain/usecases/get_support_contacts_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `get support contacts use case`.
- [`GetSupportContactsUseCase(this._repository)`](../lib/domain/usecases/get_support_contacts_usecase.dart#L9) — ينشئ كائنًا من `GetSupportContactsUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CardSupportContactResponseModel>> call(String lang)`](../lib/domain/usecases/get_support_contacts_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/login_card_usecase.dart`

- [`class LoginCardUseCase`](../lib/domain/usecases/login_card_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `login card use case`.
- [`LoginCardUseCase(this._repository)`](../lib/domain/usecases/login_card_usecase.dart#L9) — ينشئ كائنًا من `LoginCardUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<AuthResponseModel>> call(AuthLoginRequestModel request)`](../lib/domain/usecases/login_card_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/logout_usecase.dart`

- [`class LogoutUseCase`](../lib/domain/usecases/logout_usecase.dart#L8) — الكلاس الذي يعزل عملية أعمال واحدة: `logout use case`.
- [`const LogoutUseCase()`](../lib/domain/usecases/logout_usecase.dart#L14) — ينشئ كائنًا من `LogoutUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> call()`](../lib/domain/usecases/logout_usecase.dart#L16) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/register_usecase.dart`

- [`class RegisterUseCase`](../lib/domain/usecases/register_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `register use case`.
- [`RegisterUseCase(this._repository)`](../lib/domain/usecases/register_usecase.dart#L9) — ينشئ كائنًا من `RegisterUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<AuthResponseModel>> call(AuthRegisterRequestModel request)`](../lib/domain/usecases/register_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `domain/usecases/update_profile_usecase.dart`

- [`class UpdateProfileUseCase`](../lib/domain/usecases/update_profile_usecase.dart#L7) — الكلاس الذي يعزل عملية أعمال واحدة: `update profile use case`.
- [`UpdateProfileUseCase(this._repository)`](../lib/domain/usecases/update_profile_usecase.dart#L10) — ينشئ كائنًا من `UpdateProfileUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CardUpdateProfileResponseModel>> call(CardUpdateProfileRequestModel request, String lang)`](../lib/domain/usecases/update_profile_usecase.dart#L12) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.


## Feature: activate_card

### `features/activate_card/data/models/activate_card_request_model.dart`

- [`class ActivateCardRequestModel`](../lib/features/activate_card/data/models/activate_card_request_model.dart#L1) — الكلاس الذي يمثل بيانات `activate card request model` وينقلها بين الطبقات.
- [`const ActivateCardRequestModel({required this.firstName, required this.lastName, required this.cardNumber, required this.isMale, required this.phoneNumber, required this.birthDate, required this.password, required this.confirmPassword, this.nationalId, this.passportNumber})`](../lib/features/activate_card/data/models/activate_card_request_model.dart#L13) — ينشئ كائنًا من `ActivateCardRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activate_card/data/models/activate_card_request_model.dart#L17) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activate_card/data/models/activate_card_response_model.dart`

- [`class ActivateCardResponseModel`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L5) — الكلاس الذي يمثل بيانات `activate card response model` وينقلها بين الطبقات.
- [`const ActivateCardResponseModel({required this.httpStatusCode, this.errors, required this.succeeded, required this.message, this.data})`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L18) — ينشئ كائنًا من `ActivateCardResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ActivateCardResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L23) — ينشئ كائنًا من `ActivateCardResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ActivateCardData`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L29) — الكلاس الذي يمثل بيانات `activate card data` وينقلها بين الطبقات.
- [`const ActivateCardData({required this.token, required this.expiresAt})`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L36) — ينشئ كائنًا من `ActivateCardData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ActivateCardData.fromJson(Map<String, dynamic> json)`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L39) — ينشئ كائنًا من `ActivateCardData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activate_card/data/models/activate_card_response_model.dart#L42) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activate_card/data/repository/activate_card_repository_impl.dart`

- [`class ActivateCardRepositoryImpl`](../lib/features/activate_card/data/repository/activate_card_repository_impl.dart#L9) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `activate card repository impl`.
- [`Future<Either<String, ActivateCardResponseModel>> activateCard(ActivateCardRequestModel request)`](../lib/features/activate_card/data/repository/activate_card_repository_impl.dart#L12) — ينفّذ منطق `activate card` داخل `ActivateCardRepositoryImpl`.
- [`String? _backendMessageFrom(dynamic value)`](../lib/features/activate_card/data/repository/activate_card_repository_impl.dart#L55) — **خاص** — ينفّذ منطق `backend message from` داخل `ActivateCardRepositoryImpl`.
- [`String _extractBackendMessages(dynamic value)`](../lib/features/activate_card/data/repository/activate_card_repository_impl.dart#L60) — **خاص** — ينفّذ منطق `extract backend messages` داخل `ActivateCardRepositoryImpl`.

### `features/activate_card/domain/repository/activate_card_repository.dart`

- [`class ActivateCardRepository`](../lib/features/activate_card/domain/repository/activate_card_repository.dart#L5) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `activate card repository`.
- [`Future<Either<String, ActivateCardResponseModel>> activateCard(ActivateCardRequestModel request)`](../lib/features/activate_card/domain/repository/activate_card_repository.dart#L6) — ينفّذ منطق `activate card` داخل `ActivateCardRepository`.

### `features/activate_card/domain/usecases/activate_card_usecase.dart`

- [`class ActivateCardUseCase`](../lib/features/activate_card/domain/usecases/activate_card_usecase.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `activate card use case`.
- [`ActivateCardUseCase(this._repository)`](../lib/features/activate_card/domain/usecases/activate_card_usecase.dart#L9) — ينشئ كائنًا من `ActivateCardUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<Either<String, ActivateCardResponseModel>> call(ActivateCardRequestModel request)`](../lib/features/activate_card/domain/usecases/activate_card_usecase.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/activate_card/presentation/cubit/activate_card_cubit.dart`

- [`class ActivateCardCubit`](../lib/features/activate_card/presentation/cubit/activate_card_cubit.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `activate card cubit`.
- [`ActivateCardCubit(this._useCase)`](../lib/features/activate_card/presentation/cubit/activate_card_cubit.dart#L9) — ينشئ كائنًا من `ActivateCardCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> activateCard(ActivateCardRequestModel request)`](../lib/features/activate_card/presentation/cubit/activate_card_cubit.dart#L11) — ينفّذ منطق `activate card` داخل `ActivateCardCubit`.

### `features/activate_card/presentation/cubit/activate_card_state.dart`

- [`class ActivateCardState`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L3) — الكلاس الذي يدير حالة وتفاعلات `activate card state`.
- [`class ActivateCardInitial`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L5) — الكلاس الذي يدير حالة وتفاعلات `activate card initial`.
- [`class ActivateCardLoading`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `activate card loading`.
- [`class ActivateCardSuccess`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L9) — الكلاس الذي يدير حالة وتفاعلات `activate card success`.
- [`ActivateCardSuccess(this.response)`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L12) — ينشئ كائنًا من `ActivateCardSuccess` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class ActivateCardError`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L15) — الكلاس الذي يدير حالة وتفاعلات `activate card error`.
- [`ActivateCardError(this.message)`](../lib/features/activate_card/presentation/cubit/activate_card_state.dart#L18) — ينشئ كائنًا من `ActivateCardError` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activate_card/presentation/pages/activate_card_screen.dart`

- [`class ActivateCardScreen`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L19) — الكلاس الذي يمثل شاشة `activate card screen`.
- [`const ActivateCardScreen({super.key})`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L20) — ينشئ كائنًا من `ActivateCardScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ActivateCardScreen> createState()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L22) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ActivateCardScreenState`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L26) — **خاص** — الكلاس الذي يمثل شاشة `activate card screen state`.
- [`void initState()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L61) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L77) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onPasswordChanged()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L95) — **خاص** — يعالج حدث `on password changed` داخل `_ActivateCardScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L102) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildTextField({Key? fieldKey, required TextEditingController controller, required String hintText, String? fieldName, TextInputType? keyboardType, bool required = true, int? maxLength, TextCapitalization textCapitalization = TextCapitalization.none, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, ValueChanged<String>? onChanged})`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L449) — **خاص** — ينفّذ منطق `build text field` داخل `_ActivateCardScreenState`.
- [`Widget _buildPasswordField({Key? fieldKey, required TextEditingController controller, required String hintText, required bool obscure, required VoidCallback onToggle, String? fieldName, String? Function(String?)? validator})`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L497) — **خاص** — ينفّذ منطق `build password field` داخل `_ActivateCardScreenState`.
- [`Widget _buildPasswordRequirements()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L545) — **خاص** — ينفّذ منطق `build password requirements` داخل `_ActivateCardScreenState`.
- [`Widget _buildPasswordRequirement({required String label, required bool isMet, required bool showInvalid})`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L587) — **خاص** — ينفّذ منطق `build password requirement` داخل `_ActivateCardScreenState`.
- [`Widget _buildRequiredHint(String text)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L623) — **خاص** — ينفّذ منطق `build required hint` داخل `_ActivateCardScreenState`.
- [`Widget _buildBirthDatePicker(BuildContext context)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L650) — **خاص** — ينفّذ منطق `build birth date picker` داخل `_ActivateCardScreenState`.
- [`DateTime get _selectedBirthDate`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L705) — **خاص** — يغيّر الاختيار الخاص بـ `selected birth date` داخل `_ActivateCardScreenState`.
- [`DateTime? _parseBirthDate(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L710) — **خاص** — يحلّل `parse birth date` ويحوّله لصيغة قابلة للاستخدام داخل `_ActivateCardScreenState`.
- [`String? _validateFirstName(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L716) — **خاص** — يتحقق من صحة `validate first name` داخل `_ActivateCardScreenState`.
- [`String? _validateLastName(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L723) — **خاص** — يتحقق من صحة `validate last name` داخل `_ActivateCardScreenState`.
- [`String? _validateCardNumber(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L730) — **خاص** — يتحقق من صحة `validate card number` داخل `_ActivateCardScreenState`.
- [`String? _validatePhoneNumber(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L739) — **خاص** — يتحقق من صحة `validate phone number` داخل `_ActivateCardScreenState`.
- [`String? _validateNationalId(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L752) — **خاص** — يتحقق من صحة `validate national id` داخل `_ActivateCardScreenState`.
- [`String? _validatePassportNumber(String? value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L766) — **خاص** — يتحقق من صحة `validate passport number` داخل `_ActivateCardScreenState`.
- [`bool _isPasswordValid(String password)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L775) — **خاص** — يفحص شرط `is password valid` ويعيد النتيجة داخل `_ActivateCardScreenState`.
- [`bool _hasMinimumLength(String password)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L782) — **خاص** — يفحص شرط `has minimum length` ويعيد النتيجة داخل `_ActivateCardScreenState`.
- [`bool _hasLetter(String password)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L785) — **خاص** — يفحص شرط `has letter` ويعيد النتيجة داخل `_ActivateCardScreenState`.
- [`bool _hasNumber(String password)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L787) — **خاص** — يفحص شرط `has number` ويعيد النتيجة داخل `_ActivateCardScreenState`.
- [`bool _hasSpecialCharacter(String password)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L789) — **خاص** — يفحص شرط `has special character` ويعيد النتيجة داخل `_ActivateCardScreenState`.
- [`String _normalize(String value)`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L792) — **خاص** — ينفّذ منطق `normalize` داخل `_ActivateCardScreenState`.
- [`Widget _buildGenderSelector()`](../lib/features/activate_card/presentation/pages/activate_card_screen.dart#L798) — **خاص** — ينفّذ منطق `build gender selector` داخل `_ActivateCardScreenState`.


## Feature: activity

### `features/activity/data/data_source/invoice_remote_data_source.dart`

- [`class InvoiceRemoteDataSource`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L13) — الكلاس الذي يعرّف الاتصال بمصدر البيانات أو REST API.
- [`factory InvoiceRemoteDataSource(Dio dio, {String baseUrl})`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L15) — ينشئ كائنًا من `InvoiceRemoteDataSource` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<InvoicesResponseDto> getMyInvoices({@Header('Accept-Language') required String language, @Query('pageNumber') int pageNumber = 1, @Query('pageSize') int pageSize = 10, @Query('Tab') int? tab})`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L18) — يجلب `get my invoices` من مصدر البيانات المناسب داخل `InvoiceRemoteDataSource`.
- [`Future<CreateInvoiceResponseDto> createFromPackage(@Body() CreatePackageInvoiceRequestDto request)`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L26) — ينشئ أو يضيف `create from package` داخل `InvoiceRemoteDataSource`.
- [`Future<CreateInvoiceResponseDto> createFromCart(@Body() CreateCartInvoiceRequestDto request)`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L31) — ينشئ أو يضيف `create from cart` داخل `InvoiceRemoteDataSource`.
- [`Future<InvoiceDetailsResponseDto> getInvoiceDetails(@Path('invoiceId') int invoiceId)`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L36) — يجلب `get invoice details` من مصدر البيانات المناسب داخل `InvoiceRemoteDataSource`.
- [`Future<CreateInvoiceResponseDto> createReview(@Body() CreateReviewRequestDto request)`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L41) — ينشئ أو يضيف `create review` داخل `InvoiceRemoteDataSource`.
- [`Future<CreateInvoiceResponseDto> cancelInvoice(@Path('invoiceId') int invoiceId)`](../lib/features/activity/data/data_source/invoice_remote_data_source.dart#L46) — يفحص شرط `cancel invoice` ويعيد النتيجة داخل `InvoiceRemoteDataSource`.

### `features/activity/data/dto/create_cart_invoice_request_dto.dart`

- [`class CreateCartInvoiceRequestDto`](../lib/features/activity/data/dto/create_cart_invoice_request_dto.dart#L5) — الكلاس الذي يمثل بيانات `create cart invoice request dto` وينقلها بين الطبقات.
- [`const CreateCartInvoiceRequestDto({this.cardNumber, required this.isCash, required this.providerId, required this.providerBranchId, this.familyId})`](../lib/features/activity/data/dto/create_cart_invoice_request_dto.dart#L13) — ينشئ كائنًا من `CreateCartInvoiceRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CreateCartInvoiceRequestDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/create_cart_invoice_request_dto.dart#L21) — ينشئ كائنًا من `CreateCartInvoiceRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/create_cart_invoice_request_dto.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/dto/create_invoice_response_dto.dart`

- [`class CreateInvoiceResponseDto`](../lib/features/activity/data/dto/create_invoice_response_dto.dart#L5) — الكلاس الذي يمثل بيانات `create invoice response dto` وينقلها بين الطبقات.
- [`const CreateInvoiceResponseDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/activity/data/dto/create_invoice_response_dto.dart#L13) — ينشئ كائنًا من `CreateInvoiceResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CreateInvoiceResponseDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/create_invoice_response_dto.dart#L21) — ينشئ كائنًا من `CreateInvoiceResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/create_invoice_response_dto.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/dto/create_package_invoice_request_dto.dart`

- [`class CreatePackageInvoiceRequestDto`](../lib/features/activity/data/dto/create_package_invoice_request_dto.dart#L5) — الكلاس الذي يمثل بيانات `create package invoice request dto` وينقلها بين الطبقات.
- [`const CreatePackageInvoiceRequestDto({required this.packageId, required this.providerBranchId, required this.isCash, this.cardNumber})`](../lib/features/activity/data/dto/create_package_invoice_request_dto.dart#L12) — ينشئ كائنًا من `CreatePackageInvoiceRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CreatePackageInvoiceRequestDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/create_package_invoice_request_dto.dart#L19) — ينشئ كائنًا من `CreatePackageInvoiceRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/create_package_invoice_request_dto.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/dto/create_review_request_dto.dart`

- [`class CreateReviewRequestDto`](../lib/features/activity/data/dto/create_review_request_dto.dart#L1) — الكلاس الذي يمثل بيانات `create review request dto` وينقلها بين الطبقات.
- [`const CreateReviewRequestDto({required this.invoiceId, this.rating, this.ratingText})`](../lib/features/activity/data/dto/create_review_request_dto.dart#L6) — ينشئ كائنًا من `CreateReviewRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/create_review_request_dto.dart#L12) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/dto/invoice_details_response_dto.dart`

- [`class InvoiceDetailsResponseDto`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L1) — الكلاس الذي يمثل بيانات `invoice details response dto` وينقلها بين الطبقات.
- [`const InvoiceDetailsResponseDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L8) — ينشئ كائنًا من `InvoiceDetailsResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoiceDetailsResponseDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L16) — ينشئ كائنًا من `InvoiceDetailsResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceDetailsDto`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L29) — الكلاس الذي يمثل بيانات `invoice details dto` وينقلها بين الطبقات.
- [`const InvoiceDetailsDto({this.invoiceId, this.status, this.date, this.totalBefore, this.totalAfter, this.discountPercentage, this.familyId, this.familyFirstName, this.familyLastName, this.items})`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L41) — ينشئ كائنًا من `InvoiceDetailsDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoiceDetailsDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L54) — ينشئ كائنًا من `InvoiceDetailsDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceServiceItemsPageDto`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L74) — الكلاس الذي يمثل بيانات `invoice service items page dto` وينقلها بين الطبقات.
- [`const InvoiceServiceItemsPageDto({required this.items})`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L77) — ينشئ كائنًا من `InvoiceServiceItemsPageDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoiceServiceItemsPageDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L79) — ينشئ كائنًا من `InvoiceServiceItemsPageDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceServiceItemDto`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L92) — الكلاس الذي يمثل بيانات `invoice service item dto` وينقلها بين الطبقات.
- [`const InvoiceServiceItemDto({this.id, this.serviceName, this.serviceNameEn, this.priceBefore, this.priceAfter, this.discountPercentage})`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L100) — ينشئ كائنًا من `InvoiceServiceItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoiceServiceItemDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoice_details_response_dto.dart#L109) — ينشئ كائنًا من `InvoiceServiceItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/data/dto/invoice_item_dto.dart`

- [`class InvoiceItemDto`](../lib/features/activity/data/dto/invoice_item_dto.dart#L5) — الكلاس الذي يمثل بيانات `invoice item dto` وينقلها بين الطبقات.
- [`const InvoiceItemDto({this.invoiceId, this.providerName, this.branchName, this.status, this.date, this.providerImageUrl, this.isReviewed, this.isFromPackage, this.priceAfter, this.packagePrice, this.familyId, this.familyFirstName, this.familyLastName})`](../lib/features/activity/data/dto/invoice_item_dto.dart#L21) — ينشئ كائنًا من `InvoiceItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoiceItemDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoice_item_dto.dart#L37) — ينشئ كائنًا من `InvoiceItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/invoice_item_dto.dart#L40) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/dto/invoices_response_dto.dart`

- [`class InvoicesResponseDto`](../lib/features/activity/data/dto/invoices_response_dto.dart#L6) — الكلاس الذي يمثل بيانات `invoices response dto` وينقلها بين الطبقات.
- [`const InvoicesResponseDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/activity/data/dto/invoices_response_dto.dart#L14) — ينشئ كائنًا من `InvoicesResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoicesResponseDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoices_response_dto.dart#L22) — ينشئ كائنًا من `InvoicesResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/invoices_response_dto.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class InvoicesPageDto`](../lib/features/activity/data/dto/invoices_response_dto.dart#L28) — الكلاس الذي يمثل بيانات `invoices page dto` وينقلها بين الطبقات.
- [`const InvoicesPageDto({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/activity/data/dto/invoices_response_dto.dart#L36) — ينشئ كائنًا من `InvoicesPageDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory InvoicesPageDto.fromJson(Map<String, dynamic> json)`](../lib/features/activity/data/dto/invoices_response_dto.dart#L44) — ينشئ كائنًا من `InvoicesPageDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/activity/data/dto/invoices_response_dto.dart#L47) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/activity/data/repositories/invoice_repository_impl.dart`

- [`class InvoiceRepositoryImpl`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L18) — الكلاس الذي يمثل بيانات `invoice repository impl` وينقلها بين الطبقات.
- [`InvoiceRepositoryImpl(this._dataSource)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L21) — ينشئ كائنًا من `InvoiceRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool _isAmbiguousCreationError(Object error)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L23) — **خاص** — يفحص شرط `is ambiguous creation error` ويعيد النتيجة داخل `InvoiceRepositoryImpl`.
- [`String _failureMessage({dynamic errors, String? message, required String fallback})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L40) — **خاص** — ينفّذ منطق `failure message` داخل `InvoiceRepositoryImpl`.
- [`String? _readableError(dynamic errors)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L51) — **خاص** — ينفّذ منطق `readable error` داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<InvoicesPage>> getMyInvoices({int pageNumber = 1, int pageSize = 10, int? tab})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L70) — يجلب `get my invoices` من مصدر البيانات المناسب داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<CreatedInvoice>> createFromPackage({required int packageId, required int providerBranchId, bool isCash = true, String? cardNumber})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L148) — ينشئ أو يضيف `create from package` داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<CreatedInvoice>> createFromCart({required int providerId, required int providerBranchId, required bool isCash, int? familyId, String? cardNumber})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L186) — ينشئ أو يضيف `create from cart` داخل `InvoiceRepositoryImpl`.
- [`String? _beneficiaryName({String? firstName, String? lastName})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L226) — **خاص** — ينفّذ منطق `beneficiary name` داخل `InvoiceRepositoryImpl`.
- [`CreatedInvoice? _createdInvoiceFromData(dynamic data)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L233) — **خاص** — ينشئ أو يضيف `created invoice from data` داخل `InvoiceRepositoryImpl`.
- [`String? _validInvoiceId(dynamic value)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L259) — **خاص** — ينفّذ منطق `valid invoice id` داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L269) — يجلب `get invoice details` من مصدر البيانات المناسب داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<void>> createReview({required int invoiceId, int? rating, String? ratingText})`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L314) — ينشئ أو يضيف `create review` داخل `InvoiceRepositoryImpl`.
- [`Future<ApiResult<void>> cancelInvoice(int invoiceId)`](../lib/features/activity/data/repositories/invoice_repository_impl.dart#L345) — يفحص شرط `cancel invoice` ويعيد النتيجة داخل `InvoiceRepositoryImpl`.

### `features/activity/domain/models/created_invoice.dart`

- [`class CreatedInvoice`](../lib/features/activity/domain/models/created_invoice.dart#L1) — الكلاس الذي يمثل بيانات `created invoice` وينقلها بين الطبقات.
- [`const CreatedInvoice({required this.invoiceId, this.paymentLink})`](../lib/features/activity/domain/models/created_invoice.dart#L5) — ينشئ كائنًا من `CreatedInvoice` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/domain/models/invoice_details.dart`

- [`class InvoiceDetails`](../lib/features/activity/domain/models/invoice_details.dart#L1) — الكلاس الذي يمثل بيانات `invoice details` وينقلها بين الطبقات.
- [`const InvoiceDetails({required this.invoiceId, required this.status, required this.date, required this.totalBefore, required this.totalAfter, required this.discountPercentage, this.beneficiaryName, required this.services})`](../lib/features/activity/domain/models/invoice_details.dart#L11) — ينشئ كائنًا من `InvoiceDetails` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceServiceItem`](../lib/features/activity/domain/models/invoice_details.dart#L23) — الكلاس الذي يمثل بيانات `invoice service item` وينقلها بين الطبقات.
- [`const InvoiceServiceItem({required this.id, required this.serviceName, required this.priceBefore, required this.priceAfter, required this.discountPercentage})`](../lib/features/activity/domain/models/invoice_details.dart#L30) — ينشئ كائنًا من `InvoiceServiceItem` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/domain/models/invoice_item.dart`

- [`class InvoiceItem`](../lib/features/activity/domain/models/invoice_item.dart#L1) — الكلاس الذي يمثل بيانات `invoice item` وينقلها بين الطبقات.
- [`bool get isPending`](../lib/features/activity/domain/models/invoice_item.dart#L14) — يفحص شرط `is pending` ويعيد النتيجة داخل `InvoiceItem`.
- [`bool get isPaid`](../lib/features/activity/domain/models/invoice_item.dart#L19) — يفحص شرط `is paid` ويعيد النتيجة داخل `InvoiceItem`.
- [`bool get isUsed`](../lib/features/activity/domain/models/invoice_item.dart#L24) — يفحص شرط `is used` ويعيد النتيجة داخل `InvoiceItem`.
- [`bool get isCancelled`](../lib/features/activity/domain/models/invoice_item.dart#L29) — يفحص شرط `is cancelled` ويعيد النتيجة داخل `InvoiceItem`.
- [`const InvoiceItem({required this.invoiceId, required this.providerName, required this.branchName, required this.status, required this.date, this.providerImageUrl, this.isReviewed = false, this.isFromPackage = false, this.priceAfter, this.packagePrice, this.beneficiaryName})`](../lib/features/activity/domain/models/invoice_item.dart#L34) — ينشئ كائنًا من `InvoiceItem` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/domain/models/invoices_page.dart`

- [`class InvoicesPage`](../lib/features/activity/domain/models/invoices_page.dart#L3) — الكلاس الذي يمثل بيانات `invoices page` وينقلها بين الطبقات.
- [`const InvoicesPage({required this.items, required this.pageNumber, required this.pageSize, required this.totalCount, required this.totalPages})`](../lib/features/activity/domain/models/invoices_page.dart#L10) — ينشئ كائنًا من `InvoicesPage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get hasMore`](../lib/features/activity/domain/models/invoices_page.dart#L18) — يفحص شرط `has more` ويعيد النتيجة داخل `InvoicesPage`.

### `features/activity/domain/repositories/invoice_repository.dart`

- [`class InvoiceRepository`](../lib/features/activity/domain/repositories/invoice_repository.dart#L8) — الكلاس الذي يجمع مسؤوليات `invoice repository`.
- [`Future<ApiResult<InvoicesPage>> getMyInvoices({int pageNumber = 1, int pageSize = 10, int? tab})`](../lib/features/activity/domain/repositories/invoice_repository.dart#L22) — يجلب `get my invoices` من مصدر البيانات المناسب داخل `InvoiceRepository`.
- [`Future<ApiResult<CreatedInvoice>> createFromPackage({required int packageId, required int providerBranchId, bool isCash = true, String? cardNumber})`](../lib/features/activity/domain/repositories/invoice_repository.dart#L28) — ينشئ أو يضيف `create from package` داخل `InvoiceRepository`.
- [`Future<ApiResult<CreatedInvoice>> createFromCart({required int providerId, required int providerBranchId, required bool isCash, int? familyId, String? cardNumber})`](../lib/features/activity/domain/repositories/invoice_repository.dart#L35) — ينشئ أو يضيف `create from cart` داخل `InvoiceRepository`.
- [`Future<ApiResult<InvoiceDetails>> getInvoiceDetails(int invoiceId)`](../lib/features/activity/domain/repositories/invoice_repository.dart#L43) — يجلب `get invoice details` من مصدر البيانات المناسب داخل `InvoiceRepository`.
- [`Future<ApiResult<void>> createReview({required int invoiceId, int? rating, String? ratingText})`](../lib/features/activity/domain/repositories/invoice_repository.dart#L45) — ينشئ أو يضيف `create review` داخل `InvoiceRepository`.
- [`Future<ApiResult<void>> cancelInvoice(int invoiceId)`](../lib/features/activity/domain/repositories/invoice_repository.dart#L51) — يفحص شرط `cancel invoice` ويعيد النتيجة داخل `InvoiceRepository`.

### `features/activity/domain/usecases/cancel_invoice_usecase.dart`

- [`class CancelInvoiceUseCase`](../lib/features/activity/domain/usecases/cancel_invoice_usecase.dart#L4) — الكلاس الذي يعزل عملية أعمال واحدة: `cancel invoice use case`.
- [`CancelInvoiceUseCase(this._repository)`](../lib/features/activity/domain/usecases/cancel_invoice_usecase.dart#L7) — ينشئ كائنًا من `CancelInvoiceUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<void>> call(int invoiceId)`](../lib/features/activity/domain/usecases/cancel_invoice_usecase.dart#L9) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/activity/domain/usecases/create_review_usecase.dart`

- [`class CreateReviewUseCase`](../lib/features/activity/domain/usecases/create_review_usecase.dart#L4) — الكلاس الذي يعزل عملية أعمال واحدة: `create review use case`.
- [`CreateReviewUseCase(this._repository)`](../lib/features/activity/domain/usecases/create_review_usecase.dart#L7) — ينشئ كائنًا من `CreateReviewUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<void>> call({required int invoiceId, int? rating, String? ratingText})`](../lib/features/activity/domain/usecases/create_review_usecase.dart#L9) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/activity/domain/usecases/get_invoice_details_usecase.dart`

- [`class GetInvoiceDetailsUseCase`](../lib/features/activity/domain/usecases/get_invoice_details_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get invoice details use case`.
- [`GetInvoiceDetailsUseCase(this._repository)`](../lib/features/activity/domain/usecases/get_invoice_details_usecase.dart#L8) — ينشئ كائنًا من `GetInvoiceDetailsUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<InvoiceDetails>> call(int invoiceId)`](../lib/features/activity/domain/usecases/get_invoice_details_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/activity/presentation/cubit/activity_cubit.dart`

- [`class ActivityCubit`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L8) — الكلاس الذي يدير حالة وتفاعلات `activity cubit`.
- [`ActivityCubit(this._repository)`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L20) — ينشئ كائنًا من `ActivityCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadInvoices({int tab = 1, bool forceRefresh = false})`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L22) — يحمّل `load invoices` ويحدّث الحالة المرتبطة داخل `ActivityCubit`.
- [`Future<void> loadMore()`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L38) — يحمّل `load more` ويحدّث الحالة المرتبطة داخل `ActivityCubit`.
- [`Future<void> _performLoadInvoices({required int tab})`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L59) — **خاص** — ينفّذ منطق `perform load invoices` داخل `ActivityCubit`.
- [`Future<void> _performLoadMore()`](../lib/features/activity/presentation/cubit/activity_cubit.dart#L96) — **خاص** — ينفّذ منطق `perform load more` داخل `ActivityCubit`.

### `features/activity/presentation/cubit/activity_state.dart`

- [`class ActivityState`](../lib/features/activity/presentation/cubit/activity_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `activity state`.
- [`const factory ActivityState.initial()`](../lib/features/activity/presentation/cubit/activity_state.dart#L8) — ينشئ كائنًا من `ActivityState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ActivityState.loading()`](../lib/features/activity/presentation/cubit/activity_state.dart#L9) — ينشئ كائنًا من `ActivityState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ActivityState.success({required List<InvoiceItem> invoices, @Default(false) bool isLoadingMore, @Default(false) bool hasMore})`](../lib/features/activity/presentation/cubit/activity_state.dart#L10) — ينشئ كائنًا من `ActivityState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ActivityState.failure(String error)`](../lib/features/activity/presentation/cubit/activity_state.dart#L15) — ينشئ كائنًا من `ActivityState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/presentation/cubit/invoice_details_cubit.dart`

- [`class InvoiceDetailsCubit`](../lib/features/activity/presentation/cubit/invoice_details_cubit.dart#L12) — الكلاس الذي يدير حالة وتفاعلات `invoice details cubit`.
- [`InvoiceDetailsCubit(this._getInvoiceDetails, this._cancelInvoice, this._createReview)`](../lib/features/activity/presentation/cubit/invoice_details_cubit.dart#L17) — ينشئ كائنًا من `InvoiceDetailsCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadDetails(int invoiceId)`](../lib/features/activity/presentation/cubit/invoice_details_cubit.dart#L23) — يحمّل `load details` ويحدّث الحالة المرتبطة داخل `InvoiceDetailsCubit`.
- [`Future<String?> cancelInvoice(int invoiceId)`](../lib/features/activity/presentation/cubit/invoice_details_cubit.dart#L39) — يفحص شرط `cancel invoice` ويعيد النتيجة داخل `InvoiceDetailsCubit`.
- [`Future<String?> submitReview({required int invoiceId, int? rating, String? ratingText})`](../lib/features/activity/presentation/cubit/invoice_details_cubit.dart#L63) — يرسل `submit review` إلى الطبقة أو الخدمة المطلوبة داخل `InvoiceDetailsCubit`.

### `features/activity/presentation/cubit/invoice_details_state.dart`

- [`class InvoiceDetailsState`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L3) — الكلاس الذي يدير حالة وتفاعلات `invoice details state`.
- [`const InvoiceDetailsState()`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L4) — ينشئ كائنًا من `InvoiceDetailsState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceDetailsInitial`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `invoice details initial`.
- [`const InvoiceDetailsInitial()`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L8) — ينشئ كائنًا من `InvoiceDetailsInitial` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceDetailsLoading`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L11) — الكلاس الذي يدير حالة وتفاعلات `invoice details loading`.
- [`const InvoiceDetailsLoading()`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L12) — ينشئ كائنًا من `InvoiceDetailsLoading` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceDetailsLoaded`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L15) — الكلاس الذي يدير حالة وتفاعلات `invoice details loaded`.
- [`const InvoiceDetailsLoaded(this.details)`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L18) — ينشئ كائنًا من `InvoiceDetailsLoaded` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class InvoiceDetailsLoadFailure`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L21) — الكلاس الذي يدير حالة وتفاعلات `invoice details load failure`.
- [`const InvoiceDetailsLoadFailure(this.message)`](../lib/features/activity/presentation/cubit/invoice_details_state.dart#L24) — ينشئ كائنًا من `InvoiceDetailsLoadFailure` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/activity/presentation/pages/invoice_details_screen.dart`

- [`class InvoiceDetailsScreen`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L18) — الكلاس الذي يمثل شاشة `invoice details screen`.
- [`const InvoiceDetailsScreen({super.key, required this.invoice, this.tab = 0})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L22) — ينشئ كائنًا من `InvoiceDetailsScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L24) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _DetailsBody`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L105) — **خاص** — الكلاس الذي يمثل شاشة `details body`.
- [`const _DetailsBody({required this.invoice, required this.details, required this.tab})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L110) — **خاص** — ينشئ كائنًا من `DetailsBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L112) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _servicesText(List<InvoiceServiceItem> services)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L184) — **خاص** — ينفّذ منطق `services text` داخل `_DetailsBody`.
- [`class _StatusBadge`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L190) — **خاص** — الكلاس الذي يمثل شاشة `status badge`.
- [`const _StatusBadge({required this.status})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L193) — **خاص** — ينشئ كائنًا من `StatusBadge` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L195) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ProviderHeader`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L225) — **خاص** — الكلاس الذي يمثل شاشة `provider header`.
- [`const _ProviderHeader({required this.invoice})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L228) — **خاص** — ينشئ كائنًا من `ProviderHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L230) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _InfoCard`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L288) — **خاص** — الكلاس الذي يمثل شاشة `info card`.
- [`const _InfoCard({required this.children})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L291) — **خاص** — ينشئ كائنًا من `InfoCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L293) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _InfoRow`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L306) — **خاص** — الكلاس الذي يمثل شاشة `info row`.
- [`const _InfoRow({required this.label, required this.value, this.valueColor, this.isBold = false})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L312) — **خاص** — ينشئ كائنًا من `InfoRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L319) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _DetailsActions`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L356) — **خاص** — الكلاس الذي يمثل شاشة `details actions`.
- [`const _DetailsActions({required this.invoice, required this.details, required this.tab})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L361) — **خاص** — ينشئ كائنًا من `DetailsActions` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_DetailsActions> createState()`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L363) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _DetailsActionsState`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L367) — **خاص** — الكلاس الذي يمثل شاشة `details actions state`.
- [`bool get _canCancel`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L371) — **خاص** — يفحص شرط `can cancel` ويعيد النتيجة داخل `_DetailsActionsState`.
- [`bool get _canReview`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L377) — **خاص** — يفحص شرط `can review` ويعيد النتيجة داخل `_DetailsActionsState`.
- [`Future<void> _onCancelTapped()`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L382) — **خاص** — يعالج حدث `on cancel tapped` داخل `_DetailsActionsState`.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L488) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ReviewDialog`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L559) — **خاص** — الكلاس الذي يمثل شاشة `review dialog`.
- [`const _ReviewDialog({required this.invoiceId})`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L562) — **خاص** — ينشئ كائنًا من `ReviewDialog` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_ReviewDialog> createState()`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L564) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ReviewDialogState`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L568) — **خاص** — الكلاس الذي يمثل شاشة `review dialog state`.
- [`void dispose()`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L574) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Future<void> _submit()`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L580) — **خاص** — يرسل `submit` إلى الطبقة أو الخدمة المطلوبة داخل `_ReviewDialogState`.
- [`Widget build(BuildContext context)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L606) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _money(double value)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L695) — **خاص** — ينفّذ منطق `money` داخل هذا الملف.
- [`double _discountPercent(InvoiceDetails details)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L699) — **خاص** — ينفّذ منطق `discount percent` داخل هذا الملف.
- [`String _localizedStatus(String status)`](../lib/features/activity/presentation/pages/invoice_details_screen.dart#L709) — **خاص** — ينفّذ منطق `localized status` داخل هذا الملف.


## Feature: auth

### `features/auth/data/models/otp_response_model.dart`

- [`class OtpResponseModel`](../lib/features/auth/data/models/otp_response_model.dart#L5) — الكلاس الذي يمثل بيانات `otp response model` وينقلها بين الطبقات.
- [`const OtpResponseModel({this.httpStatusCode, this.errors, required this.succeeded, this.message, this.data})`](../lib/features/auth/data/models/otp_response_model.dart#L19) — ينشئ كائنًا من `OtpResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory OtpResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/auth/data/models/otp_response_model.dart#L27) — ينشئ كائنًا من `OtpResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/auth/data/models/otp_response_model.dart#L30) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`Object? _readSucceeded(Map<dynamic, dynamic> json, String key)`](../lib/features/auth/data/models/otp_response_model.dart#L33) — **خاص** — ينفّذ منطق `read succeeded` داخل هذا الملف.

### `features/auth/data/models/reset_password_request_model.dart`

- [`class ResetPasswordRequestModel`](../lib/features/auth/data/models/reset_password_request_model.dart#L5) — الكلاس الذي يمثل بيانات `reset password request model` وينقلها بين الطبقات.
- [`const ResetPasswordRequestModel({required this.phoneNumber, required this.password, required this.confirmPassword})`](../lib/features/auth/data/models/reset_password_request_model.dart#L11) — ينشئ كائنًا من `ResetPasswordRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json)`](../lib/features/auth/data/models/reset_password_request_model.dart#L17) — ينشئ كائنًا من `ResetPasswordRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/auth/data/models/reset_password_request_model.dart#L20) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/auth/data/models/send_otp_request_model.dart`

- [`class SendOtpRequestModel`](../lib/features/auth/data/models/send_otp_request_model.dart#L5) — الكلاس الذي يمثل بيانات `send otp request model` وينقلها بين الطبقات.
- [`const SendOtpRequestModel({required this.phoneNumber})`](../lib/features/auth/data/models/send_otp_request_model.dart#L9) — ينشئ كائنًا من `SendOtpRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory SendOtpRequestModel.fromJson(Map<String, dynamic> json)`](../lib/features/auth/data/models/send_otp_request_model.dart#L11) — ينشئ كائنًا من `SendOtpRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/auth/data/models/send_otp_request_model.dart#L14) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/auth/data/models/verify_otp_request_model.dart`

- [`class VerifyOtpRequestModel`](../lib/features/auth/data/models/verify_otp_request_model.dart#L5) — الكلاس الذي يمثل بيانات `verify otp request model` وينقلها بين الطبقات.
- [`const VerifyOtpRequestModel({required this.phoneNumber, required this.otp})`](../lib/features/auth/data/models/verify_otp_request_model.dart#L10) — ينشئ كائنًا من `VerifyOtpRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json)`](../lib/features/auth/data/models/verify_otp_request_model.dart#L12) — ينشئ كائنًا من `VerifyOtpRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/auth/data/models/verify_otp_request_model.dart#L15) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/auth/domain/usecases/reset_password_usecase.dart`

- [`class ResetPasswordUseCase`](../lib/features/auth/domain/usecases/reset_password_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `reset password use case`.
- [`ResetPasswordUseCase(this._repository)`](../lib/features/auth/domain/usecases/reset_password_usecase.dart#L8) — ينشئ كائنًا من `ResetPasswordUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<OtpResponseModel>> call({required String phoneNumber, required String password, required String confirmPassword})`](../lib/features/auth/domain/usecases/reset_password_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/auth/domain/usecases/send_otp_usecase.dart`

- [`class SendOtpUseCase`](../lib/features/auth/domain/usecases/send_otp_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `send otp use case`.
- [`SendOtpUseCase(this._repository)`](../lib/features/auth/domain/usecases/send_otp_usecase.dart#L8) — ينشئ كائنًا من `SendOtpUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<OtpResponseModel>> call(String phoneNumber)`](../lib/features/auth/domain/usecases/send_otp_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/auth/domain/usecases/verify_otp_usecase.dart`

- [`class VerifyOtpUseCase`](../lib/features/auth/domain/usecases/verify_otp_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `verify otp use case`.
- [`VerifyOtpUseCase(this._repository)`](../lib/features/auth/domain/usecases/verify_otp_usecase.dart#L8) — ينشئ كائنًا من `VerifyOtpUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<OtpResponseModel>> call({required String phoneNumber, required String otp})`](../lib/features/auth/domain/usecases/verify_otp_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/auth/presentation/cubit/forgot_password_cubit.dart`

- [`class ForgotPasswordCubit`](../lib/features/auth/presentation/cubit/forgot_password_cubit.dart#L10) — الكلاس الذي يدير حالة وتفاعلات `forgot password cubit`.
- [`ForgotPasswordCubit(this._sendOtpUseCase, this._verifyOtpUseCase, this._resetPasswordUseCase)`](../lib/features/auth/presentation/cubit/forgot_password_cubit.dart#L15) — ينشئ كائنًا من `ForgotPasswordCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> sendOtp(String phoneNumber)`](../lib/features/auth/presentation/cubit/forgot_password_cubit.dart#L21) — يرسل `send otp` إلى الطبقة أو الخدمة المطلوبة داخل `ForgotPasswordCubit`.
- [`Future<void> verifyOtp({required String phoneNumber, required String otp})`](../lib/features/auth/presentation/cubit/forgot_password_cubit.dart#L50) — ينفّذ منطق `verify otp` داخل `ForgotPasswordCubit`.
- [`Future<void> resetPassword({required String phoneNumber, required String password, required String confirmPassword})`](../lib/features/auth/presentation/cubit/forgot_password_cubit.dart#L85) — ينفّذ منطق `reset password` داخل `ForgotPasswordCubit`.

### `features/auth/presentation/cubit/forgot_password_state.dart`

- [`class ForgotPasswordState`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L5) — الكلاس الذي يدير حالة وتفاعلات `forgot password state`.
- [`const factory ForgotPasswordState.initial()`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L7) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ForgotPasswordState.loading()`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L8) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ForgotPasswordState.otpSent(String phoneNumber, String otp)`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L9) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ForgotPasswordState.otpVerified(String phoneNumber, String token)`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L11) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ForgotPasswordState.resetSuccess()`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L15) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ForgotPasswordState.failed(String error)`](../lib/features/auth/presentation/cubit/forgot_password_state.dart#L16) — ينشئ كائنًا من `ForgotPasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/auth/presentation/screens/forgot_password_screen.dart`

- [`class ForgotPasswordScreen`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L16) — الكلاس الذي يمثل شاشة `forgot password screen`.
- [`const ForgotPasswordScreen({super.key})`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L17) — ينشئ كائنًا من `ForgotPasswordScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ForgotPasswordScreen> createState()`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L19) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ForgotPasswordScreenState`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L23) — **خاص** — الكلاس الذي يمثل شاشة `forgot password screen state`.
- [`void initState()`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L29) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L39) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onSendOtpPressed(BuildContext context)`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L46) — **خاص** — يعالج حدث `on send otp pressed` داخل `_ForgotPasswordScreenState`.
- [`bool _isAccountExistsInfoMessage(String message)`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L55) — **خاص** — يفحص شرط `is account exists info message` ويعيد النتيجة داخل `_ForgotPasswordScreenState`.
- [`String? _validatePhone(String? value)`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L65) — **خاص** — يتحقق من صحة `validate phone` داخل `_ForgotPasswordScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/auth/presentation/screens/forgot_password_screen.dart#L76) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/auth/presentation/screens/otp_verification_screen.dart`

- [`class OtpVerificationScreen`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L20) — الكلاس الذي يمثل شاشة `otp verification screen`.
- [`const OtpVerificationScreen({super.key, required this.phoneNumber, required this.otp})`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L24) — ينشئ كائنًا من `OtpVerificationScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<OtpVerificationScreen> createState()`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L30) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _OtpVerificationScreenState`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L34) — **خاص** — الكلاس الذي يمثل شاشة `otp verification screen state`.
- [`void initState()`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L47) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L60) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _startCountdown()`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L68) — **خاص** — ينفّذ منطق `start countdown` داخل `_OtpVerificationScreenState`.
- [`void _startResendCooldown()`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L84) — **خاص** — ينفّذ منطق `start resend cooldown` داخل `_OtpVerificationScreenState`.
- [`void _restartCountdown(String otp)`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L88) — **خاص** — ينفّذ منطق `restart countdown` داخل `_OtpVerificationScreenState`.
- [`void _onVerifyPressed(BuildContext context)`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L98) — **خاص** — يعالج حدث `on verify pressed` داخل `_OtpVerificationScreenState`.
- [`String? _validateOtp(String? value)`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L110) — **خاص** — يتحقق من صحة `validate otp` داخل `_OtpVerificationScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L119) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _OtpPreviewCard`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L257) — **خاص** — الكلاس الذي يمثل شاشة `otp preview card`.
- [`const _OtpPreviewCard({required this.otp, required this.secondsLeft})`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L261) — **خاص** — ينشئ كائنًا من `OtpPreviewCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/auth/presentation/screens/otp_verification_screen.dart#L263) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/auth/presentation/screens/reset_password_screen.dart`

- [`class ResetPasswordScreen`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L15) — الكلاس الذي يمثل شاشة `reset password screen`.
- [`const ResetPasswordScreen({super.key, required this.phoneNumber, required this.token})`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L19) — ينشئ كائنًا من `ResetPasswordScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ResetPasswordScreen> createState()`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L25) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ResetPasswordScreenState`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L29) — **خاص** — الكلاس الذي يمثل شاشة `reset password screen state`.
- [`void initState()`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L41) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onPasswordChanged()`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L51) — **خاص** — يعالج حدث `on password changed` داخل `_ResetPasswordScreenState`.
- [`void dispose()`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L58) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onResetPressed(BuildContext context)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L69) — **خاص** — يعالج حدث `on reset pressed` داخل `_ResetPasswordScreenState`.
- [`bool _hasMinimumLength(String password)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L79) — **خاص** — يفحص شرط `has minimum length` ويعيد النتيجة داخل `_ResetPasswordScreenState`.
- [`bool _hasLetter(String password)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L82) — **خاص** — يفحص شرط `has letter` ويعيد النتيجة داخل `_ResetPasswordScreenState`.
- [`bool _hasNumber(String password)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L84) — **خاص** — يفحص شرط `has number` ويعيد النتيجة داخل `_ResetPasswordScreenState`.
- [`bool _hasSpecialCharacter(String password)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L86) — **خاص** — يفحص شرط `has special character` ويعيد النتيجة داخل `_ResetPasswordScreenState`.
- [`bool _isPasswordValid(String password)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L89) — **خاص** — يفحص شرط `is password valid` ويعيد النتيجة داخل `_ResetPasswordScreenState`.
- [`String? _validatePassword(String? value)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L96) — **خاص** — يتحقق من صحة `validate password` داخل `_ResetPasswordScreenState`.
- [`String? _validateConfirm(String? value)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L105) — **خاص** — يتحقق من صحة `validate confirm` داخل `_ResetPasswordScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L114) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildPasswordRequirements()`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L244) — **خاص** — ينفّذ منطق `build password requirements` داخل `_ResetPasswordScreenState`.
- [`Widget _buildPasswordRequirement({required String label, required bool isMet, required bool showInvalid})`](../lib/features/auth/presentation/screens/reset_password_screen.dart#L286) — **خاص** — ينفّذ منطق `build password requirement` داخل `_ResetPasswordScreenState`.


## Feature: cart

### `features/cart/data/api/cart_remote_data_source.dart`

- [`class CartRemoteDataSource`](../lib/features/cart/data/api/cart_remote_data_source.dart#L13) — الكلاس الذي يعرّف الاتصال بمصدر البيانات أو REST API.
- [`factory CartRemoteDataSource(Dio dio, {String baseUrl})`](../lib/features/cart/data/api/cart_remote_data_source.dart#L15) — ينشئ كائنًا من `CartRemoteDataSource` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<CartDto> getCart(@Header('Authorization') String token)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L18) — يجلب `get cart` من مصدر البيانات المناسب داخل `CartRemoteDataSource`.
- [`Future<UpdateCartProviderResponseDto> addToCart(@Header('Authorization') String token, @Body() AddCartRequestDto request)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L21) — ينشئ أو يضيف `add to cart` داخل `CartRemoteDataSource`.
- [`Future<UpdateCartProviderResponseDto> removeFromCart(@Header('Authorization') String token, @Query('ServiceId') int serviceId)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L27) — يحذف أو يمسح `remove from cart` داخل `CartRemoteDataSource`.
- [`Future<CategoryServicesDto> getCategoryServices(@Header('Authorization') String token, @Path('categoryId') int categoryId)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L33) — يجلب `get category services` من مصدر البيانات المناسب داخل `CartRemoteDataSource`.
- [`Future<UpdateCartProviderResponseDto> clearCart(@Header('Authorization') String token)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L39) — يحذف أو يمسح `clear cart` داخل `CartRemoteDataSource`.
- [`Future<ChooseProvidersDto> getChooseProviders(@Header('Authorization') String token)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L44) — يجلب `get choose providers` من مصدر البيانات المناسب داخل `CartRemoteDataSource`.
- [`Future<UpdateCartProviderResponseDto> updateCartProvider(@Header('Authorization') String token, @Body() UpdateCartProviderRequestDto request)`](../lib/features/cart/data/api/cart_remote_data_source.dart#L49) — يحدّث `update cart provider` داخل `CartRemoteDataSource`.

### `features/cart/data/dto/add_cart_request_dto.dart`

- [`class AddCartRequestDto`](../lib/features/cart/data/dto/add_cart_request_dto.dart#L5) — الكلاس الذي يمثل بيانات `add cart request dto` وينقلها بين الطبقات.
- [`const AddCartRequestDto({required this.serviceId, required this.categoryId, this.providerId, this.cardNumber, this.price})`](../lib/features/cart/data/dto/add_cart_request_dto.dart#L13) — ينشئ كائنًا من `AddCartRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AddCartRequestDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/add_cart_request_dto.dart#L21) — ينشئ كائنًا من `AddCartRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/add_cart_request_dto.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/cart_dto.dart`

- [`class CartDto`](../lib/features/cart/data/dto/cart_dto.dart#L7) — الكلاس الذي يمثل بيانات `cart dto` وينقلها بين الطبقات.
- [`const CartDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/cart/data/dto/cart_dto.dart#L15) — ينشئ كائنًا من `CartDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CartDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/cart_dto.dart#L23) — ينشئ كائنًا من `CartDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/cart_dto.dart#L34) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`List<String>? _stringList(dynamic value)`](../lib/features/cart/data/dto/cart_dto.dart#L37) — **خاص** — ينفّذ منطق `string list` داخل هذا الملف.
- [`class CartDataDto`](../lib/features/cart/data/dto/cart_dto.dart#L43) — الكلاس الذي يمثل بيانات `cart data dto` وينقلها بين الطبقات.
- [`const CartDataDto({this.items, this.totalCount, this.categoryCounters})`](../lib/features/cart/data/dto/cart_dto.dart#L49) — ينشئ كائنًا من `CartDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CartDataDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/cart_dto.dart#L51) — ينشئ كائنًا من `CartDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/cart_dto.dart#L54) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/cart_item_dto.dart`

- [`class CartItemDto`](../lib/features/cart/data/dto/cart_item_dto.dart#L5) — الكلاس الذي يمثل بيانات `cart item dto` وينقلها بين الطبقات.
- [`const CartItemDto({this.cartItemId, this.serviceId, this.serviceName, this.categoryId, this.categoryName, this.providerId, this.providerName, this.priceAfter, this.priceBefore, this.discountPercentage})`](../lib/features/cart/data/dto/cart_item_dto.dart#L18) — ينشئ كائنًا من `CartItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CartItemDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/cart_item_dto.dart#L31) — ينشئ كائنًا من `CartItemDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/cart_item_dto.dart#L34) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/category_counter_dto.dart`

- [`class CategoryCounterDto`](../lib/features/cart/data/dto/category_counter_dto.dart#L5) — الكلاس الذي يمثل بيانات `category counter dto` وينقلها بين الطبقات.
- [`const CategoryCounterDto({this.categoryId, this.categoryName, this.count})`](../lib/features/cart/data/dto/category_counter_dto.dart#L11) — ينشئ كائنًا من `CategoryCounterDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryCounterDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/category_counter_dto.dart#L17) — ينشئ كائنًا من `CategoryCounterDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/category_counter_dto.dart#L20) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/category_service_dto.dart`

- [`class CategoryServiceDto`](../lib/features/cart/data/dto/category_service_dto.dart#L5) — الكلاس الذي يمثل بيانات `category service dto` وينقلها بين الطبقات.
- [`const CategoryServiceDto({this.serviceId, this.serviceNameEn, this.serviceNameAr, this.isSelected})`](../lib/features/cart/data/dto/category_service_dto.dart#L12) — ينشئ كائنًا من `CategoryServiceDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String? get serviceName`](../lib/features/cart/data/dto/category_service_dto.dart#L19) — ينفّذ منطق `service name` داخل `CategoryServiceDto`.
- [`factory CategoryServiceDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/category_service_dto.dart#L29) — ينشئ كائنًا من `CategoryServiceDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/category_service_dto.dart#L32) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/category_services_dto.dart`

- [`class CategoryServicesDto`](../lib/features/cart/data/dto/category_services_dto.dart#L6) — الكلاس الذي يمثل بيانات `category services dto` وينقلها بين الطبقات.
- [`const CategoryServicesDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/cart/data/dto/category_services_dto.dart#L15) — ينشئ كائنًا من `CategoryServicesDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryServicesDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/category_services_dto.dart#L23) — ينشئ كائنًا من `CategoryServicesDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/category_services_dto.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CategoryServicesDataDto`](../lib/features/cart/data/dto/category_services_dto.dart#L29) — الكلاس الذي يمثل بيانات `category services data dto` وينقلها بين الطبقات.
- [`const CategoryServicesDataDto({this.categoryId, this.categoryName, this.services, this.totalSelectedCount})`](../lib/features/cart/data/dto/category_services_dto.dart#L50) — ينشئ كائنًا من `CategoryServicesDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`List<CategoryServiceDto> get items`](../lib/features/cart/data/dto/category_services_dto.dart#L57) — ينفّذ منطق `items` داخل `CategoryServicesDataDto`.
- [`factory CategoryServicesDataDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/category_services_dto.dart#L60) — ينشئ كائنًا من `CategoryServicesDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/category_services_dto.dart#L63) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CategoryServicesItemsWrapperDto`](../lib/features/cart/data/dto/category_services_dto.dart#L66) — الكلاس الذي يمثل بيانات `category services items wrapper dto` وينقلها بين الطبقات.
- [`const CategoryServicesItemsWrapperDto({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/cart/data/dto/category_services_dto.dart#L75) — ينشئ كائنًا من `CategoryServicesItemsWrapperDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryServicesItemsWrapperDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/category_services_dto.dart#L83) — ينشئ كائنًا من `CategoryServicesItemsWrapperDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/category_services_dto.dart#L86) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/choose_providers_dto.dart`

- [`class ChooseProvidersDto`](../lib/features/cart/data/dto/choose_providers_dto.dart#L6) — الكلاس الذي يمثل بيانات `choose providers dto` وينقلها بين الطبقات.
- [`const ChooseProvidersDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/cart/data/dto/choose_providers_dto.dart#L14) — ينشئ كائنًا من `ChooseProvidersDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ChooseProvidersDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/choose_providers_dto.dart#L22) — ينشئ كائنًا من `ChooseProvidersDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/choose_providers_dto.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ChooseProvidersDataDto`](../lib/features/cart/data/dto/choose_providers_dto.dart#L29) — الكلاس الذي يمثل بيانات `choose providers data dto` وينقلها بين الطبقات.
- [`const ChooseProvidersDataDto({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/cart/data/dto/choose_providers_dto.dart#L37) — ينشئ كائنًا من `ChooseProvidersDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ChooseProvidersDataDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/choose_providers_dto.dart#L45) — ينشئ كائنًا من `ChooseProvidersDataDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/choose_providers_dto.dart#L48) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderOptionDto`](../lib/features/cart/data/dto/choose_providers_dto.dart#L52) — الكلاس الذي يمثل بيانات `provider option dto` وينقلها بين الطبقات.
- [`const ProviderOptionDto({this.providerId, this.providerName, this.providerImageUrl, this.coveredCount, this.uncoveredCount, this.totalCount, this.totalPriceBefore, this.totalPriceAfter, this.coveredServices, this.uncoveredServices})`](../lib/features/cart/data/dto/choose_providers_dto.dart#L65) — ينشئ كائنًا من `ProviderOptionDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderOptionDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/choose_providers_dto.dart#L78) — ينشئ كائنًا من `ProviderOptionDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/choose_providers_dto.dart#L81) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderCoveredServiceDto`](../lib/features/cart/data/dto/choose_providers_dto.dart#L85) — الكلاس الذي يمثل بيانات `provider covered service dto` وينقلها بين الطبقات.
- [`const ProviderCoveredServiceDto({this.cartItemId, this.serviceId, this.serviceName, this.priceBefore, this.priceAfter, this.discountPercentage})`](../lib/features/cart/data/dto/choose_providers_dto.dart#L94) — ينشئ كائنًا من `ProviderCoveredServiceDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderCoveredServiceDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/choose_providers_dto.dart#L103) — ينشئ كائنًا من `ProviderCoveredServiceDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/choose_providers_dto.dart#L106) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/update_cart_provider_request_dto.dart`

- [`class UpdateCartProviderRequestDto`](../lib/features/cart/data/dto/update_cart_provider_request_dto.dart#L1) — الكلاس الذي يمثل بيانات `update cart provider request dto` وينقلها بين الطبقات.
- [`const UpdateCartProviderRequestDto({required this.cartId, required this.providerId})`](../lib/features/cart/data/dto/update_cart_provider_request_dto.dart#L5) — ينشئ كائنًا من `UpdateCartProviderRequestDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/cart/data/dto/update_cart_provider_request_dto.dart#L10) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/cart/data/dto/update_cart_provider_response_dto.dart`

- [`class UpdateCartProviderResponseDto`](../lib/features/cart/data/dto/update_cart_provider_response_dto.dart#L1) — الكلاس الذي يمثل بيانات `update cart provider response dto` وينقلها بين الطبقات.
- [`const UpdateCartProviderResponseDto({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/cart/data/dto/update_cart_provider_response_dto.dart#L8) — ينشئ كائنًا من `UpdateCartProviderResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory UpdateCartProviderResponseDto.fromJson(Map<String, dynamic> json)`](../lib/features/cart/data/dto/update_cart_provider_response_dto.dart#L16) — ينشئ كائنًا من `UpdateCartProviderResponseDto` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/cart/data/repository/cart_repository_impl.dart`

- [`class CartRepositoryImpl`](../lib/features/cart/data/repository/cart_repository_impl.dart#L24) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `cart repository impl`.
- [`CartRepositoryImpl(this._dataSource)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L27) — ينشئ كائنًا من `CartRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<String> get _bearerToken`](../lib/features/cart/data/repository/cart_repository_impl.dart#L29) — **خاص** — ينفّذ منطق `bearer token` داخل `CartRepositoryImpl`.
- [`String _failureMessage({List<String>? errors, String? message, required String fallback})`](../lib/features/cart/data/repository/cart_repository_impl.dart#L36) — **خاص** — ينفّذ منطق `failure message` داخل `CartRepositoryImpl`.
- [`Cart _mapCartDtoToDomain(CartDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L49) — **خاص** — يحوّل `map cart dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`CartItem _mapCartItemDtoToDomain(CartItemDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L59) — **خاص** — يحوّل `map cart item dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`CategoryCounter _mapCategoryCounterDtoToDomain(CategoryCounterDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L74) — **خاص** — يحوّل `map category counter dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`CategoryServices _mapCategoryServicesDtoToDomain(CategoryServicesDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L82) — **خاص** — يحوّل `map category services dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`CategoryService _mapCategoryServiceDtoToDomain(CategoryServiceDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L91) — **خاص** — يحوّل `map category service dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`Future<ApiResult<Cart>> getCart()`](../lib/features/cart/data/repository/cart_repository_impl.dart#L99) — يجلب `get cart` من مصدر البيانات المناسب داخل `CartRepositoryImpl`.
- [`Future<ApiResult<void>> addToCart({required int serviceId, required int categoryId, int? providerId, String? cardNumber, double? price})`](../lib/features/cart/data/repository/cart_repository_impl.dart#L127) — ينشئ أو يضيف `add to cart` داخل `CartRepositoryImpl`.
- [`Future<ApiResult<void>> removeFromCart(int serviceId)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L159) — يحذف أو يمسح `remove from cart` داخل `CartRepositoryImpl`.
- [`Future<ApiResult<void>> updateCartProvider({required int cartId, required int providerId})`](../lib/features/cart/data/repository/cart_repository_impl.dart#L178) — يحدّث `update cart provider` داخل `CartRepositoryImpl`.
- [`Future<ApiResult<CategoryServices>> getCategoryServices(int categoryId)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L203) — يجلب `get category services` من مصدر البيانات المناسب داخل `CartRepositoryImpl`.
- [`Future<ApiResult<void>> clearCart()`](../lib/features/cart/data/repository/cart_repository_impl.dart#L224) — يحذف أو يمسح `clear cart` داخل `CartRepositoryImpl`.
- [`Future<ApiResult<List<ProviderOption>>> getChooseProviders()`](../lib/features/cart/data/repository/cart_repository_impl.dart#L251) — يجلب `get choose providers` من مصدر البيانات المناسب داخل `CartRepositoryImpl`.
- [`ProviderOption _mapProviderOptionDtoToDomain(ProviderOptionDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L274) — **خاص** — يحوّل `map provider option dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.
- [`ProviderCoveredService _mapProviderCoveredServiceDtoToDomain(ProviderCoveredServiceDto dto)`](../lib/features/cart/data/repository/cart_repository_impl.dart#L293) — **خاص** — يحوّل `map provider covered service dto to domain` بين طبقات أو صيغ البيانات داخل `CartRepositoryImpl`.

### `features/cart/domain/models/cart.dart`

- [`class Cart`](../lib/features/cart/domain/models/cart.dart#L5) — الكلاس الذي يمثل بيانات `cart` وينقلها بين الطبقات.
- [`const Cart({required this.items, required this.totalCount, required this.categoryCounters})`](../lib/features/cart/domain/models/cart.dart#L10) — ينشئ كائنًا من `Cart` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const Cart.empty()`](../lib/features/cart/domain/models/cart.dart#L16) — ينشئ كائنًا من `Cart` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Cart removeService(int serviceId)`](../lib/features/cart/domain/models/cart.dart#L21) — يحذف أو يمسح `remove service` داخل `Cart`.
- [`Cart removeProvider(int providerId)`](../lib/features/cart/domain/models/cart.dart#L53) — يحذف أو يمسح `remove provider` داخل `Cart`.
- [`Cart assignProvider(ProviderOption provider)`](../lib/features/cart/domain/models/cart.dart#L85) — ينفّذ منطق `assign provider` داخل `Cart`.

### `features/cart/domain/models/cart_item.dart`

- [`class CartItem`](../lib/features/cart/domain/models/cart_item.dart#L1) — الكلاس الذي يمثل بيانات `cart item` وينقلها بين الطبقات.
- [`const CartItem({required this.cartItemId, required this.serviceId, required this.serviceName, required this.categoryId, this.categoryName = '', this.providerId, this.providerName, this.priceAfter, this.priceBefore, this.discountPercentage})`](../lib/features/cart/domain/models/cart_item.dart#L13) — ينشئ كائنًا من `CartItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`CartItem copyWith({int? providerId, String? providerName, double? priceAfter, double? priceBefore, double? discountPercentage})`](../lib/features/cart/domain/models/cart_item.dart#L26) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `features/cart/domain/models/category_counter.dart`

- [`class CategoryCounter`](../lib/features/cart/domain/models/category_counter.dart#L1) — الكلاس الذي يمثل بيانات `category counter` وينقلها بين الطبقات.
- [`const CategoryCounter({required this.categoryId, required this.categoryName, required this.count})`](../lib/features/cart/domain/models/category_counter.dart#L6) — ينشئ كائنًا من `CategoryCounter` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/cart/domain/models/category_service.dart`

- [`class CategoryService`](../lib/features/cart/domain/models/category_service.dart#L1) — الكلاس الذي يمثل بيانات `category service` وينقلها بين الطبقات.
- [`const CategoryService({required this.serviceId, required this.serviceName, required this.isSelected})`](../lib/features/cart/domain/models/category_service.dart#L6) — ينشئ كائنًا من `CategoryService` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/cart/domain/models/category_services.dart`

- [`class CategoryServices`](../lib/features/cart/domain/models/category_services.dart#L3) — الكلاس الذي يمثل بيانات `category services` وينقلها بين الطبقات.
- [`const CategoryServices({required this.items, this.totalSelectedCount = 0})`](../lib/features/cart/domain/models/category_services.dart#L10) — ينشئ كائنًا من `CategoryServices` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/cart/domain/models/provider_covered_service.dart`

- [`class ProviderCoveredService`](../lib/features/cart/domain/models/provider_covered_service.dart#L1) — الكلاس الذي يمثل بيانات `provider covered service` وينقلها بين الطبقات.
- [`const ProviderCoveredService({required this.cartItemId, required this.serviceId, required this.serviceName, this.priceBefore, this.priceAfter, this.discountPercentage})`](../lib/features/cart/domain/models/provider_covered_service.dart#L10) — ينشئ كائنًا من `ProviderCoveredService` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/cart/domain/models/provider_option.dart`

- [`class ProviderOption`](../lib/features/cart/domain/models/provider_option.dart#L3) — الكلاس الذي يمثل بيانات `provider option` وينقلها بين الطبقات.
- [`const ProviderOption({required this.providerId, required this.providerName, this.providerImageUrl, required this.coveredCount, required this.uncoveredCount, required this.totalCount, required this.totalPriceBefore, required this.totalPriceAfter, required this.coveredServices, required this.uncoveredServices})`](../lib/features/cart/domain/models/provider_option.dart#L24) — ينشئ كائنًا من `ProviderOption` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get coversAll`](../lib/features/cart/domain/models/provider_option.dart#L37) — ينفّذ منطق `covers all` داخل `ProviderOption`.

### `features/cart/domain/repository/cart_repository.dart`

- [`class CartRepository`](../lib/features/cart/domain/repository/cart_repository.dart#L6) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `cart repository`.
- [`Future<ApiResult<Cart>> getCart()`](../lib/features/cart/domain/repository/cart_repository.dart#L7) — يجلب `get cart` من مصدر البيانات المناسب داخل `CartRepository`.
- [`Future<ApiResult<void>> addToCart({required int serviceId, required int categoryId, int? providerId, String? cardNumber, double? price})`](../lib/features/cart/domain/repository/cart_repository.dart#L8) — ينشئ أو يضيف `add to cart` داخل `CartRepository`.
- [`Future<ApiResult<void>> removeFromCart(int serviceId)`](../lib/features/cart/domain/repository/cart_repository.dart#L15) — يحذف أو يمسح `remove from cart` داخل `CartRepository`.
- [`Future<ApiResult<void>> updateCartProvider({required int cartId, required int providerId})`](../lib/features/cart/domain/repository/cart_repository.dart#L16) — يحدّث `update cart provider` داخل `CartRepository`.
- [`Future<ApiResult<CategoryServices>> getCategoryServices(int categoryId)`](../lib/features/cart/domain/repository/cart_repository.dart#L20) — يجلب `get category services` من مصدر البيانات المناسب داخل `CartRepository`.
- [`Future<ApiResult<void>> clearCart()`](../lib/features/cart/domain/repository/cart_repository.dart#L21) — يحذف أو يمسح `clear cart` داخل `CartRepository`.
- [`Future<ApiResult<List<ProviderOption>>> getChooseProviders()`](../lib/features/cart/domain/repository/cart_repository.dart#L22) — يجلب `get choose providers` من مصدر البيانات المناسب داخل `CartRepository`.

### `features/cart/domain/services/cart_sync_service.dart`

- [`class CartSyncEvent`](../lib/features/cart/domain/services/cart_sync_service.dart#L3) — الكلاس الذي يقدّم خدمة `cart sync event` لباقي التطبيق.
- [`const CartSyncEvent({this.serviceId, this.categoryId, this.isSelected, this.cartCleared = false, this.selectedServiceIds, this.categorySelectedCounts, this.refreshCart = true})`](../lib/features/cart/domain/services/cart_sync_service.dart#L12) — ينشئ كائنًا من `CartSyncEvent` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class CartSyncService`](../lib/features/cart/domain/services/cart_sync_service.dart#L23) — الكلاس الذي يقدّم خدمة `cart sync service` لباقي التطبيق.
- [`Stream<CartSyncEvent> get stream`](../lib/features/cart/domain/services/cart_sync_service.dart#L26) — ينفّذ منطق `stream` داخل `CartSyncService`.
- [`void serviceSelectionChanged({required int serviceId, int? categoryId, required bool isSelected})`](../lib/features/cart/domain/services/cart_sync_service.dart#L28) — ينفّذ منطق `service selection changed` داخل `CartSyncService`.
- [`void cartCleared()`](../lib/features/cart/domain/services/cart_sync_service.dart#L42) — ينفّذ منطق `cart cleared` داخل `CartSyncService`.
- [`void selectionSnapshotChanged({required Iterable<int> selectedServiceIds, Map<int, int>? categorySelectedCounts, bool refreshCart = true})`](../lib/features/cart/domain/services/cart_sync_service.dart#L46) — يغيّر الاختيار الخاص بـ `selection snapshot changed` داخل `CartSyncService`.
- [`void dispose()`](../lib/features/cart/domain/services/cart_sync_service.dart#L62) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.

### `features/cart/presentation/cubit/cart_cubit.dart`

- [`enum UnknownInvoiceResolution`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L23) — يعرّف القيم الثابتة الخاصة بـ `unknown invoice resolution`.
- [`class CartCubit`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L35) — الكلاس الذي يدير حالة وتفاعلات `cart cubit`.
- [`CartCubit(this._repository, this._invoiceRepository, this._familyMembersRepository, this._networkRepository, {required CartSyncService cartSyncService, this.providerId})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L58) — ينشئ كائنًا من `CartCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> close()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L77) — يغلق الـ Cubit أو الـ streams والموارد التابعة له.
- [`Future<void> refreshCart()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L83) — يعيد تحميل أو محاولة `refresh cart` داخل `CartCubit`.
- [`Future<void> _refreshAfterCurrent()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L94) — **خاص** — يعيد تحميل أو محاولة `refresh after current` داخل `CartCubit`.
- [`Future<void> _performCartRefresh()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L100) — **خاص** — ينفّذ منطق `perform cart refresh` داخل `CartCubit`.
- [`void _broadcastCartSnapshot(Cart cart, {bool refreshCart = false})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L127) — **خاص** — ينفّذ منطق `broadcast cart snapshot` داخل `CartCubit`.
- [`Future<void> loadCategoryServices(int categoryId)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L138) — يحمّل `load category services` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<void> addToCart({required int serviceId, required int categoryId})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L167) — ينشئ أو يضيف `add to cart` داخل `CartCubit`.
- [`Future<void> removeFromCart({required int serviceId, required int categoryId})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L207) — يحذف أو يمسح `remove from cart` داخل `CartCubit`.
- [`Future<void> loadCart()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L249) — يحمّل `load cart` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<ApiResult<Cart>> _getCartWithRetry()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L277) — **خاص** — يجلب `get cart with retry` من مصدر البيانات المناسب داخل `CartCubit`.
- [`Future<void> loadCartAndProviders()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L286) — يحمّل `load cart and providers` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<void> clearCart()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L336) — يحذف أو يمسح `clear cart` داخل `CartCubit`.
- [`Future<void> loadProviders()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L367) — يحمّل `load providers` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`void selectProvider(ProviderOption provider)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L393) — يغيّر الاختيار الخاص بـ `select provider` داخل `CartCubit`.
- [`void selectCheckoutBranch(ProviderBranch branch)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L397) — يغيّر الاختيار الخاص بـ `select checkout branch` داخل `CartCubit`.
- [`void selectFamilyMember(FamilyMemberModel? member)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L401) — يغيّر الاختيار الخاص بـ `select family member` داخل `CartCubit`.
- [`void selectPaymentMethod(CartPaymentMethod method)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L410) — يغيّر الاختيار الخاص بـ `select payment method` داخل `CartCubit`.
- [`Future<void> loadCheckout({int? initialProviderId, ProviderBranch? initialBranch, int? packageId, String? packageName, double? packagePriceBefore, double? packagePriceAfter})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L414) — يحمّل `load checkout` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<ProviderOption?> _resolveCheckoutProvider({required Cart? cart, required int? initialProviderId})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L496) — **خاص** — ينفّذ منطق `resolve checkout provider` داخل `CartCubit`.
- [`int? _singleCartProviderId(Cart? cart)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L508) — **خاص** — ينفّذ منطق `single cart provider id` داخل `CartCubit`.
- [`Future<ProviderOption?> _freshProviderOption(int providerId)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L516) — **خاص** — ينفّذ منطق `fresh provider option` داخل `CartCubit`.
- [`Future<void> loadProviderBranches(int providerId, {ProviderBranch? initialBranch})`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L539) — يحمّل `load provider branches` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<void> loadFamilyMembers()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L593) — يحمّل `load family members` ويحدّث الحالة المرتبطة داخل `CartCubit`.
- [`Future<bool> createCartInvoice()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L618) — ينشئ أو يضيف `create cart invoice` داخل `CartCubit`.
- [`Future<UnknownInvoiceResolution> reconcileUnknownInvoiceOutcome()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L724) — ينفّذ منطق `reconcile unknown invoice outcome` داخل `CartCubit`.
- [`void _clearUnknownOutcome()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L821) — **خاص** — يحذف أو يمسح `clear unknown outcome` داخل `CartCubit`.
- [`Future<bool> createPackageInvoice()`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L827) — ينشئ أو يضيف `create package invoice` داخل `CartCubit`.
- [`Future<bool> assignProvider(ProviderOption provider)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L915) — ينفّذ منطق `assign provider` داخل `CartCubit`.
- [`Future<Cart?> _reconcileAssignedServices(ProviderOption provider, List<ProviderCoveredService> confirmedServices)`](../lib/features/cart/presentation/cubit/cart_cubit.dart#L1017) — **خاص** — ينفّذ منطق `reconcile assigned services` داخل `CartCubit`.

### `features/cart/presentation/cubit/cart_state.dart`

- [`enum CartPaymentMethod`](../lib/features/cart/presentation/cubit/cart_state.dart#L7) — يعرّف القيم الثابتة الخاصة بـ `cart payment method`.
- [`class CartState`](../lib/features/cart/presentation/cubit/cart_state.dart#L9) — الكلاس الذي يدير حالة وتفاعلات `cart state`.
- [`const CartState({this.cart, this.isCartLoading = false, this.cartError, this.categoryServices, this.isCategoryServicesLoading = false, this.categoryServicesError, this.pendingServiceIds = const {}, this.providers = const [], this.isProvidersLoading = false, this.providersError, this.isAssigningProvider = false, this.assignProviderError, this.selectedProvider, this.checkoutProvider, this.checkoutBranches = const [], this.selectedBranch, this.isCheckoutLoading = false, this.checkoutError, this.familyMembers = const [], this.isFamilyMembersLoading = false, this.familyMembersError, this.selectedFamilyMember, this.paymentMethod = CartPaymentMethod.cash, this.isCreatingInvoice = false, this.isInvoiceOutcomeUnknown = false, this.createInvoiceError, this.createdInvoiceId, this.createdInvoicePaymentLink, this.checkoutPackageId, this.checkoutPackageName, this.checkoutPackagePriceBefore, this.checkoutPackagePriceAfter})`](../lib/features/cart/presentation/cubit/cart_state.dart#L47) — ينشئ كائنًا من `CartState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`CartState copyWith({Cart? cart, bool? isCartLoading, String? cartError, bool resetCartError = false, CategoryServices? categoryServices, bool? isCategoryServicesLoading, String? categoryServicesError, bool resetCategoryServicesError = false, Set<int>? pendingServiceIds, List<ProviderOption>? providers, bool? isProvidersLoading, String? providersError, bool resetProvidersError = false, bool? isAssigningProvider, String? assignProviderError, bool resetAssignProviderError = false, ProviderOption? selectedProvider, bool resetSelectedProvider = false, ProviderOption? checkoutProvider, bool resetCheckoutProvider = false, List<ProviderBranch>? checkoutBranches, ProviderBranch? selectedBranch, bool resetSelectedBranch = false, bool? isCheckoutLoading, String? checkoutError, bool resetCheckoutError = false, List<FamilyMemberModel>? familyMembers, bool? isFamilyMembersLoading, String? familyMembersError, bool resetFamilyMembersError = false, FamilyMemberModel? selectedFamilyMember, bool resetSelectedFamilyMember = false, CartPaymentMethod? paymentMethod, bool? isCreatingInvoice, bool? isInvoiceOutcomeUnknown, String? createInvoiceError, bool resetCreateInvoiceError = false, String? createdInvoiceId, bool resetCreatedInvoiceId = false, String? createdInvoicePaymentLink, bool resetCreatedInvoicePaymentLink = false, int? checkoutPackageId, bool resetCheckoutPackageId = false, String? checkoutPackageName, bool resetCheckoutPackageName = false, double? checkoutPackagePriceBefore, bool resetCheckoutPackagePriceBefore = false, double? checkoutPackagePriceAfter, bool resetCheckoutPackagePriceAfter = false})`](../lib/features/cart/presentation/cubit/cart_state.dart#L82) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `features/cart/presentation/pages/cart_screen.dart`

- [`class CartScreen`](../lib/features/cart/presentation/pages/cart_screen.dart#L15) — الكلاس الذي يمثل شاشة `cart screen`.
- [`const CartScreen({super.key, this.initialProviderId, this.initialBranch})`](../lib/features/cart/presentation/pages/cart_screen.dart#L19) — ينشئ كائنًا من `CartScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<CartScreen> createState()`](../lib/features/cart/presentation/pages/cart_screen.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _CartScreenState`](../lib/features/cart/presentation/pages/cart_screen.dart#L25) — **خاص** — الكلاس الذي يمثل شاشة `cart screen state`.
- [`void initState()`](../lib/features/cart/presentation/pages/cart_screen.dart#L26) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/pages/cart_screen.dart#L32) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/pages/checkout_screen.dart`

- [`class CheckoutScreen`](../lib/features/cart/presentation/pages/checkout_screen.dart#L25) — الكلاس الذي يمثل شاشة `checkout screen`.
- [`const CheckoutScreen({super.key, this.initialProviderId, this.initialBranch, this.packageId, this.packageName, this.packagePriceBefore, this.packagePriceAfter})`](../lib/features/cart/presentation/pages/checkout_screen.dart#L33) — ينشئ كائنًا من `CheckoutScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<CheckoutScreen> createState()`](../lib/features/cart/presentation/pages/checkout_screen.dart#L43) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _CheckoutScreenState`](../lib/features/cart/presentation/pages/checkout_screen.dart#L47) — **خاص** — الكلاس الذي يمثل شاشة `checkout screen state`.
- [`void initState()`](../lib/features/cart/presentation/pages/checkout_screen.dart#L51) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/cart/presentation/pages/checkout_screen.dart#L65) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void didChangeAppLifecycleState(AppLifecycleState state)`](../lib/features/cart/presentation/pages/checkout_screen.dart#L71) — **خاص** — ينفّذ منطق `did change app lifecycle state` داخل `_CheckoutScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/pages/checkout_screen.dart#L84) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildBody(BuildContext context, CartState state)`](../lib/features/cart/presentation/pages/checkout_screen.dart#L180) — **خاص** — ينفّذ منطق `build body` داخل `_CheckoutScreenState`.

### `features/cart/presentation/widgets/cart_body.dart`

- [`class CartBody`](../lib/features/cart/presentation/widgets/cart_body.dart#L18) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CartBody({super.key, required this.items, required this.categoryCounters, this.initialProviderId, this.initialBranch, this.syncError, required this.isBusy})`](../lib/features/cart/presentation/widgets/cart_body.dart#L30) — ينشئ كائنًا من `CartBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_body.dart#L39) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SummaryStrip`](../lib/features/cart/presentation/widgets/cart_body.dart#L101) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SummaryStrip({required this.itemCount, required this.total, required this.isBusy})`](../lib/features/cart/presentation/widgets/cart_body.dart#L106) — **خاص** — ينشئ كائنًا من `SummaryStrip` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_body.dart#L112) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> _showClearCartSheet(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_body.dart#L170) — **خاص** — يعرض أو يفتح `show clear cart sheet` داخل هذا الملف.
- [`class _NeedsProviderBanner`](../lib/features/cart/presentation/widgets/cart_body.dart#L273) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _NeedsProviderBanner({required this.onTap})`](../lib/features/cart/presentation/widgets/cart_body.dart#L276) — **خاص** — ينشئ كائنًا من `NeedsProviderBanner` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_body.dart#L278) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ProviderGroupSection`](../lib/features/cart/presentation/widgets/cart_body.dart#L320) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ProviderGroupSection({required this.providerId, required this.items, this.initialBranch})`](../lib/features/cart/presentation/widgets/cart_body.dart#L325) — **خاص** — ينشئ كائنًا من `ProviderGroupSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_body.dart#L331) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/cart_empty_view.dart`

- [`class CartEmptyView`](../lib/features/cart/presentation/widgets/cart_empty_view.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CartEmptyView({super.key, required this.onExplore})`](../lib/features/cart/presentation/widgets/cart_empty_view.dart#L11) — ينشئ كائنًا من `CartEmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_empty_view.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/cart_error_view.dart`

- [`class CartErrorView`](../lib/features/cart/presentation/widgets/cart_error_view.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CartErrorView({super.key, required this.message, required this.onRetry})`](../lib/features/cart/presentation/widgets/cart_error_view.dart#L11) — ينشئ كائنًا من `CartErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_error_view.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/cart_item_card.dart`

- [`class CartItemCard`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CartItemCard({super.key, required this.item, this.showDivider = true})`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L17) — ينشئ كائنًا من `CartItemCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L19) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _Tag`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L130) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _Tag({required this.label, required this.bg, required this.fg})`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L135) — **خاص** — ينشئ كائنًا من `Tag` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L137) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _PriceLine`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L157) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _PriceLine({required this.item})`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L160) — **خاص** — ينشئ كائنًا من `PriceLine` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_item_card.dart#L162) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/cart_sync_warning.dart`

- [`class CartSyncWarning`](../lib/features/cart/presentation/widgets/cart_sync_warning.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CartSyncWarning({super.key, required this.message})`](../lib/features/cart/presentation/widgets/cart_sync_warning.dart#L12) — ينشئ كائنًا من `CartSyncWarning` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/cart_sync_warning.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/category_badges_row.dart`

- [`class CategoryBadgesRow`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryBadgesRow({super.key, required this.counters})`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L11) — ينشئ كائنًا من `CategoryBadgesRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class CategoryChip`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L45) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryChip({super.key, required this.counter})`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L48) — ينشئ كائنًا من `CategoryChip` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/category_badges_row.dart#L50) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_branch_selector.dart`

- [`class CheckoutBranchSelector`](../lib/features/cart/presentation/widgets/checkout_branch_selector.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutBranchSelector({super.key, required this.state})`](../lib/features/cart/presentation/widgets/checkout_branch_selector.dart#L13) — ينشئ كائنًا من `CheckoutBranchSelector` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_branch_selector.dart#L15) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_dropdown_frame.dart`

- [`class CheckoutDropdownFrame`](../lib/features/cart/presentation/widgets/checkout_dropdown_frame.dart#L5) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutDropdownFrame({super.key, required this.child})`](../lib/features/cart/presentation/widgets/checkout_dropdown_frame.dart#L8) — ينشئ كائنًا من `CheckoutDropdownFrame` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_dropdown_frame.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_error_view.dart`

- [`class CheckoutErrorView`](../lib/features/cart/presentation/widgets/checkout_error_view.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutErrorView({super.key, required this.message, required this.onRetry})`](../lib/features/cart/presentation/widgets/checkout_error_view.dart#L11) — ينشئ كائنًا من `CheckoutErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_error_view.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_map_preview.dart`

- [`class CheckoutMapPreview`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutMapPreview({super.key, required this.branch})`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L12) — ينشئ كائنًا من `CheckoutMapPreview` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<CheckoutMapPreview> createState()`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L14) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class CheckoutMapPreviewState`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L18) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`LatLng? get _point`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L21) — **خاص** — ينفّذ منطق `point` داخل `CheckoutMapPreviewState`.
- [`void didUpdateWidget(covariant CheckoutMapPreview oldWidget)`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L28) — يتعامل مع تغيّر إعدادات الـ widget مع الاحتفاظ بالحالة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_map_preview.dart#L40) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_patient_dropdown.dart`

- [`class CheckoutPatientDropdown`](../lib/features/cart/presentation/widgets/checkout_patient_dropdown.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutPatientDropdown({super.key, required this.state})`](../lib/features/cart/presentation/widgets/checkout_patient_dropdown.dart#L13) — ينشئ كائنًا من `CheckoutPatientDropdown` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_patient_dropdown.dart#L15) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _memberName(FamilyMemberModel member)`](../lib/features/cart/presentation/widgets/checkout_patient_dropdown.dart#L58) — **خاص** — ينفّذ منطق `member name` داخل `CheckoutPatientDropdown`.

### `features/cart/presentation/widgets/checkout_pay_button.dart`

- [`class CheckoutPayButton`](../lib/features/cart/presentation/widgets/checkout_pay_button.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutPayButton({super.key, required this.state})`](../lib/features/cart/presentation/widgets/checkout_pay_button.dart#L16) — ينشئ كائنًا من `CheckoutPayButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_pay_button.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> _reconcile(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_pay_button.dart#L102) — **خاص** — ينفّذ منطق `reconcile` داخل `CheckoutPayButton`.

### `features/cart/presentation/widgets/checkout_payment_dropdown.dart`

- [`class CheckoutPaymentDropdown`](../lib/features/cart/presentation/widgets/checkout_payment_dropdown.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutPaymentDropdown({super.key, required this.state})`](../lib/features/cart/presentation/widgets/checkout_payment_dropdown.dart#L12) — ينشئ كائنًا من `CheckoutPaymentDropdown` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_payment_dropdown.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_payment_summary.dart`

- [`class CheckoutPaymentSummary`](../lib/features/cart/presentation/widgets/checkout_payment_summary.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutPaymentSummary({super.key, required this.state})`](../lib/features/cart/presentation/widgets/checkout_payment_summary.dart#L14) — ينشئ كائنًا من `CheckoutPaymentSummary` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_payment_summary.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_section_title.dart`

- [`class CheckoutSectionTitle`](../lib/features/cart/presentation/widgets/checkout_section_title.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutSectionTitle({super.key, required this.text})`](../lib/features/cart/presentation/widgets/checkout_section_title.dart#L9) — ينشئ كائنًا من `CheckoutSectionTitle` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_section_title.dart#L11) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/cart/presentation/widgets/checkout_summary_row.dart`

- [`class CheckoutSummaryRow`](../lib/features/cart/presentation/widgets/checkout_summary_row.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CheckoutSummaryRow({super.key, required this.label, required this.value, this.valueColor, this.isBold = false})`](../lib/features/cart/presentation/widgets/checkout_summary_row.dart#L12) — ينشئ كائنًا من `CheckoutSummaryRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/checkout_summary_row.dart#L19) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String checkoutMoney(double value)`](../lib/features/cart/presentation/widgets/checkout_summary_row.dart#L56) — ينفّذ منطق `checkout money` داخل هذا الملف.

### `features/cart/presentation/widgets/floating_cart_button.dart`

- [`class FloatingCartButton`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L14) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const FloatingCartButton({super.key})`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L20) — ينشئ كائنًا من `FloatingCartButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<FloatingCartButton> createState()`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L22) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _FloatingCartButtonState`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L26) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L33) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onLocationChanged()`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L43) — **خاص** — يعالج حدث `on location changed` داخل `_FloatingCartButtonState`.
- [`void dispose()`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L54) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Future<void> _refreshCount()`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L61) — **خاص** — يعيد تحميل أو محاولة `refresh count` داخل `_FloatingCartButtonState`.
- [`Widget build(BuildContext context)`](../lib/features/cart/presentation/widgets/floating_cart_button.dart#L79) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: content

### `features/content/data/models/content_response_model.dart`

- [`class ContentResponseModel`](../lib/features/content/data/models/content_response_model.dart#L5) — الكلاس الذي يمثل بيانات `content response model` وينقلها بين الطبقات.
- [`const ContentResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/content/data/models/content_response_model.dart#L13) — ينشئ كائنًا من `ContentResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ContentResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/content/data/models/content_response_model.dart#L21) — ينشئ كائنًا من `ContentResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/content/data/models/content_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ContentData`](../lib/features/content/data/models/content_response_model.dart#L27) — الكلاس الذي يمثل بيانات `content data` وينقلها بين الطبقات.
- [`const ContentData({this.id, this.description = ''})`](../lib/features/content/data/models/content_response_model.dart#L34) — ينشئ كائنًا من `ContentData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ContentData.fromJson(Map<String, dynamic> json)`](../lib/features/content/data/models/content_response_model.dart#L36) — ينشئ كائنًا من `ContentData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/content/data/models/content_response_model.dart#L39) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`static int? _idFromJson(Object? value)`](../lib/features/content/data/models/content_response_model.dart#L41) — **خاص** — ينفّذ منطق `id from json` داخل `ContentData`.
- [`static String _descriptionFromJson(Object? value)`](../lib/features/content/data/models/content_response_model.dart#L48) — **خاص** — ينفّذ منطق `description from json` داخل `ContentData`.

### `features/content/data/repositories/content_repository_impl.dart`

- [`class ContentRepositoryImpl`](../lib/features/content/data/repositories/content_repository_impl.dart#L10) — الكلاس الذي يمثل بيانات `content repository impl` وينقلها بين الطبقات.
- [`ContentRepositoryImpl(this.apiService)`](../lib/features/content/data/repositories/content_repository_impl.dart#L13) — ينشئ كائنًا من `ContentRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ContentData>> getContent(ContentType contentType)`](../lib/features/content/data/repositories/content_repository_impl.dart#L15) — يجلب `get content` من مصدر البيانات المناسب داخل `ContentRepositoryImpl`.
- [`String _messageForFailure(AppFailure failure)`](../lib/features/content/data/repositories/content_repository_impl.dart#L40) — **خاص** — ينفّذ منطق `message for failure` داخل `ContentRepositoryImpl`.

### `features/content/domain/models/content_type.dart`

- [`enum ContentType`](../lib/features/content/domain/models/content_type.dart#L1) — يعرّف القيم الثابتة الخاصة بـ `content type`.
- [`const ContentType({required this.slug, required this.titleKey})`](../lib/features/content/domain/models/content_type.dart#L9) — ينشئ كائنًا من `ContentType` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String get apiPath`](../lib/features/content/domain/models/content_type.dart#L14) — ينفّذ منطق `api path` داخل `ContentType`.

### `features/content/domain/repositories/content_repository.dart`

- [`class ContentRepository`](../lib/features/content/domain/repositories/content_repository.dart#L5) — الكلاس الذي يجمع مسؤوليات `content repository`.
- [`Future<ApiResult<ContentData>> getContent(ContentType contentType)`](../lib/features/content/domain/repositories/content_repository.dart#L6) — يجلب `get content` من مصدر البيانات المناسب داخل `ContentRepository`.

### `features/content/domain/use_cases/get_content_use_case.dart`

- [`class GetContentUseCase`](../lib/features/content/domain/use_cases/get_content_use_case.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `get content use case`.
- [`GetContentUseCase(this.repository)`](../lib/features/content/domain/use_cases/get_content_use_case.dart#L9) — ينشئ كائنًا من `GetContentUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ContentData>> call(ContentType contentType)`](../lib/features/content/domain/use_cases/get_content_use_case.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/content/presentation/cubit/content_cubit.dart`

- [`class ContentCubit`](../lib/features/content/presentation/cubit/content_cubit.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `content cubit`.
- [`ContentCubit(this._getContentUseCase)`](../lib/features/content/presentation/cubit/content_cubit.dart#L12) — ينشئ كائنًا من `ContentCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadContent(ContentType contentType, {bool force = false})`](../lib/features/content/presentation/cubit/content_cubit.dart#L14) — يحمّل `load content` ويحدّث الحالة المرتبطة داخل `ContentCubit`.
- [`Future<void> retry(ContentType contentType)`](../lib/features/content/presentation/cubit/content_cubit.dart#L31) — يعيد تحميل أو محاولة `retry` داخل `ContentCubit`.
- [`Future<void> _performLoad(ContentType contentType)`](../lib/features/content/presentation/cubit/content_cubit.dart#L34) — **خاص** — ينفّذ منطق `perform load` داخل `ContentCubit`.

### `features/content/presentation/cubit/content_state.dart`

- [`class ContentState`](../lib/features/content/presentation/cubit/content_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `content state`.
- [`const factory ContentState.initial()`](../lib/features/content/presentation/cubit/content_state.dart#L8) — ينشئ كائنًا من `ContentState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ContentState.loading()`](../lib/features/content/presentation/cubit/content_state.dart#L9) — ينشئ كائنًا من `ContentState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ContentState.success(ContentData data)`](../lib/features/content/presentation/cubit/content_state.dart#L10) — ينشئ كائنًا من `ContentState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ContentState.failed(String error)`](../lib/features/content/presentation/cubit/content_state.dart#L11) — ينشئ كائنًا من `ContentState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/content/presentation/pages/content_screen.dart`

- [`class ContentScreen`](../lib/features/content/presentation/pages/content_screen.dart#L21) — الكلاس الذي يمثل شاشة `content screen`.
- [`const ContentScreen({super.key, required this.contentType})`](../lib/features/content/presentation/pages/content_screen.dart#L24) — ينشئ كائنًا من `ContentScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ContentScreen> createState()`](../lib/features/content/presentation/pages/content_screen.dart#L26) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ContentScreenState`](../lib/features/content/presentation/pages/content_screen.dart#L30) — **خاص** — الكلاس الذي يمثل شاشة `content screen state`.
- [`void initState()`](../lib/features/content/presentation/pages/content_screen.dart#L33) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/content/presentation/pages/content_screen.dart#L39) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _HtmlContentView`](../lib/features/content/presentation/pages/content_screen.dart#L89) — **خاص** — الكلاس الذي يمثل شاشة `html content view`.
- [`const _HtmlContentView({required this.html, required this.isRtl, required this.linkHandler})`](../lib/features/content/presentation/pages/content_screen.dart#L94) — **خاص** — ينشئ كائنًا من `HtmlContentView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/content/presentation/pages/content_screen.dart#L100) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ContentEmptyView`](../lib/features/content/presentation/pages/content_screen.dart#L221) — **خاص** — الكلاس الذي يمثل شاشة `content empty view`.
- [`const _ContentEmptyView({required this.contentType})`](../lib/features/content/presentation/pages/content_screen.dart#L224) — **خاص** — ينشئ كائنًا من `ContentEmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/content/presentation/pages/content_screen.dart#L226) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/content/presentation/utils/content_link_handler.dart`

- [`enum ContentLinkAction`](../lib/features/content/presentation/utils/content_link_handler.dart#L6) — يعرّف القيم الثابتة الخاصة بـ `content link action`.
- [`class ContentLinkHandler`](../lib/features/content/presentation/utils/content_link_handler.dart#L15) — الكلاس الذي يجمع مسؤوليات `content link handler`.
- [`const ContentLinkHandler(this._launcher)`](../lib/features/content/presentation/utils/content_link_handler.dart#L18) — ينشئ كائنًا من `ContentLinkHandler` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static ContentLinkAction classifyUrl(String? rawUrl)`](../lib/features/content/presentation/utils/content_link_handler.dart#L20) — ينفّذ منطق `classify url` داخل `ContentLinkHandler`.
- [`ContentLinkAction classify(String? rawUrl)`](../lib/features/content/presentation/utils/content_link_handler.dart#L47) — ينفّذ منطق `classify` داخل `ContentLinkHandler`.
- [`Future<bool> handle(BuildContext context, String? rawUrl)`](../lib/features/content/presentation/utils/content_link_handler.dart#L49) — يعالج حدث `handle` داخل `ContentLinkHandler`.

### `features/content/presentation/widgets/content_error_view.dart`

- [`class ContentErrorView`](../lib/features/content/presentation/widgets/content_error_view.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ContentErrorView({super.key, required this.onRetry, required this.message})`](../lib/features/content/presentation/widgets/content_error_view.dart#L13) — ينشئ كائنًا من `ContentErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/content/presentation/widgets/content_error_view.dart#L19) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/content/presentation/widgets/content_shimmer.dart`

- [`class ContentShimmer`](../lib/features/content/presentation/widgets/content_shimmer.dart#L5) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ContentShimmer({super.key})`](../lib/features/content/presentation/widgets/content_shimmer.dart#L6) — ينشئ كائنًا من `ContentShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/content/presentation/widgets/content_shimmer.dart#L8) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: ecard

### `features/ecard/data/models/card_data_response_model.dart`

- [`class CardDataResponseModel`](../lib/features/ecard/data/models/card_data_response_model.dart#L5) — الكلاس الذي يمثل بيانات `card data response model` وينقلها بين الطبقات.
- [`const CardDataResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/ecard/data/models/card_data_response_model.dart#L13) — ينشئ كائنًا من `CardDataResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardDataResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/ecard/data/models/card_data_response_model.dart#L21) — ينشئ كائنًا من `CardDataResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/ecard/data/models/card_data_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CardData`](../lib/features/ecard/data/models/card_data_response_model.dart#L27) — الكلاس الذي يمثل بيانات `card data` وينقلها بين الطبقات.
- [`const CardData({this.cardNumber, this.expireAt, this.firstName, this.lastName, this.planType})`](../lib/features/ecard/data/models/card_data_response_model.dart#L35) — ينشئ كائنًا من `CardData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CardData.fromJson(Map<String, dynamic> json)`](../lib/features/ecard/data/models/card_data_response_model.dart#L43) — ينشئ كائنًا من `CardData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/ecard/data/models/card_data_response_model.dart#L46) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`String get fullName`](../lib/features/ecard/data/models/card_data_response_model.dart#L48) — ينفّذ منطق `full name` داخل `CardData`.
- [`String get formattedCardNumber`](../lib/features/ecard/data/models/card_data_response_model.dart#L56) — ينسّق `formatted card number` للعرض أو الإرسال داخل `CardData`.
- [`String get formattedExpiry`](../lib/features/ecard/data/models/card_data_response_model.dart#L60) — ينسّق `formatted expiry` للعرض أو الإرسال داخل `CardData`.

### `features/ecard/domain/usecases/get_card_data_usecase.dart`

- [`class GetCardDataUseCase`](../lib/features/ecard/domain/usecases/get_card_data_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get card data use case`.
- [`GetCardDataUseCase(this._repository)`](../lib/features/ecard/domain/usecases/get_card_data_usecase.dart#L8) — ينشئ كائنًا من `GetCardDataUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CardDataResponseModel>> call()`](../lib/features/ecard/domain/usecases/get_card_data_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/ecard/presentation/cubit/ecard_cubit.dart`

- [`class ECardCubit`](../lib/features/ecard/presentation/cubit/ecard_cubit.dart#L8) — الكلاس الذي يدير حالة وتفاعلات `ecard cubit`.
- [`ECardCubit(this._getCardDataUseCase)`](../lib/features/ecard/presentation/cubit/ecard_cubit.dart#L12) — ينشئ كائنًا من `ECardCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadCardData({bool forceRefresh = false})`](../lib/features/ecard/presentation/cubit/ecard_cubit.dart#L14) — يحمّل `load card data` ويحدّث الحالة المرتبطة داخل `ECardCubit`.
- [`Future<void> _performLoad()`](../lib/features/ecard/presentation/cubit/ecard_cubit.dart#L33) — **خاص** — ينفّذ منطق `perform load` داخل `ECardCubit`.

### `features/ecard/presentation/cubit/ecard_state.dart`

- [`class ECardState`](../lib/features/ecard/presentation/cubit/ecard_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `ecard state`.
- [`const factory ECardState.initial()`](../lib/features/ecard/presentation/cubit/ecard_state.dart#L8) — ينشئ كائنًا من `ECardState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ECardState.loading()`](../lib/features/ecard/presentation/cubit/ecard_state.dart#L9) — ينشئ كائنًا من `ECardState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ECardState.loaded(CardData? data)`](../lib/features/ecard/presentation/cubit/ecard_state.dart#L10) — ينشئ كائنًا من `ECardState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ECardState.failed(String error)`](../lib/features/ecard/presentation/cubit/ecard_state.dart#L11) — ينشئ كائنًا من `ECardState` ويهيّئ الاعتماديات والقيم المطلوبة.


## Feature: family_members

### `features/family_members/data/models/create_family_member_request_model.dart`

- [`class CreateFamilyMemberRequestModel`](../lib/features/family_members/data/models/create_family_member_request_model.dart#L5) — الكلاس الذي يمثل بيانات `create family member request model` وينقلها بين الطبقات.
- [`const CreateFamilyMemberRequestModel({this.firstName, this.lastName, this.relation, this.imageUrl})`](../lib/features/family_members/data/models/create_family_member_request_model.dart#L12) — ينشئ كائنًا من `CreateFamilyMemberRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CreateFamilyMemberRequestModel.fromJson(Map<String, dynamic> json)`](../lib/features/family_members/data/models/create_family_member_request_model.dart#L19) — ينشئ كائنًا من `CreateFamilyMemberRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/family_members/data/models/create_family_member_request_model.dart#L22) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/family_members/data/models/family_member_model.dart`

- [`class FamilyMemberModel`](../lib/features/family_members/data/models/family_member_model.dart#L5) — الكلاس الذي يمثل بيانات `family member model` وينقلها بين الطبقات.
- [`const FamilyMemberModel({this.id, this.fullName, this.firstName, this.lastName, this.relation, this.imageUrl})`](../lib/features/family_members/data/models/family_member_model.dart#L14) — ينشئ كائنًا من `FamilyMemberModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory FamilyMemberModel.fromJson(Map<String, dynamic> json)`](../lib/features/family_members/data/models/family_member_model.dart#L23) — ينشئ كائنًا من `FamilyMemberModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/family_members/data/models/family_member_model.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/family_members/data/models/family_member_operation_response_model.dart`

- [`class FamilyMemberOperationResponseModel`](../lib/features/family_members/data/models/family_member_operation_response_model.dart#L5) — الكلاس الذي يمثل بيانات `family member operation response model` وينقلها بين الطبقات.
- [`const FamilyMemberOperationResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/family_members/data/models/family_member_operation_response_model.dart#L13) — ينشئ كائنًا من `FamilyMemberOperationResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory FamilyMemberOperationResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/family_members/data/models/family_member_operation_response_model.dart#L21) — ينشئ كائنًا من `FamilyMemberOperationResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/family_members/data/models/family_member_operation_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/family_members/data/models/get_family_member_response_model.dart`

- [`class GetFamilyMemberResponseModel`](../lib/features/family_members/data/models/get_family_member_response_model.dart#L6) — الكلاس الذي يمثل بيانات `get family member response model` وينقلها بين الطبقات.
- [`const GetFamilyMemberResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/family_members/data/models/get_family_member_response_model.dart#L14) — ينشئ كائنًا من `GetFamilyMemberResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GetFamilyMemberResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/family_members/data/models/get_family_member_response_model.dart#L22) — ينشئ كائنًا من `GetFamilyMemberResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/family_members/data/models/get_family_member_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/family_members/data/models/get_family_members_response_model.dart`

- [`class GetFamilyMembersResponseModel`](../lib/features/family_members/data/models/get_family_members_response_model.dart#L6) — الكلاس الذي يمثل بيانات `get family members response model` وينقلها بين الطبقات.
- [`const GetFamilyMembersResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/family_members/data/models/get_family_members_response_model.dart#L14) — ينشئ كائنًا من `GetFamilyMembersResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GetFamilyMembersResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/family_members/data/models/get_family_members_response_model.dart#L22) — ينشئ كائنًا من `GetFamilyMembersResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/family_members/data/models/get_family_members_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/family_members/data/repository/family_members_repository_impl.dart`

- [`class FamilyMembersRepositoryImpl`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L9) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `family members repository impl`.
- [`FamilyMembersRepositoryImpl(this.apiService)`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L12) — ينشئ كائنًا من `FamilyMembersRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<List<FamilyMemberModel>> getFamilyMembers()`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L14) — يجلب `get family members` من مصدر البيانات المناسب داخل `FamilyMembersRepositoryImpl`.
- [`Future<FamilyMemberModel> getFamilyMember(int id)`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L29) — يجلب `get family member` من مصدر البيانات المناسب داخل `FamilyMembersRepositoryImpl`.
- [`Future<void> createFamilyMember(String firstName, String lastName, int relation, String? imageUrl)`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L42) — ينشئ أو يضيف `create family member` داخل `FamilyMembersRepositoryImpl`.
- [`Future<void> updateFamilyMember(int id, String firstName, String lastName, int relation, String? imageUrl)`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L65) — يحدّث `update family member` داخل `FamilyMembersRepositoryImpl`.
- [`Future<void> deleteFamilyMember(int id)`](../lib/features/family_members/data/repository/family_members_repository_impl.dart#L89) — يحذف أو يمسح `delete family member` داخل `FamilyMembersRepositoryImpl`.

### `features/family_members/domain/repository/family_members_repository.dart`

- [`class FamilyMembersRepository`](../lib/features/family_members/domain/repository/family_members_repository.dart#L3) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `family members repository`.
- [`Future<List<FamilyMemberModel>> getFamilyMembers()`](../lib/features/family_members/domain/repository/family_members_repository.dart#L4) — يجلب `get family members` من مصدر البيانات المناسب داخل `FamilyMembersRepository`.
- [`Future<FamilyMemberModel> getFamilyMember(int id)`](../lib/features/family_members/domain/repository/family_members_repository.dart#L5) — يجلب `get family member` من مصدر البيانات المناسب داخل `FamilyMembersRepository`.
- [`Future<void> createFamilyMember(String firstName, String lastName, int relation, String? imageUrl)`](../lib/features/family_members/domain/repository/family_members_repository.dart#L6) — ينشئ أو يضيف `create family member` داخل `FamilyMembersRepository`.
- [`Future<void> updateFamilyMember(int id, String firstName, String lastName, int relation, String? imageUrl)`](../lib/features/family_members/domain/repository/family_members_repository.dart#L7) — يحدّث `update family member` داخل `FamilyMembersRepository`.
- [`Future<void> deleteFamilyMember(int id)`](../lib/features/family_members/domain/repository/family_members_repository.dart#L8) — يحذف أو يمسح `delete family member` داخل `FamilyMembersRepository`.

### `features/family_members/presentation/cubit/family_members_cubit.dart`

- [`class FamilyMembersCubit`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L13) — الكلاس الذي يدير حالة وتفاعلات `family members cubit`.
- [`FamilyMembersCubit(this.repository)`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L16) — ينشئ كائنًا من `FamilyMembersCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadFamilyMembers()`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L18) — يحمّل `load family members` ويحدّث الحالة المرتبطة داخل `FamilyMembersCubit`.
- [`Future<void> createFamilyMember({required String firstName, required String lastName, required int relation, String? imageUrl})`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L31) — ينشئ أو يضيف `create family member` داخل `FamilyMembersCubit`.
- [`Future<void> updateFamilyMember({required int id, required String firstName, required String lastName, required int relation, String? imageUrl})`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L70) — يحدّث `update family member` داخل `FamilyMembersCubit`.
- [`Future<void> deleteFamilyMember({required int id})`](../lib/features/family_members/presentation/cubit/family_members_cubit.dart#L98) — يحذف أو يمسح `delete family member` داخل `FamilyMembersCubit`.

### `features/family_members/presentation/cubit/family_members_state.dart`

- [`class FamilyMembersState`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `family members state`.
- [`const factory FamilyMembersState.initial()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L8) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.loading()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L9) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.success(List<FamilyMemberModel> members)`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L10) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.failed(String error)`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L11) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.creating()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L12) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.created()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L13) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.updating()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L14) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.updated()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L15) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.deleting()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L16) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory FamilyMembersState.deleted()`](../lib/features/family_members/presentation/cubit/family_members_state.dart#L17) — ينشئ كائنًا من `FamilyMembersState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/family_members/presentation/pages/add_edit_family_member_screen.dart`

- [`class AddEditFamilyMemberScreen`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L16) — الكلاس الذي يمثل شاشة `add edit family member screen`.
- [`const AddEditFamilyMemberScreen({super.key, this.member})`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L19) — ينشئ كائنًا من `AddEditFamilyMemberScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AddEditFamilyMemberScreen> createState()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AddEditFamilyMemberScreenState`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L26) — **خاص** — الكلاس الذي يمثل شاشة `add edit family member screen state`.
- [`void initState()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L35) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L55) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _submit()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L65) — **خاص** — يرسل `submit` إلى الطبقة أو الخدمة المطلوبة داخل `_AddEditFamilyMemberScreenState`.
- [`void _showDeleteDialog()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L85) — **خاص** — يعرض أو يفتح `show delete dialog` داخل `_AddEditFamilyMemberScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L114) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildTextField({required TextEditingController controller, required String hint, String? Function(String?)? validator, List<TextInputFormatter>? inputFormatters, String? focusKey})`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L259) — **خاص** — ينفّذ منطق `build text field` داخل `_AddEditFamilyMemberScreenState`.
- [`String? _validateName(String? value)`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L283) — **خاص** — يتحقق من صحة `validate name` داخل `_AddEditFamilyMemberScreenState`.
- [`Widget _buildRelationDropdown()`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L292) — **خاص** — ينفّذ منطق `build relation dropdown` داخل `_AddEditFamilyMemberScreenState`.
- [`class _FieldLabel`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L328) — **خاص** — الكلاس الذي يمثل شاشة `field label`.
- [`const _FieldLabel(this.label)`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L330) — **خاص** — ينشئ كائنًا من `FieldLabel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/family_members/presentation/pages/add_edit_family_member_screen.dart#L332) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/family_members/presentation/pages/family_members_list_screen.dart`

- [`class FamilyMembersListScreen`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L18) — الكلاس الذي يمثل شاشة `family members list screen`.
- [`const FamilyMembersListScreen({super.key})`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L19) — ينشئ كائنًا من `FamilyMembersListScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<FamilyMembersListScreen> createState()`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _FamilyMembersListScreenState`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L26) — **خاص** — الكلاس الذي يمثل شاشة `family members list screen state`.
- [`Widget build(BuildContext context)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L27) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildEmptyState(BuildContext context)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L171) — **خاص** — ينفّذ منطق `build empty state` داخل `_FamilyMembersListScreenState`.
- [`class _FamilyMemberListItem`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L188) — **خاص** — الكلاس الذي يمثل شاشة `family member list item`.
- [`const _FamilyMemberListItem({required this.member, this.showDivider = true})`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L192) — **خاص** — ينشئ كائنًا من `FamilyMemberListItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L194) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`void _showDeleteDialog(BuildContext context, FamilyMemberModel member)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L266) — **خاص** — يعرض أو يفتح `show delete dialog` داخل `_FamilyMemberListItem`.
- [`Widget _buildAvatar(String? imageUrl)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L295) — **خاص** — ينفّذ منطق `build avatar` داخل `_FamilyMemberListItem`.
- [`Widget _buildPlaceholderAvatar()`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L315) — **خاص** — ينفّذ منطق `build placeholder avatar` داخل `_FamilyMemberListItem`.
- [`class _CircleIconButton`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L324) — **خاص** — الكلاس الذي يمثل شاشة `circle icon button`.
- [`const _CircleIconButton({required this.icon, required this.foreground, required this.background, required this.onTap})`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L330) — **خاص** — ينشئ كائنًا من `CircleIconButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/family_members/presentation/pages/family_members_list_screen.dart#L337) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: guest_home

### `features/guest_home/data/models/guest_home_response_model.dart`

- [`class GuestHomeResponseModel`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L5) — الكلاس الذي يمثل بيانات `guest home response model` وينقلها بين الطبقات.
- [`const GuestHomeResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L13) — ينشئ كائنًا من `GuestHomeResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestHomeResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L21) — ينشئ كائنًا من `GuestHomeResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestHomeDataModel`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L27) — الكلاس الذي يمثل بيانات `guest home data model` وينقلها بين الطبقات.
- [`const GuestHomeDataModel({this.sliders, this.categories, this.nearestProviders, this.packages})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L34) — ينشئ كائنًا من `GuestHomeDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestHomeDataModel.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L41) — ينشئ كائنًا من `GuestHomeDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L44) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestSlider`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L47) — الكلاس الذي يمثل بيانات `guest slider` وينقلها بين الطبقات.
- [`const GuestSlider({this.id, this.imageUrl, this.providerId, this.providerName})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L54) — ينشئ كائنًا من `GuestSlider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestSlider.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L61) — ينشئ كائنًا من `GuestSlider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L64) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestCategory`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L67) — الكلاس الذي يمثل بيانات `guest category` وينقلها بين الطبقات.
- [`const GuestCategory({this.id, this.name, this.imageUrl})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L73) — ينشئ كائنًا من `GuestCategory` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestCategory.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L79) — ينشئ كائنًا من `GuestCategory` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L82) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestNearestProvider`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L85) — الكلاس الذي يمثل بيانات `guest nearest provider` وينقلها بين الطبقات.
- [`const GuestNearestProvider({this.providerId, this.providerBranchId, this.providerName, this.providerImageUrl, this.branchName, this.fullAddress, this.mapUrl, this.distanceKm})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L96) — ينشئ كائنًا من `GuestNearestProvider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestNearestProvider.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L107) — ينشئ كائنًا من `GuestNearestProvider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L110) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestPackage`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L113) — الكلاس الذي يمثل بيانات `guest package` وينقلها بين الطبقات.
- [`const GuestPackage({this.packageId, this.providerId, this.providerName, this.name, this.imageUrl, this.description, this.priceBefore, this.priceAfter, this.discountPercentage, this.servicesCount})`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L126) — ينشئ كائنًا من `GuestPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestPackage.fromJson(Map<String, dynamic> json)`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L139) — ينشئ كائنًا من `GuestPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/guest_home/data/models/guest_home_response_model.dart#L142) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/guest_home/domain/usecases/get_guest_home_data_usecase.dart`

- [`class GetGuestHomeDataUseCase`](../lib/features/guest_home/domain/usecases/get_guest_home_data_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get guest home data use case`.
- [`GetGuestHomeDataUseCase(this._repository)`](../lib/features/guest_home/domain/usecases/get_guest_home_data_usecase.dart#L8) — ينشئ كائنًا من `GetGuestHomeDataUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<GuestHomeResponseModel>> call({double? latitude, double? longitude})`](../lib/features/guest_home/domain/usecases/get_guest_home_data_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/guest_home/presentation/cubit/guest_home_cubit.dart`

- [`class GuestHomeCubit`](../lib/features/guest_home/presentation/cubit/guest_home_cubit.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `guest home cubit`.
- [`GuestHomeCubit(this._getGuestHomeDataUseCase, this._locationRepository)`](../lib/features/guest_home/presentation/cubit/guest_home_cubit.dart#L11) — ينشئ كائنًا من `GuestHomeCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> getGuestHomeData()`](../lib/features/guest_home/presentation/cubit/guest_home_cubit.dart#L14) — يجلب `get guest home data` من مصدر البيانات المناسب داخل `GuestHomeCubit`.

### `features/guest_home/presentation/cubit/guest_home_state.dart`

- [`class GuestHomeState`](../lib/features/guest_home/presentation/cubit/guest_home_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `guest home state`.
- [`const factory GuestHomeState.initial()`](../lib/features/guest_home/presentation/cubit/guest_home_state.dart#L8) — ينشئ كائنًا من `GuestHomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory GuestHomeState.loading()`](../lib/features/guest_home/presentation/cubit/guest_home_state.dart#L9) — ينشئ كائنًا من `GuestHomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory GuestHomeState.success(GuestHomeResponseModel data)`](../lib/features/guest_home/presentation/cubit/guest_home_state.dart#L10) — ينشئ كائنًا من `GuestHomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory GuestHomeState.failed(String error)`](../lib/features/guest_home/presentation/cubit/guest_home_state.dart#L11) — ينشئ كائنًا من `GuestHomeState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/guest_home/presentation/mappers/guest_home_mappers.dart`

- [`List<ProviderModel> mapGuestProviders(List<GuestNearestProvider> raw)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L6) — يحوّل `map guest providers` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`List<PromoBanner> mapGuestPromoBanners(List<GuestSlider> raw)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L23) — يحوّل `map guest promo banners` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`List<FeaturedServiceModel> mapGuestPackages(List<GuestPackage> raw)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L35) — يحوّل `map guest packages` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`bool _hasAnyText(List<String?> values)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L63) — **خاص** — يفحص شرط `has any text` ويعيد النتيجة داخل هذا الملف.
- [`bool _hasText(String? value)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L65) — **خاص** — يفحص شرط `has text` ويعيد النتيجة داخل هذا الملف.
- [`String _textOrEmpty(String? value)`](../lib/features/guest_home/presentation/mappers/guest_home_mappers.dart#L67) — **خاص** — ينفّذ منطق `text or empty` داخل هذا الملف.

### `features/guest_home/presentation/pages/guest_home_screen.dart`

- [`class GuestHomeScreen`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L24) — الكلاس الذي يمثل شاشة `guest home screen`.
- [`const GuestHomeScreen({super.key})`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L25) — ينشئ كائنًا من `GuestHomeScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<GuestHomeScreen> createState()`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L27) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _GuestHomeScreenState`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L31) — **خاص** — الكلاس الذي يمثل شاشة `guest home screen state`.
- [`void initState()`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L35) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L48) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildShellScrollView({required Widget child, List<PromoBanner> banners = const []})`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L95) — **خاص** — ينفّذ منطق `build shell scroll view` داخل `_GuestHomeScreenState`.
- [`class _GuestHomeHeader`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L117) — **خاص** — الكلاس الذي يمثل شاشة `guest home header`.
- [`const _GuestHomeHeader()`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L118) — **خاص** — ينشئ كائنًا من `GuestHomeHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L120) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _GuestHomeSuccessContent`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L169) — **خاص** — الكلاس الذي يمثل شاشة `guest home success content`.
- [`const _GuestHomeSuccessContent({required this.providers, required this.packages})`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L173) — **خاص** — ينشئ كائنًا من `GuestHomeSuccessContent` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/guest_home/presentation/pages/guest_home_screen.dart#L178) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: help_center

### `features/help_center/presentation/pages/help_center_screen.dart`

- [`class HelpCenterScreen`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L9) — الكلاس الذي يمثل شاشة `help center screen`.
- [`const HelpCenterScreen({super.key})`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L10) — ينشئ كائنًا من `HelpCenterScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ContactTile`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L163) — **خاص** — الكلاس الذي يمثل شاشة `contact tile`.
- [`const _ContactTile({required this.icon, required this.iconColor, required this.bgColor, required this.label, required this.value, this.showDivider = true, required this.onTap})`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L172) — **خاص** — ينشئ كائنًا من `ContactTile` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/help_center/presentation/pages/help_center_screen.dart#L182) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: home

### `features/home/data/home_mock_data.dart`

- [`class QuickAction`](../lib/features/home/data/home_mock_data.dart#L1) — الكلاس الذي يمثل بيانات `quick action` وينقلها بين الطبقات.
- [`const QuickAction({required this.labelKey, required this.assetPath})`](../lib/features/home/data/home_mock_data.dart#L5) — ينشئ كائنًا من `QuickAction` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class PromoBanner`](../lib/features/home/data/home_mock_data.dart#L8) — الكلاس الذي يمثل بيانات `promo banner` وينقلها بين الطبقات.
- [`const PromoBanner({this.providerId, required this.imageUrl, required this.providerLogoUrl, required this.title, required this.subtitle})`](../lib/features/home/data/home_mock_data.dart#L15) — ينشئ كائنًا من `PromoBanner` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class HomeMockData`](../lib/features/home/data/home_mock_data.dart#L24) — الكلاس الذي يمثل بيانات `home mock data` وينقلها بين الطبقات.

### `features/home/data/models/home_response_model.dart`

- [`class HomeResponseModel`](../lib/features/home/data/models/home_response_model.dart#L5) — الكلاس الذي يمثل بيانات `home response model` وينقلها بين الطبقات.
- [`const HomeResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/home/data/models/home_response_model.dart#L13) — ينشئ كائنًا من `HomeResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomeResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L21) — ينشئ كائنًا من `HomeResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L32) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`List<String>? _stringList(dynamic value)`](../lib/features/home/data/models/home_response_model.dart#L35) — **خاص** — ينفّذ منطق `string list` داخل هذا الملف.
- [`String? _stringValue(dynamic value)`](../lib/features/home/data/models/home_response_model.dart#L41) — **خاص** — ينفّذ منطق `string value` داخل هذا الملف.
- [`int? _intValue(dynamic value)`](../lib/features/home/data/models/home_response_model.dart#L43) — **خاص** — ينفّذ منطق `int value` داخل هذا الملف.
- [`double? _doubleValue(dynamic value)`](../lib/features/home/data/models/home_response_model.dart#L50) — **خاص** — ينفّذ منطق `double value` داخل هذا الملف.
- [`class HomeDataModel`](../lib/features/home/data/models/home_response_model.dart#L57) — الكلاس الذي يمثل بيانات `home data model` وينقلها بين الطبقات.
- [`const HomeDataModel({this.sliders, this.pendingAppointments, this.nearestProviders, this.packages})`](../lib/features/home/data/models/home_response_model.dart#L64) — ينشئ كائنًا من `HomeDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomeDataModel.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L71) — ينشئ كائنًا من `HomeDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L74) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class HomeSlider`](../lib/features/home/data/models/home_response_model.dart#L77) — الكلاس الذي يمثل بيانات `home slider` وينقلها بين الطبقات.
- [`const HomeSlider({this.id, this.imageUrl, this.providerId, this.providerName})`](../lib/features/home/data/models/home_response_model.dart#L84) — ينشئ كائنًا من `HomeSlider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomeSlider.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L91) — ينشئ كائنًا من `HomeSlider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L98) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class HomePendingAppointment`](../lib/features/home/data/models/home_response_model.dart#L101) — الكلاس الذي يمثل بيانات `home pending appointment` وينقلها بين الطبقات.
- [`const HomePendingAppointment({this.invoiceId, this.providerId, this.providerBranchId, this.providerName, this.providerImageUrl, this.branchName, this.service, this.status, this.date})`](../lib/features/home/data/models/home_response_model.dart#L113) — ينشئ كائنًا من `HomePendingAppointment` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomePendingAppointment.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L125) — ينشئ كائنًا من `HomePendingAppointment` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L138) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class HomeNearestProvider`](../lib/features/home/data/models/home_response_model.dart#L141) — الكلاس الذي يمثل بيانات `home nearest provider` وينقلها بين الطبقات.
- [`const HomeNearestProvider({this.providerId, this.providerBranchId, this.providerName, this.providerImageUrl, this.branchName, this.fullAddress, this.mapUrl, this.distanceKm})`](../lib/features/home/data/models/home_response_model.dart#L152) — ينشئ كائنًا من `HomeNearestProvider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomeNearestProvider.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L163) — ينشئ كائنًا من `HomeNearestProvider` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L175) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class HomePackage`](../lib/features/home/data/models/home_response_model.dart#L178) — الكلاس الذي يمثل بيانات `home package` وينقلها بين الطبقات.
- [`const HomePackage({this.packageId, this.providerId, this.providerBranchId, this.providerName, this.name, this.imageUrl, this.description, this.priceBefore, this.priceAfter, this.discountPercentage, this.servicesCount})`](../lib/features/home/data/models/home_response_model.dart#L192) — ينشئ كائنًا من `HomePackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory HomePackage.fromJson(Map<String, dynamic> json)`](../lib/features/home/data/models/home_response_model.dart#L206) — ينشئ كائنًا من `HomePackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/home/data/models/home_response_model.dart#L220) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/home/domain/models/appointment_model.dart`

- [`class AppointmentModel`](../lib/features/home/domain/models/appointment_model.dart#L1) — الكلاس الذي يمثل بيانات `appointment model` وينقلها بين الطبقات.
- [`const AppointmentModel({this.invoiceId, this.providerId, required this.providerLogoUrl, required this.providerName, required this.service, required this.branch, required this.status, required this.date})`](../lib/features/home/domain/models/appointment_model.dart#L11) — ينشئ كائنًا من `AppointmentModel` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/home/domain/models/featured_service_model.dart`

- [`class FeaturedServiceModel`](../lib/features/home/domain/models/featured_service_model.dart#L1) — الكلاس الذي يمثل بيانات `featured service model` وينقلها بين الطبقات.
- [`const FeaturedServiceModel({this.packageId, this.providerId, this.providerBranchId, required this.imageUrl, required this.providerLogoUrl, required this.providerName, required this.serviceName, required this.location, required this.originalPrice, required this.discountedPrice, required this.rating, required this.reviewCount})`](../lib/features/home/domain/models/featured_service_model.dart#L15) — ينشئ كائنًا من `FeaturedServiceModel` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/home/domain/models/home_failure.dart`

- [`enum HomeFailureType`](../lib/features/home/domain/models/home_failure.dart#L3) — يعرّف القيم الثابتة الخاصة بـ `home failure type`.
- [`extension HomeFailureTypeCode`](../lib/features/home/domain/models/home_failure.dart#L15) — يضيف وظائف مساعدة إلى نوع موجود دون تعديل تعريفه.
- [`String get code`](../lib/features/home/domain/models/home_failure.dart#L16) — ينفّذ منطق `code` داخل `HomeFailureTypeCode`.
- [`HomeFailureType homeFailureFromCode(String code)`](../lib/features/home/domain/models/home_failure.dart#L19) — ينفّذ منطق `home failure from code` داخل هذا الملف.
- [`HomeFailureType homeFailureFromAppFailure(AppFailure failure)`](../lib/features/home/domain/models/home_failure.dart#L27) — ينفّذ منطق `home failure from app failure` داخل هذا الملف.

### `features/home/domain/models/provider_model.dart`

- [`class ProviderModel`](../lib/features/home/domain/models/provider_model.dart#L1) — الكلاس الذي يمثل بيانات `provider model` وينقلها بين الطبقات.
- [`const ProviderModel({this.providerId, required this.imageUrl, required this.name, required this.rating, required this.reviewCount, required this.type, required this.location, this.badges = const [], this.mapUrl = '', this.distanceKm})`](../lib/features/home/domain/models/provider_model.dart#L13) — ينشئ كائنًا من `ProviderModel` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/home/domain/usecases/get_home_data_usecase.dart`

- [`class GetHomeDataUseCase`](../lib/features/home/domain/usecases/get_home_data_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get home data use case`.
- [`GetHomeDataUseCase(this._repository)`](../lib/features/home/domain/usecases/get_home_data_usecase.dart#L8) — ينشئ كائنًا من `GetHomeDataUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<HomeResponseModel>> call({double? latitude, double? longitude})`](../lib/features/home/domain/usecases/get_home_data_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/home/presentation/cubit/home_cubit.dart`

- [`class HomeCubit`](../lib/features/home/presentation/cubit/home_cubit.dart#L11) — الكلاس الذي يدير حالة وتفاعلات `home cubit`.
- [`HomeCubit(this._getHomeDataUseCase, this._locationRepository, this._locationService)`](../lib/features/home/presentation/cubit/home_cubit.dart#L19) — ينشئ كائنًا من `HomeCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> getHomeData({bool refresh = false})`](../lib/features/home/presentation/cubit/home_cubit.dart#L25) — يجلب `get home data` من مصدر البيانات المناسب داخل `HomeCubit`.
- [`Future<void> _performHomeLoad({required bool refresh})`](../lib/features/home/presentation/cubit/home_cubit.dart#L40) — **خاص** — ينفّذ منطق `perform home load` داخل `HomeCubit`.

### `features/home/presentation/cubit/home_state.dart`

- [`class HomeState`](../lib/features/home/presentation/cubit/home_state.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `home state`.
- [`const factory HomeState.initial()`](../lib/features/home/presentation/cubit/home_state.dart#L9) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory HomeState.loading()`](../lib/features/home/presentation/cubit/home_state.dart#L10) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory HomeState.success(HomeResponseModel data)`](../lib/features/home/presentation/cubit/home_state.dart#L11) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory HomeState.failed(HomeFailureType failure, {@Default(false) bool isRetrying})`](../lib/features/home/presentation/cubit/home_state.dart#L12) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory HomeState.refreshing(HomeResponseModel data)`](../lib/features/home/presentation/cubit/home_state.dart#L16) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory HomeState.refreshFailed(HomeResponseModel data, HomeFailureType failure)`](../lib/features/home/presentation/cubit/home_state.dart#L17) — ينشئ كائنًا من `HomeState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/home/presentation/cubit/location_cubit.dart`

- [`class LocationCubit`](../lib/features/home/presentation/cubit/location_cubit.dart#L10) — الكلاس الذي يدير حالة وتفاعلات `location cubit`.
- [`LocationCubit(this._locationRepository, this._locationService)`](../lib/features/home/presentation/cubit/location_cubit.dart#L17) — ينشئ كائنًا من `LocationCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadLocation()`](../lib/features/home/presentation/cubit/location_cubit.dart#L20) — يحمّل `load location` ويحدّث الحالة المرتبطة داخل `LocationCubit`.
- [`Future<void> refreshLocation()`](../lib/features/home/presentation/cubit/location_cubit.dart#L24) — يعيد تحميل أو محاولة `refresh location` داخل `LocationCubit`.
- [`Future<void> retryLocation()`](../lib/features/home/presentation/cubit/location_cubit.dart#L28) — يعيد تحميل أو محاولة `retry location` داخل `LocationCubit`.
- [`Future<void> _resolveLocationName({required bool clearCache})`](../lib/features/home/presentation/cubit/location_cubit.dart#L67) — **خاص** — ينفّذ منطق `resolve location name` داخل `LocationCubit`.
- [`String? _locationNameFromPlacemarks(List<Placemark> placemarks)`](../lib/features/home/presentation/cubit/location_cubit.dart#L137) — **خاص** — ينفّذ منطق `location name from placemarks` داخل `LocationCubit`.
- [`String _fallbackLocationName(double latitude, double longitude)`](../lib/features/home/presentation/cubit/location_cubit.dart#L162) — **خاص** — ينفّذ منطق `fallback location name` داخل `LocationCubit`.

### `features/home/presentation/cubit/location_state.dart`

- [`class LocationState`](../lib/features/home/presentation/cubit/location_state.dart#L3) — الكلاس الذي يدير حالة وتفاعلات `location state`.
- [`const LocationState()`](../lib/features/home/presentation/cubit/location_state.dart#L4) — ينشئ كائنًا من `LocationState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`List<Object?> get props`](../lib/features/home/presentation/cubit/location_state.dart#L6) — ينفّذ منطق `props` داخل `LocationState`.
- [`class LocationInitial`](../lib/features/home/presentation/cubit/location_state.dart#L10) — الكلاس الذي يدير حالة وتفاعلات `location initial`.
- [`const LocationInitial()`](../lib/features/home/presentation/cubit/location_state.dart#L11) — ينشئ كائنًا من `LocationInitial` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class LocationLoading`](../lib/features/home/presentation/cubit/location_state.dart#L14) — الكلاس الذي يدير حالة وتفاعلات `location loading`.
- [`const LocationLoading()`](../lib/features/home/presentation/cubit/location_state.dart#L15) — ينشئ كائنًا من `LocationLoading` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class LocationLoaded`](../lib/features/home/presentation/cubit/location_state.dart#L18) — الكلاس الذي يدير حالة وتفاعلات `location loaded`.
- [`const LocationLoaded({required this.name, required this.latitude, required this.longitude})`](../lib/features/home/presentation/cubit/location_state.dart#L23) — ينشئ كائنًا من `LocationLoaded` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`List<Object?> get props`](../lib/features/home/presentation/cubit/location_state.dart#L29) — ينفّذ منطق `props` داخل `LocationLoaded`.
- [`class LocationError`](../lib/features/home/presentation/cubit/location_state.dart#L33) — الكلاس الذي يدير حالة وتفاعلات `location error`.
- [`const LocationError(this.message)`](../lib/features/home/presentation/cubit/location_state.dart#L36) — ينشئ كائنًا من `LocationError` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`List<Object?> get props`](../lib/features/home/presentation/cubit/location_state.dart#L38) — ينفّذ منطق `props` داخل `LocationError`.

### `features/home/presentation/mappers/home_mappers.dart`

- [`List<ProviderModel> mapProviders(List<HomeNearestProvider> raw)`](../lib/features/home/presentation/mappers/home_mappers.dart#L7) — يحوّل `map providers` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`List<AppointmentModel> mapAppointments(List<HomePendingAppointment> raw)`](../lib/features/home/presentation/mappers/home_mappers.dart#L27) — يحوّل `map appointments` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`List<PromoBanner> mapPromoBanners(List<HomeSlider> raw)`](../lib/features/home/presentation/mappers/home_mappers.dart#L53) — يحوّل `map promo banners` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`List<FeaturedServiceModel> mapPackages(List<HomePackage> raw)`](../lib/features/home/presentation/mappers/home_mappers.dart#L65) — يحوّل `map packages` بين طبقات أو صيغ البيانات داخل هذا الملف.
- [`bool _hasAnyText(List<String?> values)`](../lib/features/home/presentation/mappers/home_mappers.dart#L94) — **خاص** — يفحص شرط `has any text` ويعيد النتيجة داخل هذا الملف.
- [`bool _hasText(String? value)`](../lib/features/home/presentation/mappers/home_mappers.dart#L96) — **خاص** — يفحص شرط `has text` ويعيد النتيجة داخل هذا الملف.
- [`String _textOrEmpty(String? value)`](../lib/features/home/presentation/mappers/home_mappers.dart#L98) — **خاص** — ينفّذ منطق `text or empty` داخل هذا الملف.
- [`String _appointmentStatusText(String? status)`](../lib/features/home/presentation/mappers/home_mappers.dart#L100) — **خاص** — ينفّذ منطق `appointment status text` داخل هذا الملف.

### `features/home/presentation/pages/home_screen.dart`

- [`class HomeScreen`](../lib/features/home/presentation/pages/home_screen.dart#L39) — الكلاس الذي يمثل شاشة `home screen`.
- [`const HomeScreen({super.key, this.initialIndex = 0})`](../lib/features/home/presentation/pages/home_screen.dart#L42) — ينشئ كائنًا من `HomeScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<HomeScreen> createState()`](../lib/features/home/presentation/pages/home_screen.dart#L44) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _HomeScreenState`](../lib/features/home/presentation/pages/home_screen.dart#L48) — **خاص** — الكلاس الذي يمثل شاشة `home screen state`.
- [`void initState()`](../lib/features/home/presentation/pages/home_screen.dart#L53) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/pages/home_screen.dart#L64) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _HomeBody`](../lib/features/home/presentation/pages/home_screen.dart#L179) — **خاص** — الكلاس الذي يمثل شاشة `home body`.
- [`const _HomeBody({required this.onNavigateToTab})`](../lib/features/home/presentation/pages/home_screen.dart#L182) — **خاص** — ينشئ كائنًا من `HomeBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`void _openAllProviders(BuildContext context)`](../lib/features/home/presentation/pages/home_screen.dart#L184) — **خاص** — يعرض أو يفتح `open all providers` داخل `_HomeBody`.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/pages/home_screen.dart#L188) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildLoadedView(BuildContext context, HomeResponseModel data, {bool isRefreshing = false})`](../lib/features/home/presentation/pages/home_screen.dart#L232) — **خاص** — ينفّذ منطق `build loaded view` داخل `_HomeBody`.
- [`Widget _buildShellScrollView({required List<Widget> slivers, List<PromoBanner> banners = const [], bool isRefreshing = false})`](../lib/features/home/presentation/pages/home_screen.dart#L289) — **خاص** — ينفّذ منطق `build shell scroll view` داخل `_HomeBody`.
- [`class _ProfileBody`](../lib/features/home/presentation/pages/home_screen.dart#L326) — **خاص** — الكلاس الذي يمثل شاشة `profile body`.
- [`const _ProfileBody()`](../lib/features/home/presentation/pages/home_screen.dart#L327) — **خاص** — ينشئ كائنًا من `ProfileBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_ProfileBody> createState()`](../lib/features/home/presentation/pages/home_screen.dart#L329) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ProfileBodyState`](../lib/features/home/presentation/pages/home_screen.dart#L333) — **خاص** — الكلاس الذي يمثل شاشة `profile body state`.
- [`void initState()`](../lib/features/home/presentation/pages/home_screen.dart#L334) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onProfileSummaryRefresh()`](../lib/features/home/presentation/pages/home_screen.dart#L342) — **خاص** — يعالج حدث `on profile summary refresh` داخل `_ProfileBodyState`.
- [`void dispose()`](../lib/features/home/presentation/pages/home_screen.dart#L347) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/pages/home_screen.dart#L355) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/activity/activity_empty_view.dart`

- [`class ActivityEmptyView`](../lib/features/home/presentation/widgets/activity/activity_empty_view.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ActivityEmptyView({super.key, required this.title, required this.message, required this.icon})`](../lib/features/home/presentation/widgets/activity/activity_empty_view.dart#L12) — ينشئ كائنًا من `ActivityEmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity/activity_empty_view.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/activity/activity_error_view.dart`

- [`class ActivityErrorView`](../lib/features/home/presentation/widgets/activity/activity_error_view.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ActivityErrorView({super.key, required this.error, required this.onRetry})`](../lib/features/home/presentation/widgets/activity/activity_error_view.dart#L12) — ينشئ كائنًا من `ActivityErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity/activity_error_view.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/activity/invoice_action_button.dart`

- [`class InvoiceActionButton`](../lib/features/home/presentation/widgets/activity/invoice_action_button.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const InvoiceActionButton({super.key, required this.item})`](../lib/features/home/presentation/widgets/activity/invoice_action_button.dart#L16) — ينشئ كائنًا من `InvoiceActionButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity/invoice_action_button.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/activity/invoice_card.dart`

- [`class InvoiceCard`](../lib/features/home/presentation/widgets/activity/invoice_card.dart#L16) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const InvoiceCard({super.key, required this.item})`](../lib/features/home/presentation/widgets/activity/invoice_card.dart#L19) — ينشئ كائنًا من `InvoiceCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity/invoice_card.dart#L21) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _providerInitial()`](../lib/features/home/presentation/widgets/activity/invoice_card.dart#L205) — **خاص** — ينفّذ منطق `provider initial` داخل `InvoiceCard`.
- [`double? _amount(InvoiceItem item)`](../lib/features/home/presentation/widgets/activity/invoice_card.dart#L213) — **خاص** — ينفّذ منطق `amount` داخل هذا الملف.

### `features/home/presentation/widgets/activity/invoice_list.dart`

- [`class InvoiceList`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const InvoiceList({super.key, required this.items, required this.emptyTitleKey, required this.emptyMessageKey, required this.emptyIcon, required this.isLoadingMore, required this.hasMore})`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L20) — ينشئ كائنًا من `InvoiceList` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<InvoiceList> createState()`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L30) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class InvoiceListState`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L34) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L37) — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void didUpdateWidget(covariant InvoiceList oldWidget)`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L43) — يتعامل مع تغيّر إعدادات الـ widget مع الاحتفاظ بالحالة.
- [`void dispose()`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L53) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onScroll()`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L61) — **خاص** — يعالج حدث `on scroll` داخل `InvoiceListState`.
- [`void _maybePrefetchMore()`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L69) — **خاص** — ينفّذ منطق `maybe prefetch more` داخل `InvoiceListState`.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L85) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class TabScope`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L133) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const TabScope({super.key, required this.tab, required super.child})`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L135) — ينشئ كائنًا من `TabScope` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`static int of(BuildContext context)`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L137) — ينفّذ منطق `of` داخل `TabScope`.
- [`bool updateShouldNotify(TabScope oldWidget)`](../lib/features/home/presentation/widgets/activity/invoice_list.dart#L141) — يحدّث `update should notify` داخل `TabScope`.

### `features/home/presentation/widgets/activity_screen.dart`

- [`class ActivityScreen`](../lib/features/home/presentation/widgets/activity_screen.dart#L17) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ActivityScreen({super.key})`](../lib/features/home/presentation/widgets/activity_screen.dart#L18) — ينشئ كائنًا من `ActivityScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ActivityScreen> createState()`](../lib/features/home/presentation/widgets/activity_screen.dart#L20) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ActivityScreenState`](../lib/features/home/presentation/widgets/activity_screen.dart#L24) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/home/presentation/widgets/activity_screen.dart#L28) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onInvoicesRefresh()`](../lib/features/home/presentation/widgets/activity_screen.dart#L43) — **خاص** — يعالج حدث `on invoices refresh` داخل `_ActivityScreenState`.
- [`void dispose()`](../lib/features/home/presentation/widgets/activity_screen.dart#L51) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onTabChanged()`](../lib/features/home/presentation/widgets/activity_screen.dart#L59) — **خاص** — يعالج حدث `on tab changed` داخل `_ActivityScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/activity_screen.dart#L65) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/ecard_preview_card.dart`

- [`class ECardPreviewCard`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ECardPreviewCard({super.key})`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L12) — ينشئ كائنًا من `ECardPreviewCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ECardPreviewCard> createState()`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L14) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ECardPreviewCardState`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L18) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L19) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L28) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _MediCardPreview`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L47) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _MediCardPreview({required this.card})`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L50) — **خاص** — ينشئ كائنًا من `MediCardPreview` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/ecard_preview_card.dart#L55) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/featured_service_card.dart`

- [`class FeaturedServiceCard`](../lib/features/home/presentation/widgets/featured_service_card.dart#L16) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const FeaturedServiceCard({super.key, required this.service})`](../lib/features/home/presentation/widgets/featured_service_card.dart#L19) — ينشئ كائنًا من `FeaturedServiceCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<FeaturedServiceCard> createState()`](../lib/features/home/presentation/widgets/featured_service_card.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _FeaturedServiceCardState`](../lib/features/home/presentation/widgets/featured_service_card.dart#L25) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`FeaturedServiceModel get service`](../lib/features/home/presentation/widgets/featured_service_card.dart#L28) — **خاص** — ينفّذ منطق `service` داخل `_FeaturedServiceCardState`.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L30) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> _openPackageDetails(BuildContext cardContext)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L255) — **خاص** — يعرض أو يفتح `open package details` داخل `_FeaturedServiceCardState`.
- [`Future<void> _bookPackage(BuildContext context)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L274) — **خاص** — ينفّذ منطق `book package` داخل `_FeaturedServiceCardState`.
- [`class _PackageDetailsSheet`](../lib/features/home/presentation/widgets/featured_service_card.dart#L310) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _PackageDetailsSheet({required this.packageId, required this.fallback, required this.onBook})`](../lib/features/home/presentation/widgets/featured_service_card.dart#L315) — **خاص** — ينشئ كائنًا من `PackageDetailsSheet` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_PackageDetailsSheet> createState()`](../lib/features/home/presentation/widgets/featured_service_card.dart#L321) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _PackageDetailsSheetState`](../lib/features/home/presentation/widgets/featured_service_card.dart#L325) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/home/presentation/widgets/featured_service_card.dart#L328) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L336) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _PackageDetailsSheetContent`](../lib/features/home/presentation/widgets/featured_service_card.dart#L378) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _PackageDetailsSheetContent({required this.details, required this.fallback, required this.onBook})`](../lib/features/home/presentation/widgets/featured_service_card.dart#L383) — **خاص** — ينشئ كائنًا من `PackageDetailsSheetContent` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L389) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _imageUrl(String value)`](../lib/features/home/presentation/widgets/featured_service_card.dart#L515) — **خاص** — ينفّذ منطق `image url` داخل `_PackageDetailsSheetContent`.

### `features/home/presentation/widgets/featured_services_section.dart`

- [`class FeaturedServicesSection`](../lib/features/home/presentation/widgets/featured_services_section.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const FeaturedServicesSection({super.key, required this.services, this.onViewAll})`](../lib/features/home/presentation/widgets/featured_services_section.dart#L12) — ينشئ كائنًا من `FeaturedServicesSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/featured_services_section.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_bottom_nav.dart`

- [`class HomeBottomNav`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeBottomNav({super.key, required this.currentIndex, required this.onTap})`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L10) — ينشئ كائنًا من `HomeBottomNav` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _NavItem`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L68) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _NavItem({required this.icon, required this.labelKey})`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L71) — **خاص** — ينشئ كائنًا من `NavItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class _NavColumn`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L74) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _NavColumn({required this.item, required this.isSelected, required this.onTap})`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L79) — **خاص** — ينشئ كائنًا من `NavColumn` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_bottom_nav.dart#L85) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_empty_view.dart`

- [`class HomeEmptyView`](../lib/features/home/presentation/widgets/home_empty_view.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeEmptyView({super.key})`](../lib/features/home/presentation/widgets/home_empty_view.dart#L8) — ينشئ كائنًا من `HomeEmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_empty_view.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_error_view.dart`

- [`class HomeErrorView`](../lib/features/home/presentation/widgets/home_error_view.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeErrorView({super.key, this.failure = HomeFailureType.unknown, this.message, required this.onRetry, this.isRetrying = false})`](../lib/features/home/presentation/widgets/home_error_view.dart#L16) — ينشئ كائنًا من `HomeErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_error_view.dart#L24) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_header.dart`

- [`class HomeHeader`](../lib/features/home/presentation/widgets/home_header.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeHeader({super.key})`](../lib/features/home/presentation/widgets/home_header.dart#L13) — ينشئ كائنًا من `HomeHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_header.dart#L15) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _HeaderTopRow`](../lib/features/home/presentation/widgets/home_header.dart#L47) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _HeaderTopRow()`](../lib/features/home/presentation/widgets/home_header.dart#L48) — **خاص** — ينشئ كائنًا من `HeaderTopRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_header.dart#L50) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _locationText(LocationState state, BuildContext context)`](../lib/features/home/presentation/widgets/home_header.dart#L84) — **خاص** — ينفّذ منطق `location text` داخل `_HeaderTopRow`.
- [`class _HeaderSearchBar`](../lib/features/home/presentation/widgets/home_header.dart#L93) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _HeaderSearchBar()`](../lib/features/home/presentation/widgets/home_header.dart#L94) — **خاص** — ينشئ كائنًا من `HeaderSearchBar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_header.dart#L96) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_section_header.dart`

- [`class HomeSectionHeader`](../lib/features/home/presentation/widgets/home_section_header.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeSectionHeader({super.key, required this.title, this.onViewAll})`](../lib/features/home/presentation/widgets/home_section_header.dart#L13) — ينشئ كائنًا من `HomeSectionHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_section_header.dart#L15) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/home_shimmer.dart`

- [`class HomeShimmer`](../lib/features/home/presentation/widgets/home_shimmer.dart#L5) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const HomeShimmer({super.key})`](../lib/features/home/presentation/widgets/home_shimmer.dart#L8) — ينشئ كائنًا من `HomeShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_shimmer.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SectionTitleShimmer`](../lib/features/home/presentation/widgets/home_shimmer.dart#L119) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/home_shimmer.dart#L121) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/location_display.dart`

- [`class LocationDisplay`](../lib/features/home/presentation/widgets/location_display.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const LocationDisplay({super.key, required this.text, required this.onTap})`](../lib/features/home/presentation/widgets/location_display.dart#L10) — ينشئ كائنًا من `LocationDisplay` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/location_display.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/nearest_provider_card.dart`

- [`class NearestProviderCard`](../lib/features/home/presentation/widgets/nearest_provider_card.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const NearestProviderCard({super.key, required this.provider})`](../lib/features/home/presentation/widgets/nearest_provider_card.dart#L14) — ينشئ كائنًا من `NearestProviderCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/nearest_provider_card.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/nearest_section.dart`

- [`class NearestSection`](../lib/features/home/presentation/widgets/nearest_section.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const NearestSection({super.key, required this.providers, this.onViewAll})`](../lib/features/home/presentation/widgets/nearest_section.dart#L12) — ينشئ كائنًا من `NearestSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/nearest_section.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/order_placed_dialog.dart`

- [`class OrderPlacedDialog`](../lib/features/home/presentation/widgets/order_placed_dialog.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`static Future<void> maybeShow(BuildContext context, {required String? orderNumber})`](../lib/features/home/presentation/widgets/order_placed_dialog.dart#L11) — ينفّذ منطق `maybe show` داخل `OrderPlacedDialog`.
- [`class _OrderPlacedDialog`](../lib/features/home/presentation/widgets/order_placed_dialog.dart#L27) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _OrderPlacedDialog({required this.orderNumber})`](../lib/features/home/presentation/widgets/order_placed_dialog.dart#L30) — **خاص** — ينشئ كائنًا من `OrderPlacedDialog` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/order_placed_dialog.dart#L32) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/pending_appointment_card.dart`

- [`class PendingAppointmentCard`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PendingAppointmentCard({super.key, required this.appointment})`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L14) — ينشئ كائنًا من `PendingAppointmentCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _StatusBadge`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L164) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _StatusBadge({required this.status})`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L167) — **خاص** — ينشئ كائنًا من `StatusBadge` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L169) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _localizedStatus(String status)`](../lib/features/home/presentation/widgets/pending_appointment_card.dart#L209) — **خاص** — ينفّذ منطق `localized status` داخل `_StatusBadge`.

### `features/home/presentation/widgets/pending_appointment_details_screen.dart`

- [`class PendingAppointmentDetailsScreen`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PendingAppointmentDetailsScreen({super.key, required this.appointment})`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L15) — ينشئ كائنًا من `PendingAppointmentDetailsScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L20) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildProviderAvatar()`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L137) — **خاص** — ينفّذ منطق `build provider avatar` داخل `PendingAppointmentDetailsScreen`.
- [`class _InfoRow`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L165) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _InfoRow({required this.label, required this.value})`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L169) — **خاص** — ينشئ كائنًا من `InfoRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L171) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _StatusBadge`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L208) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _StatusBadge({required this.status})`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L211) — **خاص** — ينشئ كائنًا من `StatusBadge` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L213) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _localizedStatus(String status)`](../lib/features/home/presentation/widgets/pending_appointment_details_screen.dart#L234) — **خاص** — ينفّذ منطق `localized status` داخل `_StatusBadge`.

### `features/home/presentation/widgets/pending_appointments_section.dart`

- [`class PendingAppointmentsSection`](../lib/features/home/presentation/widgets/pending_appointments_section.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PendingAppointmentsSection({super.key, required this.appointments, this.onViewAll})`](../lib/features/home/presentation/widgets/pending_appointments_section.dart#L12) — ينشئ كائنًا من `PendingAppointmentsSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/pending_appointments_section.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/promo_banner.dart`

- [`class PromoBannerWidget`](../lib/features/home/presentation/widgets/promo_banner.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PromoBannerWidget({super.key, required this.banners})`](../lib/features/home/presentation/widgets/promo_banner.dart#L14) — ينشئ كائنًا من `PromoBannerWidget` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<PromoBannerWidget> createState()`](../lib/features/home/presentation/widgets/promo_banner.dart#L16) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _PromoBannerWidgetState`](../lib/features/home/presentation/widgets/promo_banner.dart#L20) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void initState()`](../lib/features/home/presentation/widgets/promo_banner.dart#L25) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _startAutoScroll()`](../lib/features/home/presentation/widgets/promo_banner.dart#L33) — **خاص** — ينفّذ منطق `start auto scroll` داخل `_PromoBannerWidgetState`.
- [`void dispose()`](../lib/features/home/presentation/widgets/promo_banner.dart#L50) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/promo_banner.dart#L57) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/quick_actions_row.dart`

- [`class QuickActionsRow`](../lib/features/home/presentation/widgets/quick_actions_row.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const QuickActionsRow({super.key, required this.actions})`](../lib/features/home/presentation/widgets/quick_actions_row.dart#L12) — ينشئ كائنًا من `QuickActionsRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/quick_actions_row.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`void _onActionTap(BuildContext context, QuickAction action)`](../lib/features/home/presentation/widgets/quick_actions_row.dart#L67) — **خاص** — يعالج حدث `on action tap` داخل `QuickActionsRow`.

### `features/home/presentation/widgets/search_bar_widget.dart`

- [`class SearchBarWidget`](../lib/features/home/presentation/widgets/search_bar_widget.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SearchBarWidget({super.key, this.latitude, this.longitude})`](../lib/features/home/presentation/widgets/search_bar_widget.dart#L12) — ينشئ كائنًا من `SearchBarWidget` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/search_bar_widget.dart#L14) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/home/presentation/widgets/sort_filter.dart`

- [`enum SortOption`](../lib/features/home/presentation/widgets/sort_filter.dart#L6) — يعرّف القيم الثابتة الخاصة بـ `sort option`.
- [`class SortFilterSheet`](../lib/features/home/presentation/widgets/sort_filter.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SortFilterSheet({super.key})`](../lib/features/home/presentation/widgets/sort_filter.dart#L9) — ينشئ كائنًا من `SortFilterSheet` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<SortFilterSheet> createState()`](../lib/features/home/presentation/widgets/sort_filter.dart#L11) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _SortFilterSheetState`](../lib/features/home/presentation/widgets/sort_filter.dart#L15) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/sort_filter.dart#L24) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildCheckItem(String label, SortOption option)`](../lib/features/home/presentation/widgets/sort_filter.dart#L133) — **خاص** — ينفّذ منطق `build check item` داخل `_SortFilterSheetState`.
- [`Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged})`](../lib/features/home/presentation/widgets/sort_filter.dart#L174) — **خاص** — ينفّذ منطق `build dropdown` داخل `_SortFilterSheetState`.

### `features/home/presentation/widgets/summer_promo_dialog.dart`

- [`class SummerPromoDialog`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L4) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`static bool get _isPromoActive`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L12) — **خاص** — يفحص شرط `is promo active` ويعيد النتيجة داخل `SummerPromoDialog`.
- [`static Future<void> maybeShow(BuildContext context)`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L19) — ينفّذ منطق `maybe show` داخل `SummerPromoDialog`.
- [`class _SummerPromoDialog`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L35) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SummerPromoDialog()`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L36) — **خاص** — ينشئ كائنًا من `SummerPromoDialog` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/home/presentation/widgets/summer_promo_dialog.dart#L38) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: notifications

### `features/notifications/data/domain/notification_repo.dart`

- [`class NotificationRepository`](../lib/features/notifications/data/domain/notification_repo.dart#L7) — الكلاس الذي يمثل بيانات `notification repository` وينقلها بين الطبقات.
- [`NotificationRepository(this._service)`](../lib/features/notifications/data/domain/notification_repo.dart#L10) — ينشئ كائنًا من `NotificationRepository` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<String> get _bearerToken`](../lib/features/notifications/data/domain/notification_repo.dart#L12) — **خاص** — ينفّذ منطق `bearer token` داخل `NotificationRepository`.
- [`Future<NotificationData> getNotifications(int pageNumber, int pageSize)`](../lib/features/notifications/data/domain/notification_repo.dart#L19) — يجلب `get notifications` من مصدر البيانات المناسب داخل `NotificationRepository`.
- [`Future<void> markAsRead(int id)`](../lib/features/notifications/data/domain/notification_repo.dart#L30) — يغيّر علامة أو حالة `mark as read` داخل `NotificationRepository`.
- [`Future<void> markAllAsRead()`](../lib/features/notifications/data/domain/notification_repo.dart#L34) — يغيّر علامة أو حالة `mark all as read` داخل `NotificationRepository`.
- [`Future<bool> registerDeviceToken({required String fcmToken, required int platform})`](../lib/features/notifications/data/domain/notification_repo.dart#L38) — يسجّل `register device token` لدى النظام أو الخدمة داخل `NotificationRepository`.

### `features/notifications/data/domain/notification_service.dart`

- [`class NotificationService`](../lib/features/notifications/data/domain/notification_service.dart#L5) — الكلاس الذي يمثل بيانات `notification service` وينقلها بين الطبقات.
- [`NotificationService(this._client)`](../lib/features/notifications/data/domain/notification_service.dart#L8) — ينشئ كائنًا من `NotificationService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<NotificationData> getNotifications(String token, int pageNumber, int pageSize)`](../lib/features/notifications/data/domain/notification_service.dart#L10) — يجلب `get notifications` من مصدر البيانات المناسب داخل `NotificationService`.
- [`Future<void> markAsRead(String token, int id)`](../lib/features/notifications/data/domain/notification_service.dart#L24) — يغيّر علامة أو حالة `mark as read` داخل `NotificationService`.
- [`Future<void> markAllAsRead(String token)`](../lib/features/notifications/data/domain/notification_service.dart#L32) — يغيّر علامة أو حالة `mark all as read` داخل `NotificationService`.
- [`Future<void> registerDeviceToken(String token, {required String fcmToken, required int platform})`](../lib/features/notifications/data/domain/notification_service.dart#L40) — يسجّل `register device token` لدى النظام أو الخدمة داخل `NotificationService`.
- [`String _short(String token)`](../lib/features/notifications/data/domain/notification_service.dart#L68) — **خاص** — ينفّذ منطق `short` داخل هذا الملف.

### `features/notifications/data/domain/use_cases/get_notifications_use_case.dart`

- [`class GetNotificationsUseCase`](../lib/features/notifications/data/domain/use_cases/get_notifications_use_case.dart#L7) — الكلاس الذي يعزل عملية أعمال واحدة: `get notifications use case`.
- [`GetNotificationsUseCase(this._repo)`](../lib/features/notifications/data/domain/use_cases/get_notifications_use_case.dart#L9) — ينشئ كائنًا من `GetNotificationsUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<List<NotificationModel>>> call({required int pageNumber, required int pageSize})`](../lib/features/notifications/data/domain/use_cases/get_notifications_use_case.dart#L11) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart`

- [`class MarkAllNotificationsReadUseCase`](../lib/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `mark all notifications read use case`.
- [`MarkAllNotificationsReadUseCase(this._repo)`](../lib/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart#L8) — ينشئ كائنًا من `MarkAllNotificationsReadUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<void>> call()`](../lib/features/notifications/data/domain/use_cases/mark_all_notifications_read_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart`

- [`class MarkNotificationReadUseCase`](../lib/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart#L6) — الكلاس الذي يعزل عملية أعمال واحدة: `mark notification read use case`.
- [`MarkNotificationReadUseCase(this._repo)`](../lib/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart#L8) — ينشئ كائنًا من `MarkNotificationReadUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<void>> call(int id)`](../lib/features/notifications/data/domain/use_cases/mark_notification_read_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/notifications/data/domain/use_cases/notification_error_message.dart`

- [`String notificationErrorMessage(Object error)`](../lib/features/notifications/data/domain/use_cases/notification_error_message.dart#L7) — ينفّذ منطق `notification error message` داخل هذا الملف.
- [`String? _responseMessage(Object? data)`](../lib/features/notifications/data/domain/use_cases/notification_error_message.dart#L29) — **خاص** — ينفّذ منطق `response message` داخل هذا الملف.
- [`String _failureMessage(AppFailure failure)`](../lib/features/notifications/data/domain/use_cases/notification_error_message.dart#L49) — **خاص** — ينفّذ منطق `failure message` داخل هذا الملف.

### `features/notifications/data/model/api_response.dart`

- [`class ApiResponse`](../lib/features/notifications/data/model/api_response.dart#L5) — الكلاس الذي يمثل بيانات `api response` وينقلها بين الطبقات.
- [`ApiResponse({required this.httpStatusCode, this.errors, required this.succeeded, required this.message, this.data})`](../lib/features/notifications/data/model/api_response.dart#L13) — ينشئ كائنًا من `ApiResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT)`](../lib/features/notifications/data/model/api_response.dart#L21) — ينشئ كائنًا من `ApiResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson(Object? Function(T value) toJsonT)`](../lib/features/notifications/data/model/api_response.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/notifications/data/model/notification_model.dart`

- [`class NotificationModel`](../lib/features/notifications/data/model/notification_model.dart#L5) — الكلاس الذي يمثل بيانات `notification model` وينقلها بين الطبقات.
- [`NotificationModel({required this.id, required this.title, required this.body, required this.imageUrl, required this.isRead, required this.createdAt, this.data})`](../lib/features/notifications/data/model/notification_model.dart#L15) — ينشئ كائنًا من `NotificationModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory NotificationModel.fromJson(Map<String, dynamic> json)`](../lib/features/notifications/data/model/notification_model.dart#L25) — ينشئ كائنًا من `NotificationModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/notifications/data/model/notification_model.dart#L28) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class NotificationData`](../lib/features/notifications/data/model/notification_model.dart#L31) — الكلاس الذي يمثل بيانات `notification data` وينقلها بين الطبقات.
- [`NotificationData({required this.items, required this.pageNumber, required this.pageSize, required this.totalCount, required this.totalPages})`](../lib/features/notifications/data/model/notification_model.dart#L39) — ينشئ كائنًا من `NotificationData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory NotificationData.fromJson(Map<String, dynamic> json)`](../lib/features/notifications/data/model/notification_model.dart#L47) — ينشئ كائنًا من `NotificationData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/notifications/data/model/notification_model.dart#L50) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/notifications/data/notification_client.dart`

- [`class NotificationClient`](../lib/features/notifications/data/notification_client.dart#L8) — الكلاس الذي يمثل بيانات `notification client` وينقلها بين الطبقات.
- [`factory NotificationClient(Dio dio, {String baseUrl})`](../lib/features/notifications/data/notification_client.dart#L10) — ينشئ كائنًا من `NotificationClient` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResponse<NotificationData>> getNotifications(@Header("Authorization") String token, @Query("pageNumber") int pageNumber, @Query("pageSize") int pageSize)`](../lib/features/notifications/data/notification_client.dart#L12) — يجلب `get notifications` من مصدر البيانات المناسب داخل `NotificationClient`.
- [`Future<ApiResponse<dynamic>> sendNotification(@Header("Authorization") String token, @Body() Map<String, dynamic> body)`](../lib/features/notifications/data/notification_client.dart#L19) — يرسل `send notification` إلى الطبقة أو الخدمة المطلوبة داخل `NotificationClient`.
- [`Future<ApiResponse<dynamic>> markAsRead(@Header("Authorization") String token, @Path("id") int id)`](../lib/features/notifications/data/notification_client.dart#L25) — يغيّر علامة أو حالة `mark as read` داخل `NotificationClient`.
- [`Future<ApiResponse<dynamic>> markAllAsRead(@Header("Authorization") String token)`](../lib/features/notifications/data/notification_client.dart#L31) — يغيّر علامة أو حالة `mark all as read` داخل `NotificationClient`.
- [`Future<ApiResponse<dynamic>> registerDeviceToken(@Header("Authorization") String token, @Body() Map<String, dynamic> body)`](../lib/features/notifications/data/notification_client.dart#L36) — يسجّل `register device token` لدى النظام أو الخدمة داخل `NotificationClient`.

### `features/notifications/presentation/cubit/notification_cubit.dart`

- [`class NotificationCubit`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L10) — الكلاس الذي يدير حالة وتفاعلات `notification cubit`.
- [`NotificationCubit(this._getNotificationsUseCase, this._markNotificationReadUseCase, this._markAllNotificationsReadUseCase)`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L17) — ينشئ كائنًا من `NotificationCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> init()`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L23) — ينفّذ منطق `init` داخل `NotificationCubit`.
- [`Future<void> getNotifications()`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L28) — يجلب `get notifications` من مصدر البيانات المناسب داخل `NotificationCubit`.
- [`Future<void> loadMore()`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L42) — يحمّل `load more` ويحدّث الحالة المرتبطة داخل `NotificationCubit`.
- [`Future<void> _fetch({required int page})`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L49) — **خاص** — يجلب `fetch` من مصدر البيانات المناسب داخل `NotificationCubit`.
- [`Future<void> markAsRead(int id)`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L85) — يغيّر علامة أو حالة `mark as read` داخل `NotificationCubit`.
- [`Future<void> markAllAsRead()`](../lib/features/notifications/presentation/cubit/notification_cubit.dart#L139) — يغيّر علامة أو حالة `mark all as read` داخل `NotificationCubit`.

### `features/notifications/presentation/cubit/notification_state.dart`

- [`class NotificationState`](../lib/features/notifications/presentation/cubit/notification_state.dart#L6) — الكلاس الذي يدير حالة وتفاعلات `notification state`.
- [`const factory NotificationState({@Default([]) List<NotificationModel> items, @Default(false) bool isLoading, @Default(false) bool isLoadingMore, @Default(true) bool hasMore, @Default(1) int currentPage, String? error, String? markReadError})`](../lib/features/notifications/presentation/cubit/notification_state.dart#L8) — ينشئ كائنًا من `NotificationState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/notifications/presentation/pages/notifications_screen.dart`

- [`class NotificationsScreen`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L18) — الكلاس الذي يمثل شاشة `notifications screen`.
- [`const NotificationsScreen({super.key})`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L19) — ينشئ كائنًا من `NotificationsScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<NotificationsScreen> createState()`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _NotificationsScreenState`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L25) — **خاص** — الكلاس الذي يمثل شاشة `notifications screen state`.
- [`void initState()`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L30) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L46) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onScroll()`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L55) — **خاص** — يعالج حدث `on scroll` داخل `_NotificationsScreenState`.
- [`Future<void> _openNotification(BuildContext context, NotificationModel notification)`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L64) — **خاص** — يعرض أو يفتح `open notification` داخل `_NotificationsScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L108) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _NotificationsTabsHeader`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L211) — **خاص** — الكلاس الذي يمثل شاشة `notifications tabs header`.
- [`const _NotificationsTabsHeader({required this.selectedIndex, required this.onTabSelected, required this.onMarkAllRead})`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L216) — **خاص** — ينشئ كائنًا من `NotificationsTabsHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L222) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _NotificationTab`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L287) — **خاص** — الكلاس الذي يمثل شاشة `notification tab`.
- [`const _NotificationTab({required this.title, required this.isSelected, required this.onTap})`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L292) — **خاص** — ينشئ كائنًا من `NotificationTab` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L298) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _NotificationsMessage`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L330) — **خاص** — الكلاس الذي يمثل شاشة `notifications message`.
- [`const _NotificationsMessage({required this.icon, required this.title, required this.message, this.actionLabel, this.onAction})`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L337) — **خاص** — ينشئ كائنًا من `NotificationsMessage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/pages/notifications_screen.dart#L345) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/notifications/presentation/widgets/notification_card.dart`

- [`class NotificationCard`](../lib/features/notifications/presentation/widgets/notification_card.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const NotificationCard({super.key, required this.notification, this.onTap, this.onMarkAsRead})`](../lib/features/notifications/presentation/widgets/notification_card.dart#L16) — ينشئ كائنًا من `NotificationCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/widgets/notification_card.dart#L23) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _formatRelativeTime(DateTime dateTime)`](../lib/features/notifications/presentation/widgets/notification_card.dart#L138) — **خاص** — ينسّق `format relative time` للعرض أو الإرسال داخل `NotificationCard`.
- [`class _NotificationImage`](../lib/features/notifications/presentation/widgets/notification_card.dart#L164) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _NotificationImage(this.imageUrl)`](../lib/features/notifications/presentation/widgets/notification_card.dart#L167) — **خاص** — ينشئ كائنًا من `NotificationImage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/widgets/notification_card.dart#L169) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _NotificationFallbackIcon`](../lib/features/notifications/presentation/widgets/notification_card.dart#L190) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _NotificationFallbackIcon()`](../lib/features/notifications/presentation/widgets/notification_card.dart#L191) — **خاص** — ينشئ كائنًا من `NotificationFallbackIcon` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/notifications/presentation/widgets/notification_card.dart#L193) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/notifications/push_notification_service.dart`

- [`Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)`](../lib/features/notifications/push_notification_service.dart#L19) — **خاص** — ينفّذ منطق `firebase messaging background handler` داخل هذا الملف.
- [`class PushNotificationService`](../lib/features/notifications/push_notification_service.dart#L41) — الكلاس الذي يجمع مسؤوليات `push notification service`.
- [`PushNotificationService._()`](../lib/features/notifications/push_notification_service.dart#L43) — ينشئ كائنًا من `PushNotificationService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Stream<NotificationAction> get onNotificationAction`](../lib/features/notifications/push_notification_service.dart#L54) — يعالج حدث `on notification action` داخل `PushNotificationService`.
- [`Stream<String> get onTokenRefresh`](../lib/features/notifications/push_notification_service.dart#L59) — يعالج حدث `on token refresh` داخل `PushNotificationService`.
- [`Stream<RemoteMessage> get onMessageReceived`](../lib/features/notifications/push_notification_service.dart#L64) — يعالج حدث `on message received` داخل `PushNotificationService`.
- [`String? get currentToken`](../lib/features/notifications/push_notification_service.dart#L67) — ينفّذ منطق `current token` داخل `PushNotificationService`.
- [`Future<bool> initialize()`](../lib/features/notifications/push_notification_service.dart#L69) — ينفّذ منطق `initialize` داخل `PushNotificationService`.
- [`Future<bool> _requestPermission()`](../lib/features/notifications/push_notification_service.dart#L120) — **خاص** — ينفّذ منطق `request permission` داخل `PushNotificationService`.
- [`Future<void> setupFlutterNotifications()`](../lib/features/notifications/push_notification_service.dart#L147) — يحدّث `setup flutter notifications` داخل `PushNotificationService`.
- [`Future<void> showNotification(RemoteMessage message)`](../lib/features/notifications/push_notification_service.dart#L229) — يعرض أو يفتح `show notification` داخل `PushNotificationService`.
- [`int _notificationId(RemoteMessage message, {required String? title, required String? body})`](../lib/features/notifications/push_notification_service.dart#L375) — **خاص** — ينفّذ منطق `notification id` داخل `PushNotificationService`.
- [`Future<Uint8List> _downloadBytes(String url)`](../lib/features/notifications/push_notification_service.dart#L399) — **خاص** — ينفّذ منطق `download bytes` داخل `PushNotificationService`.
- [`Color _parseColor(String hex)`](../lib/features/notifications/push_notification_service.dart#L405) — **خاص** — يحلّل `parse color` ويحوّله لصيغة قابلة للاستخدام داخل `PushNotificationService`.
- [`Future<void> _setupMessageHandlers()`](../lib/features/notifications/push_notification_service.dart#L411) — **خاص** — يحدّث `setup message handlers` داخل `PushNotificationService`.
- [`Future<void> _setupTokenHandling()`](../lib/features/notifications/push_notification_service.dart#L449) — **خاص** — يحدّث `setup token handling` داخل `PushNotificationService`.
- [`Future<String?> _waitForApnsToken()`](../lib/features/notifications/push_notification_service.dart#L497) — **خاص** — ينفّذ منطق `wait for apns token` داخل `PushNotificationService`.
- [`Future<bool> registerDeviceToken()`](../lib/features/notifications/push_notification_service.dart#L512) — يسجّل `register device token` لدى النظام أو الخدمة داخل `PushNotificationService`.
- [`Future<String?> _fetchTokenForRegistration()`](../lib/features/notifications/push_notification_service.dart#L566) — **خاص** — يجلب `fetch token for registration` من مصدر البيانات المناسب داخل `PushNotificationService`.
- [`String _short(String token)`](../lib/features/notifications/push_notification_service.dart#L585) — **خاص** — ينفّذ منطق `short` داخل `PushNotificationService`.
- [`static void _handleNotificationTap(NotificationResponse response)`](../lib/features/notifications/push_notification_service.dart#L589) — **خاص** — يعالج حدث `handle notification tap` داخل `PushNotificationService`.
- [`void _handleMessageOpen(RemoteMessage message)`](../lib/features/notifications/push_notification_service.dart#L612) — **خاص** — يعالج حدث `handle message open` داخل `PushNotificationService`.
- [`void _navigateFromPayload(Map<String, dynamic> data)`](../lib/features/notifications/push_notification_service.dart#L624) — **خاص** — ينفّذ الانتقال أو الفتح الخاص بـ `navigate from payload` داخل `PushNotificationService`.
- [`static Future<bool> openNotificationPackage(int packageId)`](../lib/features/notifications/push_notification_service.dart#L658) — يعرض أو يفتح `open notification package` داخل `PushNotificationService`.
- [`Future<void> _openPackageFromNotification(int packageId)`](../lib/features/notifications/push_notification_service.dart#L693) — **خاص** — يعرض أو يفتح `open package from notification` داخل `PushNotificationService`.
- [`static int? _intOrNull(Object? raw)`](../lib/features/notifications/push_notification_service.dart#L700) — **خاص** — ينفّذ منطق `int or null` داخل `PushNotificationService`.
- [`Future<bool> subscribeToTopic(String topic)`](../lib/features/notifications/push_notification_service.dart#L704) — ينفّذ منطق `subscribe to topic` داخل `PushNotificationService`.
- [`Future<bool> unsubscribeFromTopic(String topic)`](../lib/features/notifications/push_notification_service.dart#L716) — ينفّذ منطق `unsubscribe from topic` داخل `PushNotificationService`.
- [`Future<bool> deleteToken()`](../lib/features/notifications/push_notification_service.dart#L728) — يحذف أو يمسح `delete token` داخل `PushNotificationService`.
- [`Future<void> cancelAllNotifications()`](../lib/features/notifications/push_notification_service.dart#L741) — يفحص شرط `cancel all notifications` ويعيد النتيجة داخل `PushNotificationService`.
- [`Future<void> cancelNotification(int id)`](../lib/features/notifications/push_notification_service.dart#L751) — يفحص شرط `cancel notification` ويعيد النتيجة داخل `PushNotificationService`.
- [`Future<List<PendingNotificationRequest>> getPendingNotifications()`](../lib/features/notifications/push_notification_service.dart#L761) — يجلب `get pending notifications` من مصدر البيانات المناسب داخل `PushNotificationService`.
- [`Future<bool> areNotificationsEnabled()`](../lib/features/notifications/push_notification_service.dart#L771) — ينفّذ منطق `are notifications enabled` داخل `PushNotificationService`.
- [`void dispose()`](../lib/features/notifications/push_notification_service.dart#L786) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`class NotificationAction`](../lib/features/notifications/push_notification_service.dart#L795) — الكلاس الذي يجمع مسؤوليات `notification action`.
- [`NotificationAction({required this.type, required this.data, this.actionId, this.messageId})`](../lib/features/notifications/push_notification_service.dart#L802) — ينشئ كائنًا من `NotificationAction` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String toString()`](../lib/features/notifications/push_notification_service.dart#L809) — يعيد تمثيلًا نصيًا للكائن.
- [`enum NotificationActionType`](../lib/features/notifications/push_notification_service.dart#L815) — يعرّف القيم الثابتة الخاصة بـ `notification action type`.


## Feature: packages

### `features/packages/presentation/pages/all_packages_screen.dart`

- [`class AllPackagesScreen`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L16) — الكلاس الذي يمثل شاشة `all packages screen`.
- [`const AllPackagesScreen({super.key})`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L19) — ينشئ كائنًا من `AllPackagesScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AllPackagesScreen> createState()`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L21) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AllPackagesScreenState`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L25) — **خاص** — الكلاس الذي يمثل شاشة `all packages screen state`.
- [`String? get _query`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L36) — **خاص** — ينفّذ منطق `query` داخل `_AllPackagesScreenState`.
- [`void initState()`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L41) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L48) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onSearchChanged(String _)`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L58) — **خاص** — يعالج حدث `on search changed` داخل `_AllPackagesScreenState`.
- [`void _openPackage(BuildContext context, AllPackage item)`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L65) — **خاص** — يعرض أو يفتح `open package` داخل `_AllPackagesScreenState`.
- [`void _onScroll()`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L75) — **خاص** — يعالج حدث `on scroll` داخل `_AllPackagesScreenState`.
- [`Future<void> _load({bool reset = false})`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L83) — **خاص** — يحمّل `load` ويحدّث الحالة المرتبطة داخل `_AllPackagesScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L128) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildBody(bool isArabic)`](../lib/features/packages/presentation/pages/all_packages_screen.dart#L213) — **خاص** — ينفّذ منطق `build body` داخل `_AllPackagesScreenState`.


## Feature: profile

### `features/profile/data/models/change_language_request_model.dart`

- [`class ChangeLanguageRequestModel`](../lib/features/profile/data/models/change_language_request_model.dart#L5) — الكلاس الذي يمثل بيانات `change language request model` وينقلها بين الطبقات.
- [`const ChangeLanguageRequestModel({required this.language})`](../lib/features/profile/data/models/change_language_request_model.dart#L9) — ينشئ كائنًا من `ChangeLanguageRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ChangeLanguageRequestModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/change_language_request_model.dart#L13) — ينشئ كائنًا من `ChangeLanguageRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/change_language_request_model.dart#L16) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/data/models/change_language_response_model.dart`

- [`class ChangeLanguageResponseModel`](../lib/features/profile/data/models/change_language_response_model.dart#L5) — الكلاس الذي يمثل بيانات `change language response model` وينقلها بين الطبقات.
- [`const ChangeLanguageResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/profile/data/models/change_language_response_model.dart#L13) — ينشئ كائنًا من `ChangeLanguageResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ChangeLanguageResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/change_language_response_model.dart#L21) — ينشئ كائنًا من `ChangeLanguageResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/change_language_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/data/models/change_password_request_model.dart`

- [`class ChangePasswordRequestModel`](../lib/features/profile/data/models/change_password_request_model.dart#L1) — الكلاس الذي يمثل بيانات `change password request model` وينقلها بين الطبقات.
- [`const ChangePasswordRequestModel({required this.currentPassword, required this.newPassword, required this.confirmNewPassword})`](../lib/features/profile/data/models/change_password_request_model.dart#L6) — ينشئ كائنًا من `ChangePasswordRequestModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/change_password_request_model.dart#L12) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/data/models/change_password_response_model.dart`

- [`class ChangePasswordResponseModel`](../lib/features/profile/data/models/change_password_response_model.dart#L5) — الكلاس الذي يمثل بيانات `change password response model` وينقلها بين الطبقات.
- [`const ChangePasswordResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.success, this.message, this.token, this.expiresAt, this.data})`](../lib/features/profile/data/models/change_password_response_model.dart#L16) — ينشئ كائنًا من `ChangePasswordResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/change_password_response_model.dart#L27) — ينشئ كائنًا من `ChangePasswordResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/change_password_response_model.dart#L30) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/data/models/member_card_activation_response_model.dart`

- [`class MemberCardActivationResponseModel`](../lib/features/profile/data/models/member_card_activation_response_model.dart#L5) — الكلاس الذي يمثل بيانات `member card activation response model` وينقلها بين الطبقات.
- [`const MemberCardActivationResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/profile/data/models/member_card_activation_response_model.dart#L15) — ينشئ كائنًا من `MemberCardActivationResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory MemberCardActivationResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/member_card_activation_response_model.dart#L23) — ينشئ كائنًا من `MemberCardActivationResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/member_card_activation_response_model.dart#L28) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/data/models/profile_response_model.dart`

- [`class ProfileResponseModel`](../lib/features/profile/data/models/profile_response_model.dart#L5) — الكلاس الذي يمثل بيانات `profile response model` وينقلها بين الطبقات.
- [`const ProfileResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/profile/data/models/profile_response_model.dart#L13) — ينشئ كائنًا من `ProfileResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProfileResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/profile_response_model.dart#L21) — ينشئ كائنًا من `ProfileResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/profile_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProfileData`](../lib/features/profile/data/models/profile_response_model.dart#L27) — الكلاس الذي يمثل بيانات `profile data` وينقلها بين الطبقات.
- [`const ProfileData({this.firstName, this.lastName, this.phoneNumber, this.nationalId, this.cardNumber, this.passportNumber, this.isMale, this.birthDate, this.imageUrl})`](../lib/features/profile/data/models/profile_response_model.dart#L39) — ينشئ كائنًا من `ProfileData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProfileData.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/profile_response_model.dart#L51) — ينشئ كائنًا من `ProfileData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/profile_response_model.dart#L54) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`ProfileData copyWith({String? firstName, String? lastName, String? phoneNumber, String? nationalId, String? cardNumber, String? passportNumber, bool? isMale, String? birthDate, String? imageUrl})`](../lib/features/profile/data/models/profile_response_model.dart#L56) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `features/profile/data/models/profile_summary_response_model.dart`

- [`class ProfileSummaryResponseModel`](../lib/features/profile/data/models/profile_summary_response_model.dart#L5) — الكلاس الذي يمثل بيانات `profile summary response model` وينقلها بين الطبقات.
- [`ProfileSummaryResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/profile/data/models/profile_summary_response_model.dart#L13) — ينشئ كائنًا من `ProfileSummaryResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProfileSummaryResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/profile_summary_response_model.dart#L21) — ينشئ كائنًا من `ProfileSummaryResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/profile_summary_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProfileSummaryData`](../lib/features/profile/data/models/profile_summary_response_model.dart#L27) — الكلاس الذي يمثل بيانات `profile summary data` وينقلها بين الطبقات.
- [`const ProfileSummaryData({this.familyMembersCount, this.rewardPoints})`](../lib/features/profile/data/models/profile_summary_response_model.dart#L32) — ينشئ كائنًا من `ProfileSummaryData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProfileSummaryData.fromJson(Map<String, dynamic> json)`](../lib/features/profile/data/models/profile_summary_response_model.dart#L34) — ينشئ كائنًا من `ProfileSummaryData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/profile/data/models/profile_summary_response_model.dart#L37) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/profile/domain/usecases/activate_member_card_usecase.dart`

- [`class ActivateMemberCardUseCase`](../lib/features/profile/domain/usecases/activate_member_card_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `activate member card use case`.
- [`ActivateMemberCardUseCase(this._repository)`](../lib/features/profile/domain/usecases/activate_member_card_usecase.dart#L8) — ينشئ كائنًا من `ActivateMemberCardUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<MemberCardActivationResponseModel>> call({required String cardNumber})`](../lib/features/profile/domain/usecases/activate_member_card_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/change_language_usecase.dart`

- [`class ChangeLanguageUseCase`](../lib/features/profile/domain/usecases/change_language_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `change language use case`.
- [`ChangeLanguageUseCase(this.repository)`](../lib/features/profile/domain/usecases/change_language_usecase.dart#L8) — ينشئ كائنًا من `ChangeLanguageUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ChangeLanguageResponseModel>> call({required String language})`](../lib/features/profile/domain/usecases/change_language_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/change_password_usecase.dart`

- [`class ChangePasswordUseCase`](../lib/features/profile/domain/usecases/change_password_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `change password use case`.
- [`ChangePasswordUseCase(this._repository)`](../lib/features/profile/domain/usecases/change_password_usecase.dart#L8) — ينشئ كائنًا من `ChangePasswordUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ChangePasswordResponseModel>> call({required String currentPassword, required String newPassword, required String confirmNewPassword})`](../lib/features/profile/domain/usecases/change_password_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/delete_profile_image_usecase.dart`

- [`class DeleteProfileImageUseCase`](../lib/features/profile/domain/usecases/delete_profile_image_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `delete profile image use case`.
- [`DeleteProfileImageUseCase(this._repository)`](../lib/features/profile/domain/usecases/delete_profile_image_usecase.dart#L8) — ينشئ كائنًا من `DeleteProfileImageUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ProfileResponseModel>> call()`](../lib/features/profile/domain/usecases/delete_profile_image_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/get_profile_summary_usecase.dart`

- [`class GetProfileSummaryUseCase`](../lib/features/profile/domain/usecases/get_profile_summary_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get profile summary use case`.
- [`GetProfileSummaryUseCase(this._repository)`](../lib/features/profile/domain/usecases/get_profile_summary_usecase.dart#L8) — ينشئ كائنًا من `GetProfileSummaryUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ProfileSummaryResponseModel>> call()`](../lib/features/profile/domain/usecases/get_profile_summary_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/get_profile_usecase.dart`

- [`class GetProfileUseCase`](../lib/features/profile/domain/usecases/get_profile_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get profile use case`.
- [`GetProfileUseCase(this._repository)`](../lib/features/profile/domain/usecases/get_profile_usecase.dart#L8) — ينشئ كائنًا من `GetProfileUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ProfileResponseModel>> call()`](../lib/features/profile/domain/usecases/get_profile_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/domain/usecases/update_profile_v2_usecase.dart`

- [`class UpdateProfileV2UseCase`](../lib/features/profile/domain/usecases/update_profile_v2_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `update profile v2 use case`.
- [`UpdateProfileV2UseCase(this._repository)`](../lib/features/profile/domain/usecases/update_profile_v2_usecase.dart#L8) — ينشئ كائنًا من `UpdateProfileV2UseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<ProfileResponseModel>> call({required String firstName, required String lastName, required String phoneNumber, required String nationalId, String? passportNumber, required bool isMale, required String birthDate, String? imagePath, bool removeImage = false, String? currentImageUrl})`](../lib/features/profile/domain/usecases/update_profile_v2_usecase.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/profile/presentation/cubit/change_password_cubit.dart`

- [`class ChangePasswordCubit`](../lib/features/profile/presentation/cubit/change_password_cubit.dart#L8) — الكلاس الذي يدير حالة وتفاعلات `change password cubit`.
- [`ChangePasswordCubit(this._changePasswordUseCase)`](../lib/features/profile/presentation/cubit/change_password_cubit.dart#L11) — ينشئ كائنًا من `ChangePasswordCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> changePassword({required String currentPassword, required String newPassword, required String confirmNewPassword})`](../lib/features/profile/presentation/cubit/change_password_cubit.dart#L14) — يحدّث `change password` داخل `ChangePasswordCubit`.

### `features/profile/presentation/cubit/change_password_state.dart`

- [`class ChangePasswordState`](../lib/features/profile/presentation/cubit/change_password_state.dart#L5) — الكلاس الذي يدير حالة وتفاعلات `change password state`.
- [`const factory ChangePasswordState.initial()`](../lib/features/profile/presentation/cubit/change_password_state.dart#L7) — ينشئ كائنًا من `ChangePasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ChangePasswordState.loading()`](../lib/features/profile/presentation/cubit/change_password_state.dart#L8) — ينشئ كائنًا من `ChangePasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ChangePasswordState.success()`](../lib/features/profile/presentation/cubit/change_password_state.dart#L9) — ينشئ كائنًا من `ChangePasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ChangePasswordState.failure(String message)`](../lib/features/profile/presentation/cubit/change_password_state.dart#L10) — ينشئ كائنًا من `ChangePasswordState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/profile/presentation/cubit/profile_cubit.dart`

- [`class ProfileCubit`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L18) — الكلاس الذي يدير حالة وتفاعلات `profile cubit`.
- [`ProfileCubit(this._getProfileUseCase, this._getProfileSummaryUseCase, this._updateProfileUseCase, this._deleteProfileImageUseCase, this._changeLanguageUseCase, this._activateMemberCardUseCase, this._logoutUseCase)`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L28) — ينشئ كائنًا من `ProfileCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadProfile({bool forceRefresh = false})`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L38) — يحمّل `load profile` ويحدّث الحالة المرتبطة داخل `ProfileCubit`.
- [`Future<void> _performProfileLoad()`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L74) — **خاص** — ينفّذ منطق `perform profile load` داخل `ProfileCubit`.
- [`Future<bool> updateProfile({required String firstName, required String lastName, required String phoneNumber, required String nationalId, String? passportNumber, required bool isMale, required String birthDate, String? imagePath, bool removeImage = false, required ProfileData currentData})`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L122) — يحدّث `update profile` داخل `ProfileCubit`.
- [`Future<void> changeLanguage({required String language})`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L176) — يحدّث `change language` داخل `ProfileCubit`.
- [`Future<bool> deleteProfileImage(ProfileData currentData)`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L197) — يحذف أو يمسح `delete profile image` داخل `ProfileCubit`.
- [`Future<bool> activateMemberCard({required String cardNumber, required ProfileData currentData})`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L230) — ينفّذ منطق `activate member card` داخل `ProfileCubit`.
- [`Future<void> refreshSummary()`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L263) — يعيد تحميل أو محاولة `refresh summary` داخل `ProfileCubit`.
- [`Future<void> _loadSummary(ProfileData profile)`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L281) — **خاص** — يحمّل `load summary` ويحدّث الحالة المرتبطة داخل `ProfileCubit`.
- [`Future<void> logout()`](../lib/features/profile/presentation/cubit/profile_cubit.dart#L318) — ينهي الجلسة الحالية وينظّف بيانات المصادقة داخل `ProfileCubit`.

### `features/profile/presentation/cubit/profile_state.dart`

- [`class ProfileState`](../lib/features/profile/presentation/cubit/profile_state.dart#L7) — الكلاس الذي يدير حالة وتفاعلات `profile state`.
- [`const factory ProfileState.initial()`](../lib/features/profile/presentation/cubit/profile_state.dart#L9) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ProfileState.loading()`](../lib/features/profile/presentation/cubit/profile_state.dart#L10) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ProfileState.success(ProfileData data, [ProfileSummaryData? summary])`](../lib/features/profile/presentation/cubit/profile_state.dart#L11) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ProfileState.updating(ProfileData data)`](../lib/features/profile/presentation/cubit/profile_state.dart#L13) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ProfileState.updated(ProfileData data)`](../lib/features/profile/presentation/cubit/profile_state.dart#L14) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory ProfileState.failed(String error)`](../lib/features/profile/presentation/cubit/profile_state.dart#L15) — ينشئ كائنًا من `ProfileState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/profile/presentation/pages/change_password_screen.dart`

- [`class ChangePasswordScreen`](../lib/features/profile/presentation/pages/change_password_screen.dart#L14) — الكلاس الذي يمثل شاشة `change password screen`.
- [`const ChangePasswordScreen({super.key})`](../lib/features/profile/presentation/pages/change_password_screen.dart#L15) — ينشئ كائنًا من `ChangePasswordScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ChangePasswordScreen> createState()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L17) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ChangePasswordScreenState`](../lib/features/profile/presentation/pages/change_password_screen.dart#L21) — **خاص** — الكلاس الذي يمثل شاشة `change password screen state`.
- [`void initState()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L39) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onNewPasswordFocusChanged()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L47) — **خاص** — يعالج حدث `on new password focus changed` داخل `_ChangePasswordScreenState`.
- [`void _onConfirmPasswordFocusChanged()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L53) — **خاص** — يعالج حدث `on confirm password focus changed` داخل `_ChangePasswordScreenState`.
- [`void _onNewPasswordChanged()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L59) — **خاص** — يعالج حدث `on new password changed` داخل `_ChangePasswordScreenState`.
- [`void dispose()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L66) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _submit()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L79) — **خاص** — يرسل `submit` إلى الطبقة أو الخدمة المطلوبة داخل `_ChangePasswordScreenState`.
- [`String? _validateNewPassword(String? value)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L94) — **خاص** — يتحقق من صحة `validate new password` داخل `_ChangePasswordScreenState`.
- [`bool _isPasswordValid(String password)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L105) — **خاص** — يفحص شرط `is password valid` ويعيد النتيجة داخل `_ChangePasswordScreenState`.
- [`bool _hasMinimumLength(String password)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L112) — **خاص** — يفحص شرط `has minimum length` ويعيد النتيجة داخل `_ChangePasswordScreenState`.
- [`bool _hasLetter(String password)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L115) — **خاص** — يفحص شرط `has letter` ويعيد النتيجة داخل `_ChangePasswordScreenState`.
- [`bool _hasNumber(String password)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L117) — **خاص** — يفحص شرط `has number` ويعيد النتيجة داخل `_ChangePasswordScreenState`.
- [`bool _hasSpecialCharacter(String password)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L119) — **خاص** — يفحص شرط `has special character` ويعيد النتيجة داخل `_ChangePasswordScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L122) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildPasswordField({Key? fieldKey, required TextEditingController controller, required String hintText, required bool showPassword, required VoidCallback onToggle, required String? Function(String?) validator, FocusNode? focusNode, AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction})`](../lib/features/profile/presentation/pages/change_password_screen.dart#L306) — **خاص** — ينفّذ منطق `build password field` داخل `_ChangePasswordScreenState`.
- [`Widget _buildPasswordRequirements()`](../lib/features/profile/presentation/pages/change_password_screen.dart#L378) — **خاص** — ينفّذ منطق `build password requirements` داخل `_ChangePasswordScreenState`.
- [`Widget _buildPasswordRequirement({required String label, required bool isMet, required bool showInvalid})`](../lib/features/profile/presentation/pages/change_password_screen.dart#L422) — **خاص** — ينفّذ منطق `build password requirement` داخل `_ChangePasswordScreenState`.
- [`class _FieldLabel`](../lib/features/profile/presentation/pages/change_password_screen.dart#L459) — **خاص** — الكلاس الذي يمثل شاشة `field label`.
- [`const _FieldLabel(this.label)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L461) — **خاص** — ينشئ كائنًا من `FieldLabel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/pages/change_password_screen.dart#L463) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/pages/edit_profile_screen.dart`

- [`class EditProfileScreen`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L21) — الكلاس الذي يمثل شاشة `edit profile screen`.
- [`const EditProfileScreen({super.key, required this.profileData})`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L24) — ينشئ كائنًا من `EditProfileScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<EditProfileScreen> createState()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L26) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _EditProfileScreenState`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L30) — **خاص** — الكلاس الذي يمثل شاشة `edit profile screen state`.
- [`Future<void> _pickImage()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L52) — **خاص** — ينفّذ منطق `pick image` داخل `_EditProfileScreenState`.
- [`bool get _hasCurrentPhoto`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L81) — **خاص** — يفحص شرط `has current photo` ويعيد النتيجة داخل `_EditProfileScreenState`.
- [`Future<void> _showImageOptions()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L86) — **خاص** — يعرض أو يفتح `show image options` داخل `_EditProfileScreenState`.
- [`Future<void> _removeCurrentImage()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L176) — **خاص** — يحذف أو يمسح `remove current image` داخل `_EditProfileScreenState`.
- [`Future<void> _selectBirthDate()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L215) — **خاص** — يغيّر الاختيار الخاص بـ `select birth date` داخل `_EditProfileScreenState`.
- [`void initState()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L240) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L266) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`String? _validateName(String? value)`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L281) — **خاص** — يتحقق من صحة `validate name` داخل `_EditProfileScreenState`.
- [`String? _validatePhoneNumber(String? value)`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L292) — **خاص** — يتحقق من صحة `validate phone number` داخل `_EditProfileScreenState`.
- [`String? _validateNationalId(String? value)`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L307) — **خاص** — يتحقق من صحة `validate national id` داخل `_EditProfileScreenState`.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L318) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> _saveProfile()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L454) — **خاص** — ينفّذ منطق `save profile` داخل `_EditProfileScreenState`.
- [`TextInputFormatter _digitsOnly({required int maxDigits})`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L495) — **خاص** — ينفّذ منطق `digits only` داخل `_EditProfileScreenState`.
- [`TextInputFormatter _lettersOnly()`](../lib/features/profile/presentation/pages/edit_profile_screen.dart#L508) — **خاص** — ينفّذ منطق `letters only` داخل `_EditProfileScreenState`.

### `features/profile/presentation/pages/profile_screen.dart`

- [`class ProfileScreen`](../lib/features/profile/presentation/pages/profile_screen.dart#L13) — الكلاس الذي يمثل شاشة `profile screen`.
- [`const ProfileScreen({super.key})`](../lib/features/profile/presentation/pages/profile_screen.dart#L14) — ينشئ كائنًا من `ProfileScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ProfileScreen> createState()`](../lib/features/profile/presentation/pages/profile_screen.dart#L16) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ProfileScreenState`](../lib/features/profile/presentation/pages/profile_screen.dart#L20) — **خاص** — الكلاس الذي يمثل شاشة `profile screen state`.
- [`void initState()`](../lib/features/profile/presentation/pages/profile_screen.dart#L23) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onProfileSummaryRefresh()`](../lib/features/profile/presentation/pages/profile_screen.dart#L37) — **خاص** — يعالج حدث `on profile summary refresh` داخل `_ProfileScreenState`.
- [`void dispose()`](../lib/features/profile/presentation/pages/profile_screen.dart#L43) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/pages/profile_screen.dart#L52) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/activate_card_banner.dart`

- [`class ActivateCardBanner`](../lib/features/profile/presentation/widgets/activate_card_banner.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ActivateCardBanner({super.key, required this.data})`](../lib/features/profile/presentation/widgets/activate_card_banner.dart#L14) — ينشئ كائنًا من `ActivateCardBanner` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/activate_card_banner.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/card_number_input_sheet.dart`

- [`Future<void> showActivateCardDialog(BuildContext context, ProfileData data)`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L13) — يعرض أو يفتح `show activate card dialog` داخل هذا الملف.
- [`class CardNumberInputSheet`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L34) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CardNumberInputSheet({super.key})`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L35) — ينشئ كائنًا من `CardNumberInputSheet` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<CardNumberInputSheet> createState()`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L37) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class CardNumberInputSheetState`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L41) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`void dispose()`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L45) — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _submit()`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L51) — **خاص** — يرسل `submit` إلى الطبقة أو الخدمة المطلوبة داخل `CardNumberInputSheetState`.
- [`String? _validateCardNumber(String? value)`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L56) — **خاص** — يتحقق من صحة `validate card number` داخل `CardNumberInputSheetState`.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/card_number_input_sheet.dart#L65) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_identity_section.dart`

- [`class EditIdentitySection`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditIdentitySection({super.key, required this.cardNumber, required this.cardNumberController, required this.nationalIdController, required this.nationalIdFocusNode, required this.nationalIdAutovalidate, required this.digitsFormatters, required this.nationalIdValidator, required this.passportNumberController, required this.passportNumberFocusNode, required this.passportNumberAutovalidate, required this.phoneNumberController, required this.phoneNumberFocusNode, required this.phoneNumberAutovalidate, required this.phoneNumberValidator, required this.birthDateController, required this.birthDateIsEmpty, required this.onSelectBirthDate, required this.isMale, required this.onGenderChanged})`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L35) — ينشئ كائنًا من `EditIdentitySection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L58) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class EditBirthDateField`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L164) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditBirthDateField({super.key, required this.controller, required this.isEmpty, required this.onTap})`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L170) — ينشئ كائنًا من `EditBirthDateField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_identity_section.dart#L177) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_name_row.dart`

- [`class EditNameRow`](../lib/features/profile/presentation/widgets/edit_profile/edit_name_row.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditNameRow({super.key, required this.firstNameController, required this.lastNameController, required this.firstNameFocusNode, required this.lastNameFocusNode, required this.firstNameAutovalidate, required this.lastNameAutovalidate, required this.nameValidator, required this.lettersFormatters})`](../lib/features/profile/presentation/widgets/edit_profile/edit_name_row.dart#L20) — ينشئ كائنًا من `EditNameRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_name_row.dart#L32) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart`

- [`class EditProfileAvatar`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditProfileAvatar({super.key, required this.imageFile, required this.isPickingImage, required this.removeImage, required this.imageUrl, required this.onPreviewTap, required this.onEditTap})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L19) — ينشئ كائنًا من `EditProfileAvatar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L29) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _RemoteImage`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L107) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _RemoteImage({required this.imageUrl})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L110) — **خاص** — ينشئ كائنًا من `RemoteImage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L112) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`bool hasValidProfileImageUrl(String? url)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L132) — يفحص شرط `has valid profile image url` ويعيد النتيجة داخل هذا الملف.
- [`void showProfileImagePreview(BuildContext context, {required File? imageFile, required String? imageUrl, required bool removeImage})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L143) — يعرض أو يفتح `show profile image preview` داخل هذا الملف.
- [`class _PreviewPhoto`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L199) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _PreviewPhoto({required this.imageFile, required this.imageUrl})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L203) — **خاص** — ينشئ كائنًا من `PreviewPhoto` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_avatar.dart#L205) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_profile_gender_dropdown.dart`

- [`class EditProfileGenderDropdown`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_gender_dropdown.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditProfileGenderDropdown({super.key, required this.isMale, required this.onChanged})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_gender_dropdown.dart#L13) — ينشئ كائنًا من `EditProfileGenderDropdown` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_gender_dropdown.dart#L19) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart`

- [`class EditProfileRequiredHint`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditProfileRequiredHint(this.text, {super.key})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L10) — ينشئ كائنًا من `EditProfileRequiredHint` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L12) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class EditProfileFieldLabel`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L41) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditProfileFieldLabel(this.label, {super.key})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L45) — ينشئ كائنًا من `EditProfileFieldLabel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_labels.dart#L47) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/edit_profile/edit_profile_text_field.dart`

- [`class EditProfileTextField`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_text_field.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const EditProfileTextField({super.key, required this.controller, required this.hintText, this.keyboardType, this.required = true, this.readOnly = false, this.maxLength, this.inputFormatters, this.validator, this.focusNode, this.autovalidateMode = AutovalidateMode.disabled})`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_text_field.dart#L23) — ينشئ كائنًا من `EditProfileTextField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/edit_profile/edit_profile_text_field.dart#L37) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_avatar.dart`

- [`class ProfileAvatar`](../lib/features/profile/presentation/widgets/profile_avatar.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileAvatar({super.key, required this.imageUrl})`](../lib/features/profile/presentation/widgets/profile_avatar.dart#L11) — ينشئ كائنًا من `ProfileAvatar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_avatar.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _fallbackAvatar()`](../lib/features/profile/presentation/widgets/profile_avatar.dart#L45) — **خاص** — ينفّذ منطق `fallback avatar` داخل `ProfileAvatar`.

### `features/profile/presentation/widgets/profile_card.dart`

- [`class ProfileCard`](../lib/features/profile/presentation/widgets/profile_card.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileCard({super.key, required this.children})`](../lib/features/profile/presentation/widgets/profile_card.dart#L8) — ينشئ كائنًا من `ProfileCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_card.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_content.dart`

- [`class ProfileContent`](../lib/features/profile/presentation/widgets/profile_content.dart#L20) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileContent({super.key, required this.data, this.summary})`](../lib/features/profile/presentation/widgets/profile_content.dart#L25) — ينشئ كائنًا من `ProfileContent` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_content.dart#L27) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> showLogoutConfirmation(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_content.dart#L210) — يعرض أو يفتح `show logout confirmation` داخل هذا الملف.

### `features/profile/presentation/widgets/profile_error_view.dart`

- [`class ProfileErrorView`](../lib/features/profile/presentation/widgets/profile_error_view.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileErrorView({super.key, required this.error})`](../lib/features/profile/presentation/widgets/profile_error_view.dart#L15) — ينشئ كائنًا من `ProfileErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_error_view.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_item.dart`

- [`class ProfileItem`](../lib/features/profile/presentation/widgets/profile_item.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileItem({super.key, this.icon, required this.label, this.trailing, this.route})`](../lib/features/profile/presentation/widgets/profile_item.dart#L15) — ينشئ كائنًا من `ProfileItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_item.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_language_item.dart`

- [`class ProfileLanguageItem`](../lib/features/profile/presentation/widgets/profile_language_item.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileLanguageItem({super.key, required this.data})`](../lib/features/profile/presentation/widgets/profile_language_item.dart#L15) — ينشئ كائنًا من `ProfileLanguageItem` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_language_item.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Future<void> _showLanguageSheet(BuildContext context, String current)`](../lib/features/profile/presentation/widgets/profile_language_item.dart#L66) — **خاص** — يعرض أو يفتح `show language sheet` داخل `ProfileLanguageItem`.
- [`Widget option(String code, String name)`](../lib/features/profile/presentation/widgets/profile_language_item.dart#L78) — ينفّذ منطق `option` داخل `ProfileLanguageItem`.

### `features/profile/presentation/widgets/profile_section_title.dart`

- [`class ProfileSectionTitle`](../lib/features/profile/presentation/widgets/profile_section_title.dart#L6) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileSectionTitle({super.key, required this.title})`](../lib/features/profile/presentation/widgets/profile_section_title.dart#L8) — ينشئ كائنًا من `ProfileSectionTitle` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_section_title.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_shimmer.dart`

- [`class ProfileShimmer`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileShimmer({super.key})`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L8) — ينشئ كائنًا من `ProfileShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L10) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SectionTitleShimmer`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L62) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SectionTitleShimmer()`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L63) — **خاص** — ينشئ كائنًا من `SectionTitleShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_shimmer.dart#L65) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/profile/presentation/widgets/profile_user_info_card.dart`

- [`class ProfileUserInfoCard`](../lib/features/profile/presentation/widgets/profile_user_info_card.dart#L14) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProfileUserInfoCard({super.key, required this.data})`](../lib/features/profile/presentation/widgets/profile_user_info_card.dart#L16) — ينشئ كائنًا من `ProfileUserInfoCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/profile/presentation/widgets/profile_user_info_card.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Feature: search

### `features/search/data/data_sources/search_remote_data_source.dart`

- [`class SearchRemoteDataSource`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L12) — الكلاس الذي يعرّف الاتصال بمصدر البيانات أو REST API.
- [`factory SearchRemoteDataSource(Dio dio, {String baseUrl})`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L14) — ينشئ كائنًا من `SearchRemoteDataSource` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<SearchResponseModel> searchProviders({@Query('Keyword') String? keyword, @Query('CategoryId') int? categoryId, @Query('GovernorateId') int? governorateId, @Query('CityId') int? cityId, @Query('ProviderId') int? providerId, @Query('BranchId') int? branchId, @Query('SortBy') int? sortBy, @Query('UserLatitude') double? userLatitude, @Query('UserLongitude') double? userLongitude, @Query('PageNumber') int? pageNumber, @Query('PageSize') int? pageSize})`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L17) — ينفّذ البحث الخاص بـ `search providers` داخل `SearchRemoteDataSource`.
- [`Future<CategoryResponseModel> getCategories()`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L32) — يجلب `get categories` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.
- [`Future<CategoryResponseModel> getServiceCategories()`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L35) — يجلب `get service categories` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.
- [`Future<LookupResponseModel> getGovernorates()`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L38) — يجلب `get governorates` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.
- [`Future<LookupResponseModel> getCities(@Query('governorateId') int governorateId)`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L41) — يجلب `get cities` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.
- [`Future<CategoryServicesResponseModel> getCategoryServices(@Path('categoryId') int categoryId, @Query('PageNumber') int? pageNumber, @Query('PageSize') int? pageSize, @Extras() Map<String, dynamic> extras)`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L46) — يجلب `get category services` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.
- [`Future<GuestCategoryServicesResponseModel> getGuestCategoryServices(@Query('categoryId') int categoryId, @Query('Search') String? search, @Query('PageNumber') int? pageNumber, @Query('PageSize') int? pageSize)`](../lib/features/search/data/data_sources/search_remote_data_source.dart#L54) — يجلب `get guest category services` من مصدر البيانات المناسب داخل `SearchRemoteDataSource`.

### `features/search/data/models/category_model.dart`

- [`class CategoryModel`](../lib/features/search/data/models/category_model.dart#L5) — الكلاس الذي يمثل بيانات `category model` وينقلها بين الطبقات.
- [`const CategoryModel({this.id, this.name, this.imageUrl})`](../lib/features/search/data/models/category_model.dart#L11) — ينشئ كائنًا من `CategoryModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_model.dart#L13) — ينشئ كائنًا من `CategoryModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_model.dart#L16) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/category_response_model.dart`

- [`class CategoryResponseModel`](../lib/features/search/data/models/category_response_model.dart#L6) — الكلاس الذي يمثل بيانات `category response model` وينقلها بين الطبقات.
- [`const CategoryResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/search/data/models/category_response_model.dart#L14) — ينشئ كائنًا من `CategoryResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_response_model.dart#L22) — ينشئ كائنًا من `CategoryResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/category_services_response_model.dart`

- [`class CategoryServicesResponseModel`](../lib/features/search/data/models/category_services_response_model.dart#L5) — الكلاس الذي يمثل بيانات `category services response model` وينقلها بين الطبقات.
- [`const CategoryServicesResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/search/data/models/category_services_response_model.dart#L13) — ينشئ كائنًا من `CategoryServicesResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryServicesResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_services_response_model.dart#L21) — ينشئ كائنًا من `CategoryServicesResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_services_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class CategoryServicesDataModel`](../lib/features/search/data/models/category_services_response_model.dart#L27) — الكلاس الذي يمثل بيانات `category services data model` وينقلها بين الطبقات.
- [`const CategoryServicesDataModel({this.categoryId, this.categoryName, this.services, this.totalSelectedCount})`](../lib/features/search/data/models/category_services_response_model.dart#L34) — ينشئ كائنًا من `CategoryServicesDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory CategoryServicesDataModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_services_response_model.dart#L41) — ينشئ كائنًا من `CategoryServicesDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_services_response_model.dart#L44) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class PagedServicesModel`](../lib/features/search/data/models/category_services_response_model.dart#L47) — الكلاس الذي يمثل بيانات `paged services model` وينقلها بين الطبقات.
- [`const PagedServicesModel({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/search/data/models/category_services_response_model.dart#L55) — ينشئ كائنًا من `PagedServicesModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory PagedServicesModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_services_response_model.dart#L63) — ينشئ كائنًا من `PagedServicesModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_services_response_model.dart#L66) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ServiceItemModel`](../lib/features/search/data/models/category_services_response_model.dart#L69) — الكلاس الذي يمثل بيانات `service item model` وينقلها بين الطبقات.
- [`const ServiceItemModel({this.serviceId, this.serviceNameEn, this.serviceNameAr, this.isSelected})`](../lib/features/search/data/models/category_services_response_model.dart#L76) — ينشئ كائنًا من `ServiceItemModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String? get serviceName`](../lib/features/search/data/models/category_services_response_model.dart#L83) — ينفّذ منطق `service name` داخل `ServiceItemModel`.
- [`factory ServiceItemModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/category_services_response_model.dart#L93) — ينشئ كائنًا من `ServiceItemModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/category_services_response_model.dart#L96) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/guest_category_services_response_model.dart`

- [`class GuestCategoryServicesResponseModel`](../lib/features/search/data/models/guest_category_services_response_model.dart#L7) — الكلاس الذي يمثل بيانات `guest category services response model` وينقلها بين الطبقات.
- [`const GuestCategoryServicesResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/search/data/models/guest_category_services_response_model.dart#L15) — ينشئ كائنًا من `GuestCategoryServicesResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestCategoryServicesResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/guest_category_services_response_model.dart#L23) — ينشئ كائنًا من `GuestCategoryServicesResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/guest_category_services_response_model.dart#L28) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class GuestPagedServicesDataModel`](../lib/features/search/data/models/guest_category_services_response_model.dart#L33) — الكلاس الذي يمثل بيانات `guest paged services data model` وينقلها بين الطبقات.
- [`const GuestPagedServicesDataModel({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/search/data/models/guest_category_services_response_model.dart#L41) — ينشئ كائنًا من `GuestPagedServicesDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestPagedServicesDataModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/guest_category_services_response_model.dart#L49) — ينشئ كائنًا من `GuestPagedServicesDataModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/guest_category_services_response_model.dart#L52) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`CategoryServicesDataModel toCategoryServicesDataModel(int categoryId)`](../lib/features/search/data/models/guest_category_services_response_model.dart#L54) — يحوّل `to category services data model` بين طبقات أو صيغ البيانات داخل `GuestPagedServicesDataModel`.
- [`class GuestServiceItemModel`](../lib/features/search/data/models/guest_category_services_response_model.dart#L80) — الكلاس الذي يمثل بيانات `guest service item model` وينقلها بين الطبقات.
- [`const GuestServiceItemModel({this.id, this.serviceName, this.serviceNameAr, this.serviceNameEn})`](../lib/features/search/data/models/guest_category_services_response_model.dart#L87) — ينشئ كائنًا من `GuestServiceItemModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory GuestServiceItemModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/guest_category_services_response_model.dart#L94) — ينشئ كائنًا من `GuestServiceItemModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/guest_category_services_response_model.dart#L97) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/lookup_model.dart`

- [`class LookupModel`](../lib/features/search/data/models/lookup_model.dart#L5) — الكلاس الذي يمثل بيانات `lookup model` وينقلها بين الطبقات.
- [`const LookupModel({this.id, this.name})`](../lib/features/search/data/models/lookup_model.dart#L10) — ينشئ كائنًا من `LookupModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory LookupModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/lookup_model.dart#L12) — ينشئ كائنًا من `LookupModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/lookup_model.dart#L15) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/lookup_response_model.dart`

- [`class LookupResponseModel`](../lib/features/search/data/models/lookup_response_model.dart#L6) — الكلاس الذي يمثل بيانات `lookup response model` وينقلها بين الطبقات.
- [`const LookupResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/search/data/models/lookup_response_model.dart#L14) — ينشئ كائنًا من `LookupResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory LookupResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/lookup_response_model.dart#L22) — ينشئ كائنًا من `LookupResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/lookup_response_model.dart#L25) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/models/search_provider_model.dart`

- [`class SearchProviderModel`](../lib/features/search/data/models/search_provider_model.dart#L1) — الكلاس الذي يمثل بيانات `search provider model` وينقلها بين الطبقات.
- [`const SearchProviderModel({this.providerId, this.providerName, this.categoryName, this.imageUrl, this.hotline, this.maxDiscountPercentage, this.averageRating, this.totalReviews, this.distanceKm})`](../lib/features/search/data/models/search_provider_model.dart#L12) — ينشئ كائنًا من `SearchProviderModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory SearchProviderModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/search_provider_model.dart#L24) — ينشئ كائنًا من `SearchProviderModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/search_provider_model.dart#L41) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`int? _intValue(dynamic value)`](../lib/features/search/data/models/search_provider_model.dart#L54) — **خاص** — ينفّذ منطق `int value` داخل هذا الملف.
- [`double? _doubleValue(dynamic value)`](../lib/features/search/data/models/search_provider_model.dart#L60) — **خاص** — ينفّذ منطق `double value` داخل هذا الملف.
- [`String? _stringValue(dynamic value)`](../lib/features/search/data/models/search_provider_model.dart#L66) — **خاص** — ينفّذ منطق `string value` داخل هذا الملف.

### `features/search/data/models/search_response_model.dart`

- [`class SearchResponseModel`](../lib/features/search/data/models/search_response_model.dart#L3) — الكلاس الذي يمثل بيانات `search response model` وينقلها بين الطبقات.
- [`const SearchResponseModel({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/features/search/data/models/search_response_model.dart#L10) — ينشئ كائنًا من `SearchResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory SearchResponseModel.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/search_response_model.dart#L18) — ينشئ كائنًا من `SearchResponseModel` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/search_response_model.dart#L29) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class SearchResponseData`](../lib/features/search/data/models/search_response_model.dart#L38) — الكلاس الذي يمثل بيانات `search response data` وينقلها بين الطبقات.
- [`const SearchResponseData({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/features/search/data/models/search_response_model.dart#L45) — ينشئ كائنًا من `SearchResponseData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory SearchResponseData.fromJson(Map<String, dynamic> json)`](../lib/features/search/data/models/search_response_model.dart#L53) — ينشئ كائنًا من `SearchResponseData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/features/search/data/models/search_response_model.dart#L69) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `features/search/data/repositories/search_repository_impl.dart`

- [`class SearchRepositoryImpl`](../lib/features/search/data/repositories/search_repository_impl.dart#L10) — الكلاس الذي يمثل بيانات `search repository impl` وينقلها بين الطبقات.
- [`SearchRepositoryImpl(this._dataSource)`](../lib/features/search/data/repositories/search_repository_impl.dart#L13) — ينشئ كائنًا من `SearchRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<SearchResponseData>> searchProviders({String? keyword, int? categoryId, int? governorateId, int? cityId, int? providerId, int? branchId, int? sortBy, double? userLatitude, double? userLongitude, int? pageNumber, int? pageSize})`](../lib/features/search/data/repositories/search_repository_impl.dart#L15) — ينفّذ البحث الخاص بـ `search providers` داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<List<CategoryModel>>> getCategories()`](../lib/features/search/data/repositories/search_repository_impl.dart#L57) — يجلب `get categories` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<List<CategoryModel>>> getServiceCategories()`](../lib/features/search/data/repositories/search_repository_impl.dart#L73) — يجلب `get service categories` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<List<LookupModel>>> getGovernorates()`](../lib/features/search/data/repositories/search_repository_impl.dart#L89) — يجلب `get governorates` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<List<LookupModel>>> getCities(int governorateId)`](../lib/features/search/data/repositories/search_repository_impl.dart#L105) — يجلب `get cities` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<CategoryServicesDataModel>> getCategoryServices(int categoryId, {int? pageNumber, int? pageSize, bool skipAuthInterceptor = false})`](../lib/features/search/data/repositories/search_repository_impl.dart#L121) — يجلب `get category services` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`Future<ApiResult<CategoryServicesDataModel>> getGuestCategoryServices(int categoryId, {String? search, int? pageNumber, int? pageSize})`](../lib/features/search/data/repositories/search_repository_impl.dart#L151) — يجلب `get guest category services` من مصدر البيانات المناسب داخل `SearchRepositoryImpl`.
- [`String _responseMessage({required dynamic errors, required String? message, required String fallback})`](../lib/features/search/data/repositories/search_repository_impl.dart#L182) — **خاص** — ينفّذ منطق `response message` داخل هذا الملف.
- [`String _extractMessages(dynamic value)`](../lib/features/search/data/repositories/search_repository_impl.dart#L193) — **خاص** — ينفّذ منطق `extract messages` داخل هذا الملف.

### `features/search/domain/repositories/search_repository.dart`

- [`class SearchRepository`](../lib/features/search/domain/repositories/search_repository.dart#L7) — الكلاس الذي يجمع مسؤوليات `search repository`.
- [`Future<ApiResult<SearchResponseData>> searchProviders({String? keyword, int? categoryId, int? governorateId, int? cityId, int? providerId, int? branchId, int? sortBy, double? userLatitude, double? userLongitude, int? pageNumber, int? pageSize})`](../lib/features/search/domain/repositories/search_repository.dart#L8) — ينفّذ البحث الخاص بـ `search providers` داخل `SearchRepository`.
- [`Future<ApiResult<List<CategoryModel>>> getCategories()`](../lib/features/search/domain/repositories/search_repository.dart#L22) — يجلب `get categories` من مصدر البيانات المناسب داخل `SearchRepository`.
- [`Future<ApiResult<List<CategoryModel>>> getServiceCategories()`](../lib/features/search/domain/repositories/search_repository.dart#L24) — يجلب `get service categories` من مصدر البيانات المناسب داخل `SearchRepository`.
- [`Future<ApiResult<List<LookupModel>>> getGovernorates()`](../lib/features/search/domain/repositories/search_repository.dart#L26) — يجلب `get governorates` من مصدر البيانات المناسب داخل `SearchRepository`.
- [`Future<ApiResult<List<LookupModel>>> getCities(int governorateId)`](../lib/features/search/domain/repositories/search_repository.dart#L28) — يجلب `get cities` من مصدر البيانات المناسب داخل `SearchRepository`.
- [`Future<ApiResult<CategoryServicesDataModel>> getCategoryServices(int categoryId, {int? pageNumber, int? pageSize, bool skipAuthInterceptor = false})`](../lib/features/search/domain/repositories/search_repository.dart#L30) — يجلب `get category services` من مصدر البيانات المناسب داخل `SearchRepository`.
- [`Future<ApiResult<CategoryServicesDataModel>> getGuestCategoryServices(int categoryId, {String? search, int? pageNumber, int? pageSize})`](../lib/features/search/domain/repositories/search_repository.dart#L37) — يجلب `get guest category services` من مصدر البيانات المناسب داخل `SearchRepository`.

### `features/search/domain/use_cases/get_categories_use_case.dart`

- [`class GetCategoriesUseCase`](../lib/features/search/domain/use_cases/get_categories_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get categories use case`.
- [`GetCategoriesUseCase(this._repository)`](../lib/features/search/domain/use_cases/get_categories_use_case.dart#L8) — ينشئ كائنًا من `GetCategoriesUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<List<CategoryModel>>> call()`](../lib/features/search/domain/use_cases/get_categories_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/search/domain/use_cases/get_category_services_use_case.dart`

- [`class GetCategoryServicesUseCase`](../lib/features/search/domain/use_cases/get_category_services_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get category services use case`.
- [`GetCategoryServicesUseCase(this._repository)`](../lib/features/search/domain/use_cases/get_category_services_use_case.dart#L8) — ينشئ كائنًا من `GetCategoryServicesUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<CategoryServicesDataModel>> call(int categoryId, {int? pageNumber, int? pageSize, bool skipAuthInterceptor = false})`](../lib/features/search/domain/use_cases/get_category_services_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.
- [`Future<ApiResult<CategoryServicesDataModel>> callGuestServices(int categoryId, {String? search, int? pageNumber, int? pageSize})`](../lib/features/search/domain/use_cases/get_category_services_use_case.dart#L24) — ينفّذ منطق `call guest services` داخل `GetCategoryServicesUseCase`.

### `features/search/domain/use_cases/get_cities_use_case.dart`

- [`class GetCitiesUseCase`](../lib/features/search/domain/use_cases/get_cities_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get cities use case`.
- [`GetCitiesUseCase(this._repository)`](../lib/features/search/domain/use_cases/get_cities_use_case.dart#L8) — ينشئ كائنًا من `GetCitiesUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<List<LookupModel>>> call(int governorateId)`](../lib/features/search/domain/use_cases/get_cities_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/search/domain/use_cases/get_governorates_use_case.dart`

- [`class GetGovernoratesUseCase`](../lib/features/search/domain/use_cases/get_governorates_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get governorates use case`.
- [`GetGovernoratesUseCase(this._repository)`](../lib/features/search/domain/use_cases/get_governorates_use_case.dart#L8) — ينشئ كائنًا من `GetGovernoratesUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<List<LookupModel>>> call()`](../lib/features/search/domain/use_cases/get_governorates_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/search/domain/use_cases/get_service_categories_use_case.dart`

- [`class GetServiceCategoriesUseCase`](../lib/features/search/domain/use_cases/get_service_categories_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get service categories use case`.
- [`GetServiceCategoriesUseCase(this._repository)`](../lib/features/search/domain/use_cases/get_service_categories_use_case.dart#L11) — ينشئ كائنًا من `GetServiceCategoriesUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<List<CategoryModel>>> call()`](../lib/features/search/domain/use_cases/get_service_categories_use_case.dart#L13) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/search/domain/use_cases/search_providers_use_case.dart`

- [`class SearchProvidersUseCase`](../lib/features/search/domain/use_cases/search_providers_use_case.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `search providers use case`.
- [`SearchProvidersUseCase(this._repository)`](../lib/features/search/domain/use_cases/search_providers_use_case.dart#L8) — ينشئ كائنًا من `SearchProvidersUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<SearchResponseData>> call({String? keyword, int? categoryId, int? governorateId, int? cityId, int? providerId, int? branchId, int? sortBy, double? userLatitude, double? userLongitude, int? pageNumber, int? pageSize})`](../lib/features/search/domain/use_cases/search_providers_use_case.dart#L10) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `features/search/presentation/cubit/filter_cubit.dart`

- [`class FilterCubit`](../lib/features/search/presentation/cubit/filter_cubit.dart#L8) — الكلاس الذي يدير حالة وتفاعلات `filter cubit`.
- [`FilterCubit(this._getGovernoratesUseCase, this._getCitiesUseCase)`](../lib/features/search/presentation/cubit/filter_cubit.dart#L14) — ينشئ كائنًا من `FilterCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> loadGovernorates()`](../lib/features/search/presentation/cubit/filter_cubit.dart#L17) — يحمّل `load governorates` ويحدّث الحالة المرتبطة داخل `FilterCubit`.
- [`Future<void> selectGovernorate(int? governorateId)`](../lib/features/search/presentation/cubit/filter_cubit.dart#L39) — يغيّر الاختيار الخاص بـ `select governorate` داخل `FilterCubit`.
- [`void selectCity(int? cityId)`](../lib/features/search/presentation/cubit/filter_cubit.dart#L67) — يغيّر الاختيار الخاص بـ `select city` داخل `FilterCubit`.
- [`void selectSortBy(int? sortBy)`](../lib/features/search/presentation/cubit/filter_cubit.dart#L76) — يغيّر الاختيار الخاص بـ `select sort by` داخل `FilterCubit`.
- [`void resetFilters()`](../lib/features/search/presentation/cubit/filter_cubit.dart#L92) — ينفّذ منطق `reset filters` داخل `FilterCubit`.

### `features/search/presentation/cubit/filter_state.dart`

- [`class FilterState`](../lib/features/search/presentation/cubit/filter_state.dart#L3) — الكلاس الذي يدير حالة وتفاعلات `filter state`.
- [`const FilterState({this.governorates = const [], this.cities = const [], this.isLoadingGovernorates = false, this.isLoadingCities = false, this.selectedGovernorateId, this.selectedCityId, this.selectedSortBy, this.error})`](../lib/features/search/presentation/cubit/filter_state.dart#L13) — ينشئ كائنًا من `FilterState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`FilterState copyWith({List<LookupModel>? governorates, List<LookupModel>? cities, bool? isLoadingGovernorates, bool? isLoadingCities, int? selectedGovernorateId, bool clearGovernorate = false, int? selectedCityId, bool clearCity = false, int? selectedSortBy, bool clearSortBy = false, String? error, bool clearError = false})`](../lib/features/search/presentation/cubit/filter_state.dart#L24) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `features/search/presentation/cubit/search_cubit.dart`

- [`class SearchCubit`](../lib/features/search/presentation/cubit/search_cubit.dart#L20) — الكلاس الذي يدير حالة وتفاعلات `search cubit`.
- [`SearchCubit(this._searchProvidersUseCase, this._getCategoriesUseCase, this._getCategoryServicesUseCase, this._getServiceCategoriesUseCase, this._cartRepository, this._cartSyncService, {LocationService? locationService, LocationRepository? locationRepository})`](../lib/features/search/presentation/cubit/search_cubit.dart#L53) — ينشئ كائنًا من `SearchCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`bool get enableCartFeatures`](../lib/features/search/presentation/cubit/search_cubit.dart#L68) — ينفّذ منطق `enable cart features` داخل `SearchCubit`.
- [`Future<void> init({double? lat, double? lng, int? categoryId, bool enableCartFeatures = true})`](../lib/features/search/presentation/cubit/search_cubit.dart#L70) — ينفّذ منطق `init` داخل `SearchCubit`.
- [`Future<void> _loadCategories()`](../lib/features/search/presentation/cubit/search_cubit.dart#L95) — **خاص** — يحمّل `load categories` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`Future<void> _loadServiceCategories()`](../lib/features/search/presentation/cubit/search_cubit.dart#L109) — **خاص** — يحمّل `load service categories` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`Future<void> _loadCartCounters()`](../lib/features/search/presentation/cubit/search_cubit.dart#L138) — **خاص** — يحمّل `load cart counters` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`Future<bool> loadCategoryServices(int categoryId, {String? search})`](../lib/features/search/presentation/cubit/search_cubit.dart#L162) — يحمّل `load category services` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`Future<int?> loadFirstServiceCategoryWithData()`](../lib/features/search/presentation/cubit/search_cubit.dart#L269) — يحمّل `load first service category with data` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`bool hasMoreCategoryServices(int categoryId)`](../lib/features/search/presentation/cubit/search_cubit.dart#L281) — يفحص شرط `has more category services` ويعيد النتيجة داخل `SearchCubit`.
- [`Future<bool> loadMoreCategoryServices(int categoryId)`](../lib/features/search/presentation/cubit/search_cubit.dart#L288) — يحمّل `load more category services` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`Future<void> addServiceToCart({required int serviceId, required int categoryId})`](../lib/features/search/presentation/cubit/search_cubit.dart#L378) — ينشئ أو يضيف `add service to cart` داخل `SearchCubit`.
- [`Future<void> removeServiceFromCart({required int serviceId, required int categoryId})`](../lib/features/search/presentation/cubit/search_cubit.dart#L469) — يحذف أو يمسح `remove service from cart` داخل `SearchCubit`.
- [`Future<void> search({String keyword = ''})`](../lib/features/search/presentation/cubit/search_cubit.dart#L537) — ينفّذ البحث الخاص بـ `search` داخل `SearchCubit`.
- [`Future<void> loadMore()`](../lib/features/search/presentation/cubit/search_cubit.dart#L565) — يحمّل `load more` ويحدّث الحالة المرتبطة داخل `SearchCubit`.
- [`bool _hasMoreProviders({required int page, required int newItemsCount, required int? totalPages, required int? totalCount, required int pageSize})`](../lib/features/search/presentation/cubit/search_cubit.dart#L572) — **خاص** — يفحص شرط `has more providers` ويعيد النتيجة داخل `SearchCubit`.
- [`Future<void> selectCategory(int? id)`](../lib/features/search/presentation/cubit/search_cubit.dart#L589) — يغيّر الاختيار الخاص بـ `select category` داخل `SearchCubit`.
- [`Future<void> applyFilters({int? governorateId, int? cityId, int? sortBy})`](../lib/features/search/presentation/cubit/search_cubit.dart#L599) — ينفّذ منطق `apply filters` داخل `SearchCubit`.
- [`Future<LocationResult> _resolveUserLocation()`](../lib/features/search/presentation/cubit/search_cubit.dart#L652) — **خاص** — ينفّذ منطق `resolve user location` داخل `SearchCubit`.
- [`String _locationUnavailableMessage(LocationAccessStatus status)`](../lib/features/search/presentation/cubit/search_cubit.dart#L660) — **خاص** — ينفّذ منطق `location unavailable message` داخل `SearchCubit`.
- [`Future<void> _fetch({required int page})`](../lib/features/search/presentation/cubit/search_cubit.dart#L673) — **خاص** — يجلب `fetch` من مصدر البيانات المناسب داخل `SearchCubit`.
- [`void _emitLocalServiceSelection({required int serviceId, required int categoryId, required bool isSelected, required Set<int> pendingServiceIds})`](../lib/features/search/presentation/cubit/search_cubit.dart#L720) — **خاص** — ينفّذ منطق `emit local service selection` داخل `SearchCubit`.
- [`CategoryServicesDataModel _copyCategoryServiceSelection(CategoryServicesDataModel data, {required int serviceId, required bool isSelected})`](../lib/features/search/presentation/cubit/search_cubit.dart#L775) — **خاص** — ينفّذ منطق `copy category service selection` داخل `SearchCubit`.
- [`int _nextSelectedCount(int current, {required bool increment})`](../lib/features/search/presentation/cubit/search_cubit.dart#L815) — **خاص** — ينفّذ منطق `next selected count` داخل `SearchCubit`.
- [`bool? _serviceSelection(CategoryServicesDataModel? data, int serviceId)`](../lib/features/search/presentation/cubit/search_cubit.dart#L820) — **خاص** — ينفّذ منطق `service selection` داخل `SearchCubit`.
- [`void _onCartSyncEvent(CartSyncEvent event)`](../lib/features/search/presentation/cubit/search_cubit.dart#L828) — **خاص** — يعالج حدث `on cart sync event` داخل `SearchCubit`.
- [`void _emitSelectionSnapshot(Set<int> selectedServiceIds, {Map<int, int>? categorySelectedCounts})`](../lib/features/search/presentation/cubit/search_cubit.dart#L865) — **خاص** — ينفّذ منطق `emit selection snapshot` داخل `SearchCubit`.
- [`void _emitServiceSelectionInLoadedCategories({required int serviceId, required bool isSelected})`](../lib/features/search/presentation/cubit/search_cubit.dart#L916) — **خاص** — ينفّذ منطق `emit service selection in loaded categories` داخل `SearchCubit`.
- [`void _emitAllServicesUnselected()`](../lib/features/search/presentation/cubit/search_cubit.dart#L941) — **خاص** — ينفّذ منطق `emit all services unselected` داخل `SearchCubit`.
- [`CategoryServicesDataModel _copyAllCategoryServicesSelection(CategoryServicesDataModel data, {required bool isSelected})`](../lib/features/search/presentation/cubit/search_cubit.dart#L965) — **خاص** — ينفّذ منطق `copy all category services selection` داخل `SearchCubit`.
- [`Future<void> close()`](../lib/features/search/presentation/cubit/search_cubit.dart#L994) — يغلق الـ Cubit أو الـ streams والموارد التابعة له.

### `features/search/presentation/cubit/search_state.dart`

- [`class SearchState`](../lib/features/search/presentation/cubit/search_state.dart#L5) — الكلاس الذي يدير حالة وتفاعلات `search state`.
- [`const SearchState({this.items = const [], this.categories = const [], this.serviceCategories = const [], this.isLoadingServiceCategories = false, this.categorySelectedCounts = const {}, this.isLoading = false, this.isLoadingMore = false, this.error, this.hasMore = true, this.currentPage = 1, this.selectedCategoryId, this.keyword = '', this.userLatitude, this.userLongitude, this.isLoadingServices = false, this.servicesError, this.servicesData, this.services = const [], this.servicesByCategoryId = const {}, this.loadingServiceCategoryIds = const {}, this.loadingMoreServiceCategoryIds = const {}, this.pendingServiceIds = const {}, this.cartActionError, this.categoriesError, this.serviceCategoriesError, this.filterError})`](../lib/features/search/presentation/cubit/search_state.dart#L54) — ينشئ كائنًا من `SearchState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`SearchState copyWith({List<SearchProviderModel>? items, List<CategoryModel>? categories, List<CategoryModel>? serviceCategories, bool? isLoadingServiceCategories, Map<int, int>? categorySelectedCounts, bool? isLoading, bool? isLoadingMore, String? error, bool clearError = false, bool? hasMore, int? currentPage, int? selectedCategoryId, bool clearSelectedCategory = false, String? keyword, double? userLatitude, double? userLongitude, bool? isLoadingServices, String? servicesError, bool clearServicesError = false, CategoryServicesDataModel? servicesData, List<ServiceItemModel>? services, Map<int, CategoryServicesDataModel>? servicesByCategoryId, Set<int>? loadingServiceCategoryIds, Set<int>? loadingMoreServiceCategoryIds, Set<int>? pendingServiceIds, String? cartActionError, bool clearCartActionError = false, String? categoriesError, bool clearCategoriesError = false, String? serviceCategoriesError, bool clearServiceCategoriesError = false, String? filterError, bool clearFilterError = false})`](../lib/features/search/presentation/cubit/search_state.dart#L83) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `features/search/presentation/screens/choose_provider_screen.dart`

- [`class ChooseProviderScreen`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L14) — الكلاس الذي يمثل شاشة `choose provider screen`.
- [`const ChooseProviderScreen({super.key})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L15) — ينشئ كائنًا من `ChooseProviderScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildBody(BuildContext context, CartState state)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L92) — **خاص** — ينفّذ منطق `build body` داخل `ChooseProviderScreen`.
- [`class _CoveragePill`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L128) — **خاص** — الكلاس الذي يمثل شاشة `coverage pill`.
- [`const _CoveragePill({required this.provider})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L132) — **خاص** — ينشئ كائنًا من `CoveragePill` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L134) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ProviderCard`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L187) — **خاص** — الكلاس الذي يمثل شاشة `provider card`.
- [`const _ProviderCard({required this.provider, required this.isSelected, required this.onTap})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L192) — **خاص** — ينشئ كائنًا من `ProviderCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L198) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ChooseProviderBottomBar`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L452) — **خاص** — الكلاس الذي يمثل شاشة `choose provider bottom bar`.
- [`const _ChooseProviderBottomBar({required this.provider})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L454) — **خاص** — ينشئ كائنًا من `ChooseProviderBottomBar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L456) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _Initials`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L577) — **خاص** — الكلاس الذي يمثل شاشة `initials`.
- [`const _Initials({required this.name})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L579) — **خاص** — ينشئ كائنًا من `Initials` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L581) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _EmptyView`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L601) — **خاص** — الكلاس الذي يمثل شاشة `empty view`.
- [`const _EmptyView()`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L602) — **خاص** — ينشئ كائنًا من `EmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L604) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ErrorView`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L636) — **خاص** — الكلاس الذي يمثل شاشة `error view`.
- [`const _ErrorView({required this.message, required this.onRetry})`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L640) — **خاص** — ينشئ كائنًا من `ErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L642) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String _money(double value)`](../lib/features/search/presentation/screens/choose_provider_screen.dart#L686) — **خاص** — ينفّذ منطق `money` داخل هذا الملف.

### `features/search/presentation/screens/search_screen.dart`

- [`class SearchScreen`](../lib/features/search/presentation/screens/search_screen.dart#L19) — الكلاس الذي يمثل شاشة `search screen`.
- [`const SearchScreen({super.key, this.userLatitude, this.userLongitude, this.categoryId, this.initialTabIndex = 0, this.enableCartFeatures = true})`](../lib/features/search/presentation/screens/search_screen.dart#L26) — ينشئ كائنًا من `SearchScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<SearchScreen> createState()`](../lib/features/search/presentation/screens/search_screen.dart#L35) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _SearchScreenState`](../lib/features/search/presentation/screens/search_screen.dart#L39) — **خاص** — الكلاس الذي يمثل شاشة `search screen state`.
- [`bool get _showServicesTab`](../lib/features/search/presentation/screens/search_screen.dart#L46) — **خاص** — يعرض أو يفتح `show services tab` داخل `_SearchScreenState`.
- [`void initState()`](../lib/features/search/presentation/screens/search_screen.dart#L51) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onScroll()`](../lib/features/search/presentation/screens/search_screen.dart#L72) — **خاص** — يعالج حدث `on scroll` داخل `_SearchScreenState`.
- [`void _onSearchChanged(String value)`](../lib/features/search/presentation/screens/search_screen.dart#L80) — **خاص** — يعالج حدث `on search changed` داخل `_SearchScreenState`.
- [`void _openFilterSheet()`](../lib/features/search/presentation/screens/search_screen.dart#L87) — **خاص** — يعرض أو يفتح `open filter sheet` داخل `_SearchScreenState`.
- [`void dispose()`](../lib/features/search/presentation/screens/search_screen.dart#L105) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/screens/search_screen.dart#L114) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/search/presentation/widgets/category_chip.dart`

- [`class CategoryChip`](../lib/features/search/presentation/widgets/category_chip.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryChip({super.key, required this.category, required this.isSelected, required this.onTap, this.badgeCount})`](../lib/features/search/presentation/widgets/category_chip.dart#L15) — ينشئ كائنًا من `CategoryChip` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/category_chip.dart#L23) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _chipImage({required bool isSelected})`](../lib/features/search/presentation/widgets/category_chip.dart#L102) — **خاص** — ينفّذ منطق `chip image` داخل `CategoryChip`.

### `features/search/presentation/widgets/filter_bottom_sheet.dart`

- [`class FilterBottomSheet`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const FilterBottomSheet({super.key, this.hideProviderFilters = false})`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L13) — ينشئ كائنًا من `FilterBottomSheet` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L25) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SectionTitle`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L205) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SectionTitle({required this.title})`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L207) — **خاص** — ينشئ كائنًا من `SectionTitle` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L209) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SortOptionTile`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L222) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SortOptionTile({required this.label, required this.value, required this.groupValue, required this.onTap})`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L228) — **خاص** — ينشئ كائنًا من `SortOptionTile` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L235) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _LookupDropdown`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L302) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _LookupDropdown({required this.hint, required this.isLoading, required this.items, required this.value, required this.onChanged, this.isDisabled = false})`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L310) — **خاص** — ينشئ كائنًا من `LookupDropdown` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L319) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _SortOption`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L368) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _SortOption({required this.value, required this.labelKey})`](../lib/features/search/presentation/widgets/filter_bottom_sheet.dart#L371) — **خاص** — ينشئ كائنًا من `SortOption` ويهيّئ الاعتماديات والقيم المطلوبة.

### `features/search/presentation/widgets/provider_card.dart`

- [`class ProviderCard`](../lib/features/search/presentation/widgets/provider_card.dart#L14) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderCard({super.key, required this.provider})`](../lib/features/search/presentation/widgets/provider_card.dart#L17) — ينشئ كائنًا من `ProviderCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/provider_card.dart#L19) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildImageSection()`](../lib/features/search/presentation/widgets/provider_card.dart#L100) — **خاص** — ينفّذ منطق `build image section` داخل `ProviderCard`.
- [`bool _hasText(String? value)`](../lib/features/search/presentation/widgets/provider_card.dart#L137) — **خاص** — يفحص شرط `has text` ويعيد النتيجة داخل `ProviderCard`.
- [`class _DiscountChipsRow`](../lib/features/search/presentation/widgets/provider_card.dart#L140) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _DiscountChipsRow({this.categoryName, this.maxDiscount})`](../lib/features/search/presentation/widgets/provider_card.dart#L144) — **خاص** — ينشئ كائنًا من `DiscountChipsRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/provider_card.dart#L146) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildChip(String label, Color bg, Color fg, FontWeight weight)`](../lib/features/search/presentation/widgets/provider_card.dart#L177) — **خاص** — ينفّذ منطق `build chip` داخل `_DiscountChipsRow`.
- [`class _RatingAndLocationRow`](../lib/features/search/presentation/widgets/provider_card.dart#L196) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _RatingAndLocationRow({required this.provider})`](../lib/features/search/presentation/widgets/provider_card.dart#L199) — **خاص** — ينشئ كائنًا من `RatingAndLocationRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/provider_card.dart#L201) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/search/presentation/widgets/search_app_bar.dart`

- [`class SearchAppBar`](../lib/features/search/presentation/widgets/search_app_bar.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SearchAppBar({super.key, required this.controller, required this.onChanged, this.onFilterTap, this.hasActiveFilters = false})`](../lib/features/search/presentation/widgets/search_app_bar.dart#L16) — ينشئ كائنًا من `SearchAppBar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<SearchAppBar> createState()`](../lib/features/search/presentation/widgets/search_app_bar.dart#L24) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _SearchAppBarState`](../lib/features/search/presentation/widgets/search_app_bar.dart#L28) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`TextEditingController get controller`](../lib/features/search/presentation/widgets/search_app_bar.dart#L39) — **خاص** — ينفّذ منطق `controller` داخل `_SearchAppBarState`.
- [`bool get _showOverlay`](../lib/features/search/presentation/widgets/search_app_bar.dart#L40) — **خاص** — يعرض أو يفتح `show overlay` داخل `_SearchAppBarState`.
- [`void initState()`](../lib/features/search/presentation/widgets/search_app_bar.dart#L42) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _onFocusChanged()`](../lib/features/search/presentation/widgets/search_app_bar.dart#L56) — **خاص** — يعالج حدث `on focus changed` داخل `_SearchAppBarState`.
- [`void _onTextChanged()`](../lib/features/search/presentation/widgets/search_app_bar.dart#L60) — **خاص** — يعالج حدث `on text changed` داخل `_SearchAppBarState`.
- [`void dispose()`](../lib/features/search/presentation/widgets/search_app_bar.dart#L64) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_app_bar.dart#L73) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/search/presentation/widgets/search_providers_tab.dart`

- [`class SearchProvidersTab`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SearchProvidersTab({super.key, required this.scrollController})`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L15) — ينشئ كائنًا من `SearchProvidersTab` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ResultsBody`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L66) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ResultsBody({required this.scrollController})`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L68) — **خاص** — ينشئ كائنًا من `ResultsBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L70) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _EmptyView`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L118) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _EmptyView()`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L119) — **خاص** — ينشئ كائنًا من `EmptyView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L121) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ErrorView`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L155) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ErrorView({required this.message, required this.onRetry})`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L159) — **خاص** — ينشئ كائنًا من `ErrorView` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_providers_tab.dart#L161) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/search/presentation/widgets/search_services_tab.dart`

- [`class SearchServicesTab`](../lib/features/search/presentation/widgets/search_services_tab.dart#L14) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SearchServicesTab({super.key, required this.enableCartFeatures})`](../lib/features/search/presentation/widgets/search_services_tab.dart#L17) — ينشئ كائنًا من `SearchServicesTab` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<SearchServicesTab> createState()`](../lib/features/search/presentation/widgets/search_services_tab.dart#L19) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ServicesTabState`](../lib/features/search/presentation/widgets/search_services_tab.dart#L23) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L29) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`String? _currentServiceSearch(BuildContext context)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L118) — **خاص** — ينفّذ منطق `current service search` داخل `_ServicesTabState`.
- [`void _autoSelectFirstCategory(BuildContext context, SearchState state)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L124) — **خاص** — ينفّذ منطق `auto select first category` داخل `_ServicesTabState`.
- [`Widget _buildServicesBody(BuildContext context, SearchState state, int totalSelected)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L153) — **خاص** — ينفّذ منطق `build services body` داخل `_ServicesTabState`.
- [`class _ServiceCardConnector`](../lib/features/search/presentation/widgets/search_services_tab.dart#L324) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ServiceCardConnector({required this.serviceId, required this.categoryId, required this.serviceName, required this.isSelected})`](../lib/features/search/presentation/widgets/search_services_tab.dart#L330) — **خاص** — ينشئ كائنًا من `ServiceCardConnector` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L337) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ServiceCard`](../lib/features/search/presentation/widgets/search_services_tab.dart#L369) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ServiceCard({required this.serviceName, required this.isSelected, required this.isPending, required this.onToggle})`](../lib/features/search/presentation/widgets/search_services_tab.dart#L375) — **خاص** — ينشئ كائنًا من `ServiceCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L382) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ChooseProviderBar`](../lib/features/search/presentation/widgets/search_services_tab.dart#L482) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ChooseProviderBar({required this.count})`](../lib/features/search/presentation/widgets/search_services_tab.dart#L484) — **خاص** — ينشئ كائنًا من `ChooseProviderBar` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_services_tab.dart#L486) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `features/search/presentation/widgets/search_shimmer.dart`

- [`class SearchShimmer`](../lib/features/search/presentation/widgets/search_shimmer.dart#L5) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const SearchShimmer({super.key})`](../lib/features/search/presentation/widgets/search_shimmer.dart#L6) — ينشئ كائنًا من `SearchShimmer` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_shimmer.dart#L8) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ShimmerCard`](../lib/features/search/presentation/widgets/search_shimmer.dart#L23) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ShimmerCard()`](../lib/features/search/presentation/widgets/search_shimmer.dart#L24) — **خاص** — ينشئ كائنًا من `ShimmerCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/features/search/presentation/widgets/search_shimmer.dart#L26) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Module: firebase_options.dart

### `firebase_options.dart`

- [`class DefaultFirebaseOptions`](../lib/firebase_options.dart#L7) — الكلاس الذي يجمع مسؤوليات `default firebase options`.
- [`static FirebaseOptions get currentPlatform`](../lib/firebase_options.dart#L18) — ينفّذ منطق `current platform` داخل `DefaultFirebaseOptions`.


## Module: main.dart

### `main.dart`

- [`void main()`](../lib/main.dart#L28) — نقطة بدء التطبيق؛ تهيّئ الخدمات ثم تشغّل واجهة Flutter.
- [`Future<void> _initializeNonBlockingServices()`](../lib/main.dart#L73) — **خاص** — ينفّذ منطق `initialize non blocking services` داخل هذا الملف.
- [`bool get _shouldInitializeFirebase`](../lib/main.dart#L95) — **خاص** — يفحص شرط `should initialize firebase` ويعيد النتيجة داخل هذا الملف.
- [`class MyApp`](../lib/main.dart#L104) — الكلاس الذي يجمع مسؤوليات `my app`.
- [`const MyApp({super.key, required this.initialLocation})`](../lib/main.dart#L107) — ينشئ كائنًا من `MyApp` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<MyApp> createState()`](../lib/main.dart#L109) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _MyAppState`](../lib/main.dart#L113) — **خاص** — الكلاس الذي يجمع مسؤوليات `my app state`.
- [`void initState()`](../lib/main.dart#L117) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Widget build(BuildContext context)`](../lib/main.dart#L123) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class AppVideoSplash`](../lib/main.dart#L257) — الكلاس الذي يجمع مسؤوليات `app video splash`.
- [`const AppVideoSplash({super.key, required this.onFinished})`](../lib/main.dart#L260) — ينشئ كائنًا من `AppVideoSplash` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<AppVideoSplash> createState()`](../lib/main.dart#L262) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AppVideoSplashState`](../lib/main.dart#L266) — **خاص** — الكلاس الذي يجمع مسؤوليات `app video splash state`.
- [`void initState()`](../lib/main.dart#L275) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void _handleVideoProgress()`](../lib/main.dart#L299) — **خاص** — يعالج حدث `handle video progress` داخل `_AppVideoSplashState`.
- [`void _finish()`](../lib/main.dart#L311) — **خاص** — ينفّذ منطق `finish` داخل `_AppVideoSplashState`.
- [`void dispose()`](../lib/main.dart#L317) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`Widget build(BuildContext context)`](../lib/main.dart#L325) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Module: medicard_network

### `medicard_network/domain/usecases/get_package_details_usecase.dart`

- [`class GetPackageDetailsUseCase`](../lib/medicard_network/domain/usecases/get_package_details_usecase.dart#L5) — الكلاس الذي يعزل عملية أعمال واحدة: `get package details use case`.
- [`GetPackageDetailsUseCase(this._repository)`](../lib/medicard_network/domain/usecases/get_package_details_usecase.dart#L10) — ينشئ كائنًا من `GetPackageDetailsUseCase` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ApiResult<PackageDetailsResponse>> call({required int packageId})`](../lib/medicard_network/domain/usecases/get_package_details_usecase.dart#L12) — ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.

### `medicard_network/logic/provider_page_cubit.dart`

- [`class ProviderPageCubit`](../lib/medicard_network/logic/provider_page_cubit.dart#L22) — الكلاس الذي يجمع مسؤوليات `provider page cubit`.
- [`ProviderPageCubit(this._medicardRepository, this._invoiceRepository, this._cartRepository, this._cartSyncService, this.providerId)`](../lib/medicard_network/logic/provider_page_cubit.dart#L43) — ينشئ كائنًا من `ProviderPageCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> init()`](../lib/medicard_network/logic/provider_page_cubit.dart#L53) — ينفّذ منطق `init` داخل `ProviderPageCubit`.
- [`Future<void> loadProviderPage()`](../lib/medicard_network/logic/provider_page_cubit.dart#L55) — يحمّل `load provider page` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadPackages({bool reset = false})`](../lib/medicard_network/logic/provider_page_cubit.dart#L93) — يحمّل `load packages` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadMorePackages()`](../lib/medicard_network/logic/provider_page_cubit.dart#L159) — يحمّل `load more packages` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadReviews({bool reset = false})`](../lib/medicard_network/logic/provider_page_cubit.dart#L161) — يحمّل `load reviews` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadMoreReviews()`](../lib/medicard_network/logic/provider_page_cubit.dart#L227) — يحمّل `load more reviews` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadProviderServices({bool reset = false})`](../lib/medicard_network/logic/provider_page_cubit.dart#L229) — يحمّل `load provider services` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadServices({bool reset = false})`](../lib/medicard_network/logic/provider_page_cubit.dart#L232) — يحمّل `load services` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadMoreServices()`](../lib/medicard_network/logic/provider_page_cubit.dart#L302) — يحمّل `load more services` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> loadCategories()`](../lib/medicard_network/logic/provider_page_cubit.dart#L304) — يحمّل `load categories` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`void _updateTab(int categoryId, CategoryTab Function(CategoryTab) update)`](../lib/medicard_network/logic/provider_page_cubit.dart#L357) — **خاص** — يحدّث `update tab` داخل `ProviderPageCubit`.
- [`bool _isArabic()`](../lib/medicard_network/logic/provider_page_cubit.dart#L364) — **خاص** — يفحص شرط `is arabic` ويعيد النتيجة داخل `ProviderPageCubit`.
- [`void _mergeCategoryServices(List<ProviderService> services)`](../lib/medicard_network/logic/provider_page_cubit.dart#L367) — **خاص** — ينفّذ منطق `merge category services` داخل `ProviderPageCubit`.
- [`Future<void> loadCategoryServices(int categoryId, {bool reset = false})`](../lib/medicard_network/logic/provider_page_cubit.dart#L383) — يحمّل `load category services` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<void> selectCategoryTab(int index)`](../lib/medicard_network/logic/provider_page_cubit.dart#L454) — يغيّر الاختيار الخاص بـ `select category tab` داخل `ProviderPageCubit`.
- [`Future<void> retryTabLoad(int index)`](../lib/medicard_network/logic/provider_page_cubit.dart#L464) — يعيد تحميل أو محاولة `retry tab load` داخل `ProviderPageCubit`.
- [`Future<void> loadMoreCategoryServices()`](../lib/medicard_network/logic/provider_page_cubit.dart#L473) — يحمّل `load more category services` ويحدّث الحالة المرتبطة داخل `ProviderPageCubit`.
- [`Future<bool> requireAuth()`](../lib/medicard_network/logic/provider_page_cubit.dart#L485) — ينفّذ منطق `require auth` داخل `ProviderPageCubit`.
- [`Future<bool> addToCart(int serviceId, {int? categoryId})`](../lib/medicard_network/logic/provider_page_cubit.dart#L492) — ينشئ أو يضيف `add to cart` داخل `ProviderPageCubit`.
- [`Future<void> removeFromCart(int serviceId)`](../lib/medicard_network/logic/provider_page_cubit.dart#L577) — يحذف أو يمسح `remove from cart` داخل `ProviderPageCubit`.
- [`Future<void> togglePackageDetails(int packageId)`](../lib/medicard_network/logic/provider_page_cubit.dart#L617) — يغيّر الاختيار الخاص بـ `toggle package details` داخل `ProviderPageCubit`.
- [`Future<ApiResult<CreatedInvoice>> createInvoiceFromPackage({required int packageId, required int providerBranchId, bool isCash = true, String? cardNumber})`](../lib/medicard_network/logic/provider_page_cubit.dart#L681) — ينشئ أو يضيف `create invoice from package` داخل `ProviderPageCubit`.
- [`void updateSearchQuery(String query)`](../lib/medicard_network/logic/provider_page_cubit.dart#L716) — يحدّث `update search query` داخل `ProviderPageCubit`.
- [`Future<void> switchView(ProviderViewType view)`](../lib/medicard_network/logic/provider_page_cubit.dart#L745) — ينفّذ منطق `switch view` داخل `ProviderPageCubit`.
- [`List<ProviderService> _filterServices(List<ProviderService> services, String? query)`](../lib/medicard_network/logic/provider_page_cubit.dart#L763) — **خاص** — ينفّذ منطق `filter services` داخل `ProviderPageCubit`.
- [`void _setServiceSelected({required int serviceId, required bool isSelected, required Set<int> pendingCartActionIds})`](../lib/medicard_network/logic/provider_page_cubit.dart#L776) — **خاص** — يحدّث `set service selected` داخل `ProviderPageCubit`.
- [`void _onCartSyncEvent(CartSyncEvent event)`](../lib/medicard_network/logic/provider_page_cubit.dart#L799) — **خاص** — يعالج حدث `on cart sync event` داخل `ProviderPageCubit`.
- [`List<ProviderPackage> _filterPackages(List<ProviderPackage> packages, String? query)`](../lib/medicard_network/logic/provider_page_cubit.dart#L850) — **خاص** — ينفّذ منطق `filter packages` داخل `ProviderPageCubit`.
- [`List<ProviderReview> _filterReviews(List<ProviderReview> reviews, String? query)`](../lib/medicard_network/logic/provider_page_cubit.dart#L861) — **خاص** — ينفّذ منطق `filter reviews` داخل `ProviderPageCubit`.
- [`Future<void> close()`](../lib/medicard_network/logic/provider_page_cubit.dart#L876) — يغلق الـ Cubit أو الـ streams والموارد التابعة له.

### `medicard_network/logic/provider_page_state.dart`

- [`enum ProviderViewType`](../lib/medicard_network/logic/provider_page_state.dart#L4) — يعرّف القيم الثابتة الخاصة بـ `provider view type`.
- [`class CategoryTab`](../lib/medicard_network/logic/provider_page_state.dart#L12) — الكلاس الذي يجمع مسؤوليات `category tab`.
- [`const CategoryTab({required this.categoryId, required this.categoryName, this.imageUrl, this.services, this.isLoading = false, this.hasMore = true, this.error})`](../lib/medicard_network/logic/provider_page_state.dart#L21) — ينشئ كائنًا من `CategoryTab` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`int get selectedCount`](../lib/medicard_network/logic/provider_page_state.dart#L31) — يغيّر الاختيار الخاص بـ `selected count` داخل `CategoryTab`.
- [`CategoryTab copyWith({dynamic services, bool? isLoading, bool? hasMore, String? error, bool clearError = false})`](../lib/medicard_network/logic/provider_page_state.dart#L33) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.
- [`class ProviderPageState`](../lib/medicard_network/logic/provider_page_state.dart#L52) — الكلاس الذي يجمع مسؤوليات `provider page state`.
- [`const ProviderPageState({this.providerData, this.isProviderLoading = false, this.providerError, this.services = const [], this.fullServices = const [], this.isServicesLoading = false, this.isServicesLoadingMore = false, this.servicesHasMore = false, this.servicesError, this.categoryTabs = const [], this.selectedCategoryIndex = 0, this.packages = const [], this.fullPackages = const [], this.isPackagesLoading = false, this.isPackagesLoadingMore = false, this.packagesHasMore = true, this.packagesError, this.packageDetailsById = const {}, this.loadingPackageDetailsIds = const {}, this.packageDetailsErrors = const {}, this.reviews = const [], this.fullReviews = const [], this.isReviewsLoading = false, this.isReviewsLoadingMore = false, this.reviewsHasMore = true, this.reviewsError, this.currentView = ProviderViewType.services, this.catalogView = ProviderViewType.services, this.searchQuery, this.pendingCartActionIds = const {}, this.pendingPackageInvoiceIds = const {}})`](../lib/medicard_network/logic/provider_page_state.dart#L91) — ينشئ كائنًا من `ProviderPageState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`CategoryTab? get selectedTab`](../lib/medicard_network/logic/provider_page_state.dart#L125) — يغيّر الاختيار الخاص بـ `selected tab` داخل `ProviderPageState`.
- [`int get displayServicesCount`](../lib/medicard_network/logic/provider_page_state.dart#L131) — ينفّذ منطق `display services count` داخل `ProviderPageState`.
- [`bool isServiceInCart(int serviceId)`](../lib/medicard_network/logic/provider_page_state.dart#L133) — يفحص شرط `is service in cart` ويعيد النتيجة داخل `ProviderPageState`.
- [`int getCartItemCount()`](../lib/medicard_network/logic/provider_page_state.dart#L139) — يجلب `get cart item count` من مصدر البيانات المناسب داخل `ProviderPageState`.
- [`ProviderPageState copyWith({ProviderPageData? providerData, bool resetProviderData = false, bool? isProviderLoading, String? providerError, bool resetProviderError = false, List<ProviderService>? services, List<ProviderService>? fullServices, bool? isServicesLoading, bool? isServicesLoadingMore, bool? servicesHasMore, String? servicesError, bool resetServicesError = false, List<CategoryTab>? categoryTabs, int? selectedCategoryIndex, List<ProviderPackage>? packages, List<ProviderPackage>? fullPackages, bool? isPackagesLoading, bool? isPackagesLoadingMore, bool? packagesHasMore, String? packagesError, bool resetPackagesError = false, Map<int, PackageDetailsData>? packageDetailsById, Set<int>? loadingPackageDetailsIds, Map<int, String>? packageDetailsErrors, List<ProviderReview>? reviews, List<ProviderReview>? fullReviews, bool? isReviewsLoading, bool? isReviewsLoadingMore, bool? reviewsHasMore, String? reviewsError, bool resetReviewsError = false, ProviderViewType? currentView, ProviderViewType? catalogView, String? searchQuery, bool resetSearchQuery = false, Set<int>? pendingCartActionIds, Set<int>? pendingPackageInvoiceIds})`](../lib/medicard_network/logic/provider_page_state.dart#L147) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.

### `medicard_network/presentation/pages/branches_screen.dart`

- [`class BranchesScreen`](../lib/medicard_network/presentation/pages/branches_screen.dart#L11) — الكلاس الذي يمثل شاشة `branches screen`.
- [`const BranchesScreen({super.key, required this.branches, this.providerName})`](../lib/medicard_network/presentation/pages/branches_screen.dart#L15) — ينشئ كائنًا من `BranchesScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<BranchesScreen> createState()`](../lib/medicard_network/presentation/pages/branches_screen.dart#L17) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _BranchesScreenState`](../lib/medicard_network/presentation/pages/branches_screen.dart#L21) — **خاص** — الكلاس الذي يمثل شاشة `branches screen state`.
- [`void initState()`](../lib/medicard_network/presentation/pages/branches_screen.dart#L25) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/medicard_network/presentation/pages/branches_screen.dart#L34) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`List<ProviderBranch> get _filteredBranches`](../lib/medicard_network/presentation/pages/branches_screen.dart#L40) — **خاص** — ينفّذ منطق `filtered branches` داخل `_BranchesScreenState`.
- [`String _branchesCountText(int count, BuildContext context)`](../lib/medicard_network/presentation/pages/branches_screen.dart#L49) — **خاص** — ينفّذ منطق `branches count text` داخل `_BranchesScreenState`.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/pages/branches_screen.dart#L65) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildHeader(BuildContext context)`](../lib/medicard_network/presentation/pages/branches_screen.dart#L186) — **خاص** — ينفّذ منطق `build header` داخل `_BranchesScreenState`.
- [`class _BranchCard`](../lib/medicard_network/presentation/pages/branches_screen.dart#L247) — **خاص** — الكلاس الذي يمثل شاشة `branch card`.
- [`const _BranchCard({required this.branch, required this.onTap})`](../lib/medicard_network/presentation/pages/branches_screen.dart#L251) — **خاص** — ينشئ كائنًا من `BranchCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> _openMap()`](../lib/medicard_network/presentation/pages/branches_screen.dart#L253) — **خاص** — يعرض أو يفتح `open map` داخل `_BranchCard`.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/pages/branches_screen.dart#L262) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/pages/provider_page_screen.dart`

- [`class ProviderPageScreen`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L15) — الكلاس الذي يمثل شاشة `provider page screen`.
- [`const ProviderPageScreen({super.key, required this.providerId, this.autoOpenPackageId})`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L22) — ينشئ كائنًا من `ProviderPageScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ProviderPageScreen> createState()`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L28) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ProviderPageScreenState`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L32) — **خاص** — الكلاس الذي يمثل شاشة `provider page screen state`.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L35) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`bool _handleScrollNotification(ScrollNotification scrollInfo, ProviderPageState state, ProviderPageCubit cubit)`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L104) — **خاص** — يعالج حدث `handle scroll notification` داخل `_ProviderPageScreenState`.
- [`void _openBranchSelector(List<ProviderBranch>? branches, String? providerName)`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L135) — **خاص** — يعرض أو يفتح `open branch selector` داخل `_ProviderPageScreenState`.
- [`class _AutoOpenPackage`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L150) — **خاص** — الكلاس الذي يمثل شاشة `auto open package`.
- [`const _AutoOpenPackage({required this.packageId, this.selectedBranch})`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L158) — **خاص** — ينشئ كائنًا من `AutoOpenPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<_AutoOpenPackage> createState()`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L160) — **خاص** — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _AutoOpenPackageState`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L164) — **خاص** — الكلاس الذي يمثل شاشة `auto open package state`.
- [`void initState()`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L167) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`Future<void> _open()`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L173) — **خاص** — يعرض أو يفتح `open` داخل `_AutoOpenPackageState`.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/pages/provider_page_screen.dart#L206) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/pages/reviews_screen.dart`

- [`class ReviewsScreen`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L12) — الكلاس الذي يمثل شاشة `reviews screen`.
- [`const ReviewsScreen({super.key, required this.providerId, this.providerName})`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L18) — ينشئ كائنًا من `ReviewsScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<ReviewsScreen> createState()`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L24) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _ReviewsScreenState`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L28) — **خاص** — الكلاس الذي يمثل شاشة `reviews screen state`.
- [`void initState()`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L31) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L41) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onScroll()`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L49) — **خاص** — يعالج حدث `on scroll` داخل `_ReviewsScreenState`.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/pages/reviews_screen.dart#L57) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/category_service_card.dart`

- [`class CategoryServiceCard`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryServiceCard({super.key, required this.service, this.categoryId})`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L25) — ينشئ كائنًا من `CategoryServiceCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L27) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ServicePrice`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L209) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _ServicePrice({required this.service})`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L213) — **خاص** — ينشئ كائنًا من `ServicePrice` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/category_service_card.dart#L215) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/package_details_sheet.dart`

- [`void openPackageDetailsSheet(BuildContext context, ProviderPageCubit cubit, ProviderPackage packageData, ProviderBranch? selectedBranch)`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L16) — يعرض أو يفتح `open package details sheet` داخل هذا الملف.
- [`Future<void> createPackageInvoice(BuildContext context, ProviderPageCubit cubit, int packageId, ProviderBranch? selectedBranch)`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L48) — ينشئ أو يضيف `create package invoice` داخل هذا الملف.
- [`Future<void> openPackageCheckout(BuildContext context, ProviderPageCubit cubit, ProviderPackage packageData, ProviderBranch? selectedBranch, {PackageDetailsData? details})`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L63) — يعرض أو يفتح `open package checkout` داخل هذا الملف.
- [`class _PackageDetailsSheetBody`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L111) — **خاص** — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const _PackageDetailsSheetBody({required this.packageData, required this.selectedBranch})`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L115) — **خاص** — ينشئ كائنًا من `PackageDetailsSheetBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/package_details_sheet.dart#L120) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_content_section.dart`

- [`class ProviderContentSection`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L19) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderContentSection({super.key, required this.selectedBranch})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L24) — ينشئ كائنًا من `ProviderContentSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L26) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class CategoryTabsSection`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L46) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryTabsSection({super.key, required this.state})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L51) — ينشئ كائنًا من `CategoryTabsSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L53) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ProviderServicesBody`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L95) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderServicesBody({super.key, required this.state})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L99) — ينشئ كائنًا من `ProviderServicesBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L101) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class TabServicesBody`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L156) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const TabServicesBody({super.key, required this.state})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L160) — ينشئ كائنًا من `TabServicesBody` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L162) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class PackagesSection`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L247) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PackagesSection({super.key, required this.state, required this.selectedBranch})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L252) — ينشئ كائنًا من `PackagesSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L258) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ReviewsSection`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L319) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ReviewsSection({super.key, required this.state})`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L323) — ينشئ كائنًا من `ReviewsSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_content_section.dart#L325) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_package_card.dart`

- [`class ProviderPackageCard`](../lib/medicard_network/presentation/widgets/provider_package_card.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderPackageCard({super.key, required this.packageData, this.onDetailsTap, this.onQuickAdd})`](../lib/medicard_network/presentation/widgets/provider_package_card.dart#L16) — ينشئ كائنًا من `ProviderPackageCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_package_card.dart#L23) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_rebuild_scopes.dart`

- [`class ProviderRebuildScopes`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L3) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`static bool isHeaderSliceChanged(ProviderPageState previous, ProviderPageState current)`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L8) — يفحص شرط `is header slice changed` ويعيد النتيجة داخل `ProviderRebuildScopes`.
- [`static bool isSearchRowSliceChanged(ProviderPageState previous, ProviderPageState current)`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L17) — يفحص شرط `is search row slice changed` ويعيد النتيجة داخل `ProviderRebuildScopes`.
- [`static bool isCartBarSliceChanged(ProviderPageState previous, ProviderPageState current)`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L24) — يفحص شرط `is cart bar slice changed` ويعيد النتيجة داخل `ProviderRebuildScopes`.
- [`static bool isContentSliceChanged(ProviderPageState previous, ProviderPageState current)`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L30) — يفحص شرط `is content slice changed` ويعيد النتيجة داخل `ProviderRebuildScopes`.
- [`static bool isPackageSheetSliceChanged(int packageId, ProviderPageState previous, ProviderPageState current)`](../lib/medicard_network/presentation/widgets/provider_rebuild_scopes.dart#L62) — يفحص شرط `is package sheet slice changed` ويعيد النتيجة داخل `ProviderRebuildScopes`.

### `medicard_network/presentation/widgets/provider_review_card.dart`

- [`class ProviderReviewCard`](../lib/medicard_network/presentation/widgets/provider_review_card.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderReviewCard({super.key, required this.review})`](../lib/medicard_network/presentation/widgets/provider_review_card.dart#L14) — ينشئ كائنًا من `ProviderReviewCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_review_card.dart#L16) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_search_row.dart`

- [`class ProviderSearchRow`](../lib/medicard_network/presentation/widgets/provider_search_row.dart#L11) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderSearchRow({super.key})`](../lib/medicard_network/presentation/widgets/provider_search_row.dart#L15) — ينشئ كائنًا من `ProviderSearchRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_search_row.dart#L17) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_service_card.dart`

- [`class ProviderServiceCard`](../lib/medicard_network/presentation/widgets/provider_service_card.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderServiceCard({super.key, required this.service})`](../lib/medicard_network/presentation/widgets/provider_service_card.dart#L20) — ينشئ كائنًا من `ProviderServiceCard` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_service_card.dart#L22) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_shared_widgets.dart`

- [`String formatPrice(double? price)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L12) — ينسّق `format price` للعرض أو الإرسال داخل هذا الملف.
- [`String packageImageUrl(String value)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L20) — ينفّذ منطق `package image url` داخل هذا الملف.
- [`class ProviderInfoRow`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L30) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderInfoRow({super.key, required this.data, required this.servicesCount, required this.selectedBranch, required this.onBranchTap, required this.onRatingTap})`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L37) — ينشئ كائنًا من `ProviderInfoRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L45) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class PackageServiceNames`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L203) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PackageServiceNames({super.key, required this.serviceNames})`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L206) — ينشئ كائنًا من `PackageServiceNames` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L208) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class PackagePlainServiceNames`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L250) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const PackagePlainServiceNames({super.key, required this.serviceNames})`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L253) — ينشئ كائنًا من `PackagePlainServiceNames` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L255) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class ServiceBadge`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L283) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ServiceBadge({super.key, required this.label, required this.color, required this.backgroundColor, this.icon})`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L289) — ينشئ كائنًا من `ServiceBadge` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L296) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class CategoryTabChip`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L326) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const CategoryTabChip({super.key, required this.tab, required this.isSelected, required this.onTap})`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L331) — ينشئ كائنًا من `CategoryTabChip` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_shared_widgets.dart#L337) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/presentation/widgets/provider_top_header.dart`

- [`class ProviderTopHeader`](../lib/medicard_network/presentation/widgets/provider_top_header.dart#L12) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const ProviderTopHeader({super.key, required this.selectedBranch, required this.onBranchTap})`](../lib/medicard_network/presentation/widgets/provider_top_header.dart#L18) — ينشئ كائنًا من `ProviderTopHeader` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/medicard_network/presentation/widgets/provider_top_header.dart#L24) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `medicard_network/repository/medicard_network_repository.dart`

- [`class MedicardNetworkRepository`](../lib/medicard_network/repository/medicard_network_repository.dart#L11) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `medicard network repository`.
- [`MedicardNetworkRepository(this._apiService)`](../lib/medicard_network/repository/medicard_network_repository.dart#L14) — ينشئ كائنًا من `MedicardNetworkRepository` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String _cleanError(Object error)`](../lib/medicard_network/repository/medicard_network_repository.dart#L16) — **خاص** — ينفّذ منطق `clean error` داخل `MedicardNetworkRepository`.
- [`void _logDebugError(String operation, Object error)`](../lib/medicard_network/repository/medicard_network_repository.dart#L18) — **خاص** — ينفّذ منطق `log debug error` داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<ProviderPageResponse>> getProviderPage({required int providerId})`](../lib/medicard_network/repository/medicard_network_repository.dart#L24) — يجلب `get provider page` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<List<ProviderBranch>>> getProviderBranchLocations({required int providerId})`](../lib/medicard_network/repository/medicard_network_repository.dart#L48) — يجلب `get provider branch locations` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<List<ProviderCategory>>> getProviderCategories({required int providerId})`](../lib/medicard_network/repository/medicard_network_repository.dart#L66) — يجلب `get provider categories` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<AllPackagesResponse>> getAllPackages({int pageNumber = 1, int pageSize = 15, String? search})`](../lib/medicard_network/repository/medicard_network_repository.dart#L83) — يجلب `get all packages` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<ServicesByCategoryResponse>> getServicesByCategory({required int providerId, required int categoryId, int pageNumber = 1, int pageSize = 20})`](../lib/medicard_network/repository/medicard_network_repository.dart#L107) — يجلب `get services by category` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<ProviderServicesResponse>> getProviderServices({required int providerId, String? search, int pageNumber = 1, int pageSize = 20})`](../lib/medicard_network/repository/medicard_network_repository.dart#L132) — يجلب `get provider services` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<ProviderReviewsResponse>> getProviderReviews({required int providerId, int pageNumber = 1, int pageSize = 20})`](../lib/medicard_network/repository/medicard_network_repository.dart#L158) — يجلب `get provider reviews` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<ProviderPackagesResponse>> getProviderPackages({required int providerId, int pageNumber = 1, int pageSize = 20})`](../lib/medicard_network/repository/medicard_network_repository.dart#L182) — يجلب `get provider packages` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.
- [`Future<ApiResult<PackageDetailsResponse>> getPackageDetails({required int packageId})`](../lib/medicard_network/repository/medicard_network_repository.dart#L206) — يجلب `get package details` من مصدر البيانات المناسب داخل `MedicardNetworkRepository`.

### `medicard_network/service/medicard_network_api_service.dart`

- [`class MedicardNetworkApiService`](../lib/medicard_network/service/medicard_network_api_service.dart#L11) — الكلاس الذي يقدّم خدمة `medicard network api service` لباقي التطبيق.
- [`factory MedicardNetworkApiService(Dio dio, {String baseUrl})`](../lib/medicard_network/service/medicard_network_api_service.dart#L13) — ينشئ كائنًا من `MedicardNetworkApiService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<ProviderPageResponse> getProviderPage(@Path("providerId") int providerId)`](../lib/medicard_network/service/medicard_network_api_service.dart#L16) — يجلب `get provider page` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ProviderBranchesResponse> getProviderBranchLocations(@Path("providerId") int providerId)`](../lib/medicard_network/service/medicard_network_api_service.dart#L21) — يجلب `get provider branch locations` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ProviderServicesResponse> getProviderServices(@Query("providerId") int providerId, {@Query("search") String? search, @Query("pageNumber") int? pageNumber, @Query("pageSize") int? pageSize})`](../lib/medicard_network/service/medicard_network_api_service.dart#L26) — يجلب `get provider services` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ProviderReviewsResponse> getProviderReviews(@Path("providerId") int providerId, {@Query("pageNumber") int? pageNumber, @Query("pageSize") int? pageSize})`](../lib/medicard_network/service/medicard_network_api_service.dart#L34) — يجلب `get provider reviews` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ProviderPackagesResponse> getProviderPackages(@Path("providerId") int providerId, {@Query("pageNumber") int? pageNumber, @Query("pageSize") int? pageSize})`](../lib/medicard_network/service/medicard_network_api_service.dart#L41) — يجلب `get provider packages` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<PackageDetailsResponse> getPackageDetails(@Path("packageId") int packageId)`](../lib/medicard_network/service/medicard_network_api_service.dart#L48) — يجلب `get package details` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<AllPackagesResponse> getAllPackages({@Query("pageNumber") int? pageNumber, @Query("pageSize") int? pageSize, @Query("Search") String? search})`](../lib/medicard_network/service/medicard_network_api_service.dart#L53) — يجلب `get all packages` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ProviderCategoriesResponse> getProviderCategories(@Query("providerId") int providerId)`](../lib/medicard_network/service/medicard_network_api_service.dart#L60) — يجلب `get provider categories` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.
- [`Future<ServicesByCategoryResponse> getServicesByCategory(@Query("categoryId") int categoryId, @Query("providerId") int providerId, {@Query("pageNumber") int? pageNumber, @Query("pageSize") int? pageSize})`](../lib/medicard_network/service/medicard_network_api_service.dart#L65) — يجلب `get services by category` من مصدر البيانات المناسب داخل `MedicardNetworkApiService`.


## Module: network

### `network/data/all_packages_models.dart`

- [`class AllPackagesResponse`](../lib/network/data/all_packages_models.dart#L1) — الكلاس الذي يمثل بيانات `all packages response` وينقلها بين الطبقات.
- [`const AllPackagesResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/all_packages_models.dart#L9) — ينشئ كائنًا من `AllPackagesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AllPackagesResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/all_packages_models.dart#L17) — ينشئ كائنًا من `AllPackagesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class AllPackagesData`](../lib/network/data/all_packages_models.dart#L34) — الكلاس الذي يمثل بيانات `all packages data` وينقلها بين الطبقات.
- [`const AllPackagesData({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/network/data/all_packages_models.dart#L41) — ينشئ كائنًا من `AllPackagesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AllPackagesData.fromJson(Map<String, dynamic> json)`](../lib/network/data/all_packages_models.dart#L49) — ينشئ كائنًا من `AllPackagesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class AllPackage`](../lib/network/data/all_packages_models.dart#L62) — الكلاس الذي يمثل بيانات `all package` وينقلها بين الطبقات.
- [`const AllPackage({this.id, this.name, this.providerId, this.providerNameAr, this.providerNameEn, this.description, this.image, this.priceBefore, this.priceAfter, this.discountPercentage, this.serviceNames})`](../lib/network/data/all_packages_models.dart#L75) — ينشئ كائنًا من `AllPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory AllPackage.fromJson(Map<String, dynamic> json)`](../lib/network/data/all_packages_models.dart#L89) — ينشئ كائنًا من `AllPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`double? asDouble(Object? value)`](../lib/network/data/all_packages_models.dart#L90) — ينفّذ منطق `as double` داخل `AllPackage`.
- [`String providerName(bool isArabic)`](../lib/network/data/all_packages_models.dart#L108) — ينفّذ منطق `provider name` داخل `AllPackage`.

### `network/data/provider_categories_models.dart`

- [`class ProviderCategoriesResponse`](../lib/network/data/provider_categories_models.dart#L3) — الكلاس الذي يمثل بيانات `provider categories response` وينقلها بين الطبقات.
- [`const ProviderCategoriesResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_categories_models.dart#L12) — ينشئ كائنًا من `ProviderCategoriesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderCategoriesResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_categories_models.dart#L20) — ينشئ كائنًا من `ProviderCategoriesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class ProviderCategory`](../lib/network/data/provider_categories_models.dart#L36) — الكلاس الذي يمثل بيانات `provider category` وينقلها بين الطبقات.
- [`const ProviderCategory({this.imageUrl, this.id, this.name})`](../lib/network/data/provider_categories_models.dart#L41) — ينشئ كائنًا من `ProviderCategory` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderCategory.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_categories_models.dart#L43) — ينشئ كائنًا من `ProviderCategory` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class ServicesByCategoryResponse`](../lib/network/data/provider_categories_models.dart#L52) — الكلاس الذي يمثل بيانات `services by category response` وينقلها بين الطبقات.
- [`const ServicesByCategoryResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_categories_models.dart#L61) — ينشئ كائنًا من `ServicesByCategoryResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ServicesByCategoryResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_categories_models.dart#L69) — ينشئ كائنًا من `ServicesByCategoryResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class ServicesByCategoryData`](../lib/network/data/provider_categories_models.dart#L86) — الكلاس الذي يمثل بيانات `services by category data` وينقلها بين الطبقات.
- [`const ServicesByCategoryData({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/network/data/provider_categories_models.dart#L93) — ينشئ كائنًا من `ServicesByCategoryData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ServicesByCategoryData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_categories_models.dart#L101) — ينشئ كائنًا من `ServicesByCategoryData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`class ProviderCategoryService`](../lib/network/data/provider_categories_models.dart#L116) — الكلاس الذي يمثل بيانات `provider category service` وينقلها بين الطبقات.
- [`const ProviderCategoryService({this.id, this.serviceName, this.serviceNameAr, this.serviceNameEn, this.instruction, this.priceBefore, this.discountPercentage, this.priceAfter, this.isSpecialOffer})`](../lib/network/data/provider_categories_models.dart#L127) — ينشئ كائنًا من `ProviderCategoryService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderCategoryService.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_categories_models.dart#L139) — ينشئ كائنًا من `ProviderCategoryService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`double? asDouble(Object? value)`](../lib/network/data/provider_categories_models.dart#L140) — ينفّذ منطق `as double` داخل `ProviderCategoryService`.
- [`String displayName(bool isArabic)`](../lib/network/data/provider_categories_models.dart#L155) — ينفّذ منطق `display name` داخل `ProviderCategoryService`.
- [`ProviderService toProviderService({required int categoryId, required bool isArabic, bool? isSelected})`](../lib/network/data/provider_categories_models.dart#L165) — يحوّل `to provider service` بين طبقات أو صيغ البيانات داخل `ProviderCategoryService`.

### `network/data/provider_page_response_model.dart`

- [`class ProviderPageResponse`](../lib/network/data/provider_page_response_model.dart#L7) — الكلاس الذي يمثل بيانات `provider page response` وينقلها بين الطبقات.
- [`ProviderPageResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_page_response_model.dart#L15) — ينشئ كائنًا من `ProviderPageResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderPageResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L23) — ينشئ كائنًا من `ProviderPageResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L26) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderBranchesResponse`](../lib/network/data/provider_page_response_model.dart#L29) — الكلاس الذي يمثل بيانات `provider branches response` وينقلها بين الطبقات.
- [`ProviderBranchesResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_page_response_model.dart#L37) — ينشئ كائنًا من `ProviderBranchesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderBranchesResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L45) — ينشئ كائنًا من `ProviderBranchesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L48) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderPageData`](../lib/network/data/provider_page_response_model.dart#L51) — الكلاس الذي يمثل بيانات `provider page data` وينقلها بين الطبقات.
- [`ProviderPageData({required this.id, required this.name, required this.categoryName, this.categoryId, required this.imageUrl, this.hotLine, this.phoneNumber1, this.phoneNumber2, this.totalServices, this.averageRating, this.totalReviews, this.branches, this.services, this.pageNumber, this.pageSize, this.totalPages})`](../lib/network/data/provider_page_response_model.dart#L70) — ينشئ كائنًا من `ProviderPageData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderPageData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L89) — ينشئ كائنًا من `ProviderPageData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L92) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`String get providerName`](../lib/network/data/provider_page_response_model.dart#L95) — ينفّذ منطق `provider name` داخل `ProviderPageData`.
- [`String get providerLogo`](../lib/network/data/provider_page_response_model.dart#L96) — ينفّذ منطق `provider logo` داخل `ProviderPageData`.
- [`int get providerId`](../lib/network/data/provider_page_response_model.dart#L97) — ينفّذ منطق `provider id` داخل `ProviderPageData`.
- [`double? get rating`](../lib/network/data/provider_page_response_model.dart#L98) — ينفّذ منطق `rating` داخل `ProviderPageData`.
- [`int? get reviewsCount`](../lib/network/data/provider_page_response_model.dart#L99) — ينفّذ منطق `reviews count` داخل `ProviderPageData`.
- [`List<String>? get phones`](../lib/network/data/provider_page_response_model.dart#L100) — ينفّذ منطق `phones` داخل `ProviderPageData`.
- [`int? get servicesCount`](../lib/network/data/provider_page_response_model.dart#L112) — ينفّذ منطق `services count` داخل `ProviderPageData`.
- [`class ProviderBranch`](../lib/network/data/provider_page_response_model.dart#L115) — الكلاس الذي يمثل بيانات `provider branch` وينقلها بين الطبقات.
- [`ProviderBranch({required this.branchId, required this.branchName, this.phoneNumber1, this.phoneNumber2, this.fullAddress, this.mapUrl, this.latitude, this.longitude, this.distanceKm})`](../lib/network/data/provider_page_response_model.dart#L127) — ينشئ كائنًا من `ProviderBranch` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderBranch.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L139) — ينشئ كائنًا من `ProviderBranch` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L142) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`String? get phone`](../lib/network/data/provider_page_response_model.dart#L145) — ينفّذ منطق `phone` داخل `ProviderBranch`.
- [`String? get mapsUrl`](../lib/network/data/provider_page_response_model.dart#L146) — يحوّل `maps url` بين طبقات أو صيغ البيانات داخل `ProviderBranch`.
- [`class ProviderReviewsResponse`](../lib/network/data/provider_page_response_model.dart#L149) — الكلاس الذي يمثل بيانات `provider reviews response` وينقلها بين الطبقات.
- [`ProviderReviewsResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_page_response_model.dart#L157) — ينشئ كائنًا من `ProviderReviewsResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderReviewsResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L165) — ينشئ كائنًا من `ProviderReviewsResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L168) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderReviewsData`](../lib/network/data/provider_page_response_model.dart#L171) — الكلاس الذي يمثل بيانات `provider reviews data` وينقلها بين الطبقات.
- [`ProviderReviewsData({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/network/data/provider_page_response_model.dart#L179) — ينشئ كائنًا من `ProviderReviewsData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderReviewsData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L187) — ينشئ كائنًا من `ProviderReviewsData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L190) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderReview`](../lib/network/data/provider_page_response_model.dart#L193) — الكلاس الذي يمثل بيانات `provider review` وينقلها بين الطبقات.
- [`ProviderReview({this.userName, this.userImageUrl, this.rating, this.ratingText, this.createdAt})`](../lib/network/data/provider_page_response_model.dart#L201) — ينشئ كائنًا من `ProviderReview` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderReview.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L209) — ينشئ كائنًا من `ProviderReview` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L212) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderPackagesResponse`](../lib/network/data/provider_page_response_model.dart#L215) — الكلاس الذي يمثل بيانات `provider packages response` وينقلها بين الطبقات.
- [`ProviderPackagesResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_page_response_model.dart#L223) — ينشئ كائنًا من `ProviderPackagesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderPackagesResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L231) — ينشئ كائنًا من `ProviderPackagesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L234) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderPackagesData`](../lib/network/data/provider_page_response_model.dart#L237) — الكلاس الذي يمثل بيانات `provider packages data` وينقلها بين الطبقات.
- [`ProviderPackagesData({this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/network/data/provider_page_response_model.dart#L245) — ينشئ كائنًا من `ProviderPackagesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderPackagesData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L253) — ينشئ كائنًا من `ProviderPackagesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L256) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderPackage`](../lib/network/data/provider_page_response_model.dart#L259) — الكلاس الذي يمثل بيانات `provider package` وينقلها بين الطبقات.
- [`ProviderPackage({this.id, this.name, this.imageUrl, this.description, this.priceBefore, this.priceAfter, this.discountPercentage, this.servicesCount})`](../lib/network/data/provider_page_response_model.dart#L270) — ينشئ كائنًا من `ProviderPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderPackage.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L281) — ينشئ كائنًا من `ProviderPackage` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L284) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class PackageDetailsResponse`](../lib/network/data/provider_page_response_model.dart#L287) — الكلاس الذي يمثل بيانات `package details response` وينقلها بين الطبقات.
- [`PackageDetailsResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_page_response_model.dart#L295) — ينشئ كائنًا من `PackageDetailsResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory PackageDetailsResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L303) — ينشئ كائنًا من `PackageDetailsResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L306) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class PackageDetailsData`](../lib/network/data/provider_page_response_model.dart#L309) — الكلاس الذي يمثل بيانات `package details data` وينقلها بين الطبقات.
- [`PackageDetailsData({this.id, this.name, this.description, this.image, this.priceBefore, this.priceAfter, this.discountPercentage, this.serviceNames, this.providerId})`](../lib/network/data/provider_page_response_model.dart#L324) — ينشئ كائنًا من `PackageDetailsData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory PackageDetailsData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_page_response_model.dart#L336) — ينشئ كائنًا من `PackageDetailsData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_page_response_model.dart#L339) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.

### `network/data/provider_services_response_model.dart`

- [`class ProviderServicesResponse`](../lib/network/data/provider_services_response_model.dart#L5) — الكلاس الذي يمثل بيانات `provider services response` وينقلها بين الطبقات.
- [`ProviderServicesResponse({this.httpStatusCode, this.errors, this.succeeded, this.message, this.data})`](../lib/network/data/provider_services_response_model.dart#L13) — ينشئ كائنًا من `ProviderServicesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderServicesResponse.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_services_response_model.dart#L21) — ينشئ كائنًا من `ProviderServicesResponse` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_services_response_model.dart#L24) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderServicesData`](../lib/network/data/provider_services_response_model.dart#L27) — الكلاس الذي يمثل بيانات `provider services data` وينقلها بين الطبقات.
- [`ProviderServicesData({this.groups, this.items, this.pageNumber, this.pageSize, this.totalCount, this.totalPages})`](../lib/network/data/provider_services_response_model.dart#L36) — ينشئ كائنًا من `ProviderServicesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderServicesData.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_services_response_model.dart#L45) — ينشئ كائنًا من `ProviderServicesData` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_services_response_model.dart#L48) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`List<ProviderService>? get services`](../lib/network/data/provider_services_response_model.dart#L51) — ينفّذ منطق `services` داخل `ProviderServicesData`.
- [`Pagination? get pagination`](../lib/network/data/provider_services_response_model.dart#L63) — ينفّذ منطق `pagination` داخل `ProviderServicesData`.
- [`class ProviderServicesGroup`](../lib/network/data/provider_services_response_model.dart#L81) — الكلاس الذي يمثل بيانات `provider services group` وينقلها بين الطبقات.
- [`ProviderServicesGroup({this.categoryId, this.categoryName, this.services})`](../lib/network/data/provider_services_response_model.dart#L87) — ينشئ كائنًا من `ProviderServicesGroup` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderServicesGroup.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_services_response_model.dart#L89) — ينشئ كائنًا من `ProviderServicesGroup` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_services_response_model.dart#L92) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`class ProviderService`](../lib/network/data/provider_services_response_model.dart#L95) — الكلاس الذي يمثل بيانات `provider service` وينقلها بين الطبقات.
- [`ProviderService({this.id, this.serviceName, this.instruction, this.priceBefore, this.priceAfter, this.discountPercentage, this.isSpecialOffer, this.isSelected, this.categoryId})`](../lib/network/data/provider_services_response_model.dart#L107) — ينشئ كائنًا من `ProviderService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`factory ProviderService.fromJson(Map<String, dynamic> json)`](../lib/network/data/provider_services_response_model.dart#L119) — ينشئ كائنًا من `ProviderService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Map<String, dynamic> toJson()`](../lib/network/data/provider_services_response_model.dart#L122) — يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.
- [`bool? get hasSpecialOffer`](../lib/network/data/provider_services_response_model.dart#L125) — يفحص شرط `has special offer` ويعيد النتيجة داخل `ProviderService`.
- [`ProviderService withCategoryId(int? nextCategoryId)`](../lib/network/data/provider_services_response_model.dart#L127) — ينفّذ منطق `with category id` داخل `ProviderService`.
- [`ProviderService copyWith({bool? isSelected})`](../lib/network/data/provider_services_response_model.dart#L139) — ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.
- [`class Pagination`](../lib/network/data/provider_services_response_model.dart#L152) — الكلاس الذي يمثل بيانات `pagination` وينقلها بين الطبقات.
- [`Pagination({required this.currentPage, required this.pageSize, required this.totalCount, required this.totalPages, required this.hasNextPage, required this.hasPreviousPage})`](../lib/network/data/provider_services_response_model.dart#L160) — ينشئ كائنًا من `Pagination` ويهيّئ الاعتماديات والقيم المطلوبة.


## Module: presentation

### `presentation/logic/medicard_login_cubit.dart`

- [`class MedicardLoginCubit`](../lib/presentation/logic/medicard_login_cubit.dart#L18) — الكلاس الذي يجمع مسؤوليات `medicard login cubit`.
- [`MedicardLoginCubit(this._loginCardUseCase)`](../lib/presentation/logic/medicard_login_cubit.dart#L21) — ينشئ كائنًا من `MedicardLoginCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> login({String? cardNumber, String? phoneNumber, required String password})`](../lib/presentation/logic/medicard_login_cubit.dart#L24) — ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة داخل `MedicardLoginCubit`.

### `presentation/logic/medicard_login_state.dart`

- [`class MedicardLoginState`](../lib/presentation/logic/medicard_login_state.dart#L7) — الكلاس الذي يجمع مسؤوليات `medicard login state`.
- [`const factory MedicardLoginState.initial()`](../lib/presentation/logic/medicard_login_state.dart#L9) — ينشئ كائنًا من `MedicardLoginState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory MedicardLoginState.loading()`](../lib/presentation/logic/medicard_login_state.dart#L10) — ينشئ كائنًا من `MedicardLoginState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory MedicardLoginState.success(AuthResponseModel response)`](../lib/presentation/logic/medicard_login_state.dart#L11) — ينشئ كائنًا من `MedicardLoginState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory MedicardLoginState.failed({required String error})`](../lib/presentation/logic/medicard_login_state.dart#L13) — ينشئ كائنًا من `MedicardLoginState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `presentation/logic/register_cubit.dart`

- [`class RegisterCubit`](../lib/presentation/logic/register_cubit.dart#L15) — الكلاس الذي يجمع مسؤوليات `register cubit`.
- [`RegisterCubit(this._registerUseCase)`](../lib/presentation/logic/register_cubit.dart#L18) — ينشئ كائنًا من `RegisterCubit` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<void> register({required String firstName, required String lastName, required String phoneNumber, required bool isMale, required String birthDate, required String password, required String confirmPassword, String? nationalId, String? passportNumber})`](../lib/presentation/logic/register_cubit.dart#L20) — يسجّل `register` لدى النظام أو الخدمة داخل `RegisterCubit`.

### `presentation/logic/register_state.dart`

- [`class RegisterState`](../lib/presentation/logic/register_state.dart#L7) — الكلاس الذي يجمع مسؤوليات `register state`.
- [`const factory RegisterState.initial()`](../lib/presentation/logic/register_state.dart#L9) — ينشئ كائنًا من `RegisterState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory RegisterState.loading()`](../lib/presentation/logic/register_state.dart#L10) — ينشئ كائنًا من `RegisterState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory RegisterState.success(AuthResponseModel response)`](../lib/presentation/logic/register_state.dart#L11) — ينشئ كائنًا من `RegisterState` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`const factory RegisterState.failed({required String error})`](../lib/presentation/logic/register_state.dart#L12) — ينشئ كائنًا من `RegisterState` ويهيّئ الاعتماديات والقيم المطلوبة.

### `presentation/medicard_login_screen.dart`

- [`class MediCardLoginScreen`](../lib/presentation/medicard_login_screen.dart#L17) — الكلاس الذي يجمع مسؤوليات `medi card login screen`.
- [`const MediCardLoginScreen({super.key})`](../lib/presentation/medicard_login_screen.dart#L18) — ينشئ كائنًا من `MediCardLoginScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<MediCardLoginScreen> createState()`](../lib/presentation/medicard_login_screen.dart#L20) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _MediCardLoginScreenState`](../lib/presentation/medicard_login_screen.dart#L24) — **خاص** — الكلاس الذي يجمع مسؤوليات `medi card login screen state`.
- [`void dispose()`](../lib/presentation/medicard_login_screen.dart#L30) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onLoginPressed(BuildContext context)`](../lib/presentation/medicard_login_screen.dart#L37) — **خاص** — يعالج حدث `on login pressed` داخل `_MediCardLoginScreenState`.
- [`String? _validateLoginIdentifier(String? value)`](../lib/presentation/medicard_login_screen.dart#L55) — **خاص** — يتحقق من صحة `validate login identifier` داخل `_MediCardLoginScreenState`.
- [`Widget build(BuildContext context)`](../lib/presentation/medicard_login_screen.dart#L84) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`Widget _buildPhoneField()`](../lib/presentation/medicard_login_screen.dart#L237) — **خاص** — ينفّذ منطق `build phone field` داخل `_MediCardLoginScreenState`.
- [`Widget _buildPasswordField()`](../lib/presentation/medicard_login_screen.dart#L254) — **خاص** — ينفّذ منطق `build password field` داخل `_MediCardLoginScreenState`.
- [`class _LoginIdentifier`](../lib/presentation/medicard_login_screen.dart#L282) — **خاص** — الكلاس الذي يجمع مسؤوليات `login identifier`.
- [`const _LoginIdentifier({this.cardNumber, this.phoneNumber})`](../lib/presentation/medicard_login_screen.dart#L286) — **خاص** — ينشئ كائنًا من `LoginIdentifier` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`_LoginIdentifier _parseLoginIdentifier(String raw)`](../lib/presentation/medicard_login_screen.dart#L289) — **خاص** — يحلّل `parse login identifier` ويحوّله لصيغة قابلة للاستخدام داخل هذا الملف.
- [`bool _isEgyptianMobile(String value)`](../lib/presentation/medicard_login_screen.dart#L297) — **خاص** — يفحص شرط `is egyptian mobile` ويعيد النتيجة داخل هذا الملف.
- [`bool _looksLikePhoneAttempt(String value)`](../lib/presentation/medicard_login_screen.dart#L302) — **خاص** — ينفّذ منطق `looks like phone attempt` داخل هذا الملف.
- [`bool _isPotentialCardNumber(String value)`](../lib/presentation/medicard_login_screen.dart#L310) — **خاص** — يفحص شرط `is potential card number` ويعيد النتيجة داخل هذا الملف.
- [`class _OrDivider`](../lib/presentation/medicard_login_screen.dart#L316) — **خاص** — الكلاس الذي يجمع مسؤوليات `or divider`.
- [`Widget build(BuildContext context)`](../lib/presentation/medicard_login_screen.dart#L317) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ActivateCardButton`](../lib/presentation/medicard_login_screen.dart#L337) — **خاص** — الكلاس الذي يجمع مسؤوليات `activate card button`.
- [`const _ActivateCardButton({required this.onPressed})`](../lib/presentation/medicard_login_screen.dart#L339) — **خاص** — ينشئ كائنًا من `ActivateCardButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/medicard_login_screen.dart#L341) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class _ContinueAsGuestButton`](../lib/presentation/medicard_login_screen.dart#L370) — **خاص** — الكلاس الذي يجمع مسؤوليات `continue as guest button`.
- [`const _ContinueAsGuestButton({required this.onPressed})`](../lib/presentation/medicard_login_screen.dart#L372) — **خاص** — ينشئ كائنًا من `ContinueAsGuestButton` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/medicard_login_screen.dart#L374) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/register_screen.dart`

- [`class RegisterScreen`](../lib/presentation/register_screen.dart#L19) — الكلاس الذي يجمع مسؤوليات `register screen`.
- [`const RegisterScreen({super.key})`](../lib/presentation/register_screen.dart#L20) — ينشئ كائنًا من `RegisterScreen` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`State<RegisterScreen> createState()`](../lib/presentation/register_screen.dart#L22) — ينشئ كائن الحالة المرتبط بالـ StatefulWidget.
- [`class _RegisterScreenState`](../lib/presentation/register_screen.dart#L26) — **خاص** — الكلاس الذي يجمع مسؤوليات `register screen state`.
- [`void initState()`](../lib/presentation/register_screen.dart#L48) — **خاص** — يهيّئ حالة الـ widget والاشتراكات عند إنشائها.
- [`void dispose()`](../lib/presentation/register_screen.dart#L72) — **خاص** — يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.
- [`void _onPasswordChanged()`](../lib/presentation/register_screen.dart#L88) — **خاص** — يعالج حدث `on password changed` داخل `_RegisterScreenState`.
- [`String? _validatePassword(String? value)`](../lib/presentation/register_screen.dart#L95) — **خاص** — يتحقق من صحة `validate password` داخل `_RegisterScreenState`.
- [`String? _validateConfirmPassword(String? value)`](../lib/presentation/register_screen.dart#L109) — **خاص** — يتحقق من صحة `validate confirm password` داخل `_RegisterScreenState`.
- [`bool _hasUsableAuthSession(AuthResponseModel response)`](../lib/presentation/register_screen.dart#L126) — **خاص** — يفحص شرط `has usable auth session` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`bool _isPasswordValid(String password)`](../lib/presentation/register_screen.dart#L136) — **خاص** — يفحص شرط `is password valid` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`bool _hasMinimumLength(String password)`](../lib/presentation/register_screen.dart#L143) — **خاص** — يفحص شرط `has minimum length` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`bool _hasLetter(String password)`](../lib/presentation/register_screen.dart#L146) — **خاص** — يفحص شرط `has letter` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`bool _hasNumber(String password)`](../lib/presentation/register_screen.dart#L148) — **خاص** — يفحص شرط `has number` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`bool _hasSpecialCharacter(String password)`](../lib/presentation/register_screen.dart#L150) — **خاص** — يفحص شرط `has special character` ويعيد النتيجة داخل `_RegisterScreenState`.
- [`String? _validateName(String? value, {required String requiredKey})`](../lib/presentation/register_screen.dart#L153) — **خاص** — يتحقق من صحة `validate name` داخل `_RegisterScreenState`.
- [`String? _validatePhoneNumber(String? value)`](../lib/presentation/register_screen.dart#L164) — **خاص** — يتحقق من صحة `validate phone number` داخل `_RegisterScreenState`.
- [`String? _validateNationalId(String? value)`](../lib/presentation/register_screen.dart#L184) — **خاص** — يتحقق من صحة `validate national id` داخل `_RegisterScreenState`.
- [`String? _validatePassportNumber(String? value)`](../lib/presentation/register_screen.dart#L205) — **خاص** — يتحقق من صحة `validate passport number` داخل `_RegisterScreenState`.
- [`void _clearInputFocus()`](../lib/presentation/register_screen.dart#L221) — **خاص** — يحذف أو يمسح `clear input focus` داخل `_RegisterScreenState`.
- [`Future<void> _selectBirthDate()`](../lib/presentation/register_screen.dart#L227) — **خاص** — يغيّر الاختيار الخاص بـ `select birth date` داخل `_RegisterScreenState`.
- [`void _onRegisterPressed(BuildContext context)`](../lib/presentation/register_screen.dart#L251) — **خاص** — يعالج حدث `on register pressed` داخل `_RegisterScreenState`.
- [`Widget build(BuildContext context)`](../lib/presentation/register_screen.dart#L286) — **خاص** — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_account_section.dart`

- [`class RegisterAccountSection`](../lib/presentation/widgets/register/register_account_section.dart#L13) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterAccountSection({super.key, required this.phoneNumberController, required this.phoneNumberFocusNode, required this.phoneNumberAutovalidate, required this.phoneNumberValidator, required this.isMale, required this.onMaleTap, required this.onFemaleTap, required this.birthDate, required this.onSelectBirthDate, required this.passwordController, required this.obscurePassword, required this.onPasswordToggle, required this.passwordFocusNode, required this.passwordAutovalidate, required this.passwordValidator, required this.passwordMinLength, required this.confirmPasswordFieldKey, required this.confirmPasswordController, required this.obscureConfirmPassword, required this.onConfirmPasswordToggle, required this.confirmPasswordFocusNode, required this.confirmPasswordAutovalidate, required this.confirmPasswordValidator})`](../lib/presentation/widgets/register/register_account_section.dart#L40) — ينشئ كائنًا من `RegisterAccountSection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_account_section.dart#L67) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_birth_date_field.dart`

- [`class RegisterBirthDateField`](../lib/presentation/widgets/register/register_birth_date_field.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterBirthDateField({super.key, required this.birthDate, required this.onTap})`](../lib/presentation/widgets/register/register_birth_date_field.dart#L12) — ينشئ كائنًا من `RegisterBirthDateField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_birth_date_field.dart#L18) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_gender_selector.dart`

- [`class RegisterGenderSelector`](../lib/presentation/widgets/register/register_gender_selector.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterGenderSelector({super.key, required this.isMale, required this.onMaleTap, required this.onFemaleTap})`](../lib/presentation/widgets/register/register_gender_selector.dart#L13) — ينشئ كائنًا من `RegisterGenderSelector` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_gender_selector.dart#L20) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_identity_section.dart`

- [`class RegisterIdentitySection`](../lib/presentation/widgets/register/register_identity_section.dart#L10) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterIdentitySection({super.key, required this.nationalIdFieldKey, required this.nationalIdController, required this.nationalIdFocusNode, required this.nationalIdAutovalidate, required this.nationalIdValidator, required this.passportNumberController, required this.passportNumberFocusNode, required this.passportNumberAutovalidate, required this.passportNumberValidator, required this.onPassportChanged})`](../lib/presentation/widgets/register/register_identity_section.dart#L24) — ينشئ كائنًا من `RegisterIdentitySection` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_identity_section.dart#L38) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_name_row.dart`

- [`class RegisterNameRow`](../lib/presentation/widgets/register/register_name_row.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterNameRow({super.key, required this.firstNameController, required this.lastNameController, required this.firstNameFocusNode, required this.lastNameFocusNode, required this.firstNameAutovalidate, required this.lastNameAutovalidate, required this.firstNameValidator, required this.lastNameValidator})`](../lib/presentation/widgets/register/register_name_row.dart#L20) — ينشئ كائنًا من `RegisterNameRow` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_name_row.dart#L32) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_password_field.dart`

- [`class RegisterPasswordField`](../lib/presentation/widgets/register/register_password_field.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterPasswordField({super.key, this.fieldKey, required this.controller, required this.hintText, required this.obscure, required this.onToggle, this.validator, this.focusNode, this.autovalidateMode = AutovalidateMode.disabled})`](../lib/presentation/widgets/register/register_password_field.dart#L18) — ينشئ كائنًا من `RegisterPasswordField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_password_field.dart#L30) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_password_requirements.dart`

- [`class RegisterPasswordRequirements`](../lib/presentation/widgets/register/register_password_requirements.dart#L9) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterPasswordRequirements({super.key, required this.password, required this.minLength})`](../lib/presentation/widgets/register/register_password_requirements.dart#L14) — ينشئ كائنًا من `RegisterPasswordRequirements` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_password_requirements.dart#L20) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.
- [`class RegisterPasswordRequirement`](../lib/presentation/widgets/register/register_password_requirements.dart#L67) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterPasswordRequirement({super.key, required this.label, required this.isMet, required this.showInvalid})`](../lib/presentation/widgets/register/register_password_requirements.dart#L72) — ينشئ كائنًا من `RegisterPasswordRequirement` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_password_requirements.dart#L79) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_required_hint.dart`

- [`class RegisterRequiredHint`](../lib/presentation/widgets/register/register_required_hint.dart#L7) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterRequiredHint(this.text, {super.key})`](../lib/presentation/widgets/register/register_required_hint.dart#L11) — ينشئ كائنًا من `RegisterRequiredHint` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_required_hint.dart#L13) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.

### `presentation/widgets/register/register_text_field.dart`

- [`class RegisterTextField`](../lib/presentation/widgets/register/register_text_field.dart#L8) — الكلاس الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.
- [`const RegisterTextField({super.key, this.fieldKey, required this.controller, required this.hintText, this.keyboardType, this.required = true, this.validator, this.onChanged, this.inputFormatters, this.focusNode, this.autovalidateMode = AutovalidateMode.disabled})`](../lib/presentation/widgets/register/register_text_field.dart#L22) — ينشئ كائنًا من `RegisterTextField` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Widget build(BuildContext context)`](../lib/presentation/widgets/register/register_text_field.dart#L36) — يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.


## Module: repository

### `repository/medicard_repository_impl.dart`

- [`class MedicardRepositoryImpl`](../lib/repository/medicard_repository_impl.dart#L39) — الكلاس المسؤول عن عقد أو تنفيذ الوصول إلى بيانات `medicard repository impl`.
- [`MedicardRepositoryImpl(this._apiService)`](../lib/repository/medicard_repository_impl.dart#L42) — ينشئ كائنًا من `MedicardRepositoryImpl` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`String _formatApiMessages(dynamic value)`](../lib/repository/medicard_repository_impl.dart#L44) — **خاص** — ينسّق `format api messages` للعرض أو الإرسال داخل `MedicardRepositoryImpl`.
- [`String _friendlyChangePasswordMessage(String message)`](../lib/repository/medicard_repository_impl.dart#L62) — **خاص** — ينفّذ منطق `friendly change password message` داخل `MedicardRepositoryImpl`.
- [`bool _isRegisterSuccess(AuthResponseModel response)`](../lib/repository/medicard_repository_impl.dart#L73) — **خاص** — يفحص شرط `is register success` ويعيد النتيجة داخل `MedicardRepositoryImpl`.
- [`bool _isLoginSuccess(AuthResponseModel response)`](../lib/repository/medicard_repository_impl.dart#L84) — **خاص** — يفحص شرط `is login success` ويعيد النتيجة داخل `MedicardRepositoryImpl`.
- [`String _authFailureMessage(AuthResponseModel response)`](../lib/repository/medicard_repository_impl.dart#L95) — **خاص** — ينفّذ منطق `auth failure message` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<AuthResponseModel>> register(AuthRegisterRequestModel request)`](../lib/repository/medicard_repository_impl.dart#L111) — يسجّل `register` لدى النظام أو الخدمة داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<AuthResponseModel>> login(AuthLoginRequestModel request)`](../lib/repository/medicard_repository_impl.dart#L126) — ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة داخل `MedicardRepositoryImpl`.
- [`String _otpFailureMessage(OtpResponseModel response)`](../lib/repository/medicard_repository_impl.dart#L141) — **خاص** — ينفّذ منطق `otp failure message` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<OtpResponseModel>> sendOtp(String phoneNumber)`](../lib/repository/medicard_repository_impl.dart#L149) — يرسل `send otp` إلى الطبقة أو الخدمة المطلوبة داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<OtpResponseModel>> verifyOtp({required String phoneNumber, required String otp})`](../lib/repository/medicard_repository_impl.dart#L164) — ينفّذ منطق `verify otp` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<OtpResponseModel>> resetPassword({required String phoneNumber, required String password, required String confirmPassword})`](../lib/repository/medicard_repository_impl.dart#L182) — ينفّذ منطق `reset password` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<CardHomeInfoResponseModel>> getHomeInfo(String cardNo, String lang)`](../lib/repository/medicard_repository_impl.dart#L205) — يجلب `get home info` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<CardPersonalInfoResponseModel>> getPersonalInfo(String cardNo, String lang)`](../lib/repository/medicard_repository_impl.dart#L225) — يجلب `get personal info` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<CardSupportContactResponseModel>> getSupportContacts(String lang)`](../lib/repository/medicard_repository_impl.dart#L245) — يجلب `get support contacts` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<CardUpdateProfileResponseModel>> updateProfile(CardUpdateProfileRequestModel request, String lang)`](../lib/repository/medicard_repository_impl.dart#L274) — يحدّث `update profile` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<HomeResponseModel>> getHomeData({double? latitude, double? longitude})`](../lib/repository/medicard_repository_impl.dart#L323) — يجلب `get home data` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ProfileResponseModel>> getProfile()`](../lib/repository/medicard_repository_impl.dart#L361) — يجلب `get profile` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ProfileSummaryResponseModel>> getProfileSummary()`](../lib/repository/medicard_repository_impl.dart#L389) — يجلب `get profile summary` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ProfileResponseModel>> deleteProfileImage()`](../lib/repository/medicard_repository_impl.dart#L415) — يحذف أو يمسح `delete profile image` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<MemberCardActivationResponseModel>> activateMemberCard({required String cardNumber})`](../lib/repository/medicard_repository_impl.dart#L444) — ينفّذ منطق `activate member card` داخل `MedicardRepositoryImpl`.
- [`String _memberCardActivationBackendMessage(MemberCardActivationResponseModel response)`](../lib/repository/medicard_repository_impl.dart#L472) — **خاص** — ينفّذ منطق `member card activation backend message` داخل `MedicardRepositoryImpl`.
- [`String _backendMessageFromDio(Object error)`](../lib/repository/medicard_repository_impl.dart#L484) — **خاص** — ينفّذ منطق `backend message from dio` داخل `MedicardRepositoryImpl`.
- [`String _extractBackendMessages(dynamic value)`](../lib/repository/medicard_repository_impl.dart#L492) — **خاص** — ينفّذ منطق `extract backend messages` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<CardDataResponseModel>> getCardData()`](../lib/repository/medicard_repository_impl.dart#L528) — يجلب `get card data` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ProfileResponseModel>> updateProfileV2({required String firstName, required String lastName, required String phoneNumber, required String nationalId, String? passportNumber, required bool isMale, required String birthDate, String? imagePath, bool removeImage = false, String? currentImageUrl})`](../lib/repository/medicard_repository_impl.dart#L566) — يحدّث `update profile v2` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ChangePasswordResponseModel>> changePassword({required String currentPassword, required String newPassword, required String confirmNewPassword})`](../lib/repository/medicard_repository_impl.dart#L657) — يحدّث `change password` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<ChangeLanguageResponseModel>> changeLanguage({required String language})`](../lib/repository/medicard_repository_impl.dart#L694) — يحدّث `change language` داخل `MedicardRepositoryImpl`.
- [`Future<ApiResult<GuestHomeResponseModel>> getGuestHomeData({double? latitude, double? longitude})`](../lib/repository/medicard_repository_impl.dart#L721) — يجلب `get guest home data` من مصدر البيانات المناسب داخل `MedicardRepositoryImpl`.


## Module: service

### `service/medicard_api_service.dart`

- [`class MedicardApiService`](../lib/service/medicard_api_service.dart#L31) — الكلاس الذي يقدّم خدمة `medicard api service` لباقي التطبيق.
- [`factory MedicardApiService(Dio dio, {String baseUrl})`](../lib/service/medicard_api_service.dart#L33) — ينشئ كائنًا من `MedicardApiService` ويهيّئ الاعتماديات والقيم المطلوبة.
- [`Future<AuthResponseModel> register(@Body() AuthRegisterRequestModel request)`](../lib/service/medicard_api_service.dart#L35) — يسجّل `register` لدى النظام أو الخدمة داخل `MedicardApiService`.
- [`Future<AuthResponseModel> login(@Body() AuthLoginRequestModel request)`](../lib/service/medicard_api_service.dart#L38) — ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة داخل `MedicardApiService`.
- [`Future<OtpResponseModel> sendOtp(@Body() SendOtpRequestModel request)`](../lib/service/medicard_api_service.dart#L41) — يرسل `send otp` إلى الطبقة أو الخدمة المطلوبة داخل `MedicardApiService`.
- [`Future<OtpResponseModel> verifyOtp(@Body() VerifyOtpRequestModel request)`](../lib/service/medicard_api_service.dart#L44) — ينفّذ منطق `verify otp` داخل `MedicardApiService`.
- [`Future<OtpResponseModel> resetPassword(@Body() ResetPasswordRequestModel request)`](../lib/service/medicard_api_service.dart#L47) — ينفّذ منطق `reset password` داخل `MedicardApiService`.
- [`Future<CardHomeInfoResponseModel> getHomeInfo(@Path("lang") String lang, @Query("CardNo") String cardNo)`](../lib/service/medicard_api_service.dart#L52) — يجلب `get home info` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<CardPersonalInfoResponseModel> getPersonalInfo(@Path("lang") String lang, @Query("CardNo") String cardNo)`](../lib/service/medicard_api_service.dart#L58) — يجلب `get personal info` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<CardSupportContactResponseModel> getSupportContacts(@Path("lang") String lang)`](../lib/service/medicard_api_service.dart#L64) — يجلب `get support contacts` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<HomeResponseModel> getHomeData(@Query("latitude") double? latitude, @Query("longitude") double? longitude)`](../lib/service/medicard_api_service.dart#L69) — يجلب `get home data` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<CardUpdateProfileResponseModel> updateProfile(@Path("lang") String lang, @Part(name: "CardNo") String cardNo, @Part(name: "FirstName") String? firstName, @Part(name: "LastName") String? lastName, @Part(name: "PhoneNumber") String? phoneNumber, @Part(name: "Email") String? email, @Part(name: "NationalId") String? nationalId, @Part(name: "PassportNumber") String? passportNumber, @Part(name: "Birthdate") String? birthdate, @Part(name: "IsMale") bool? isMale, @Part(name: "ProfileImage") MultipartFile? profileImage)`](../lib/service/medicard_api_service.dart#L75) — يحدّث `update profile` داخل `MedicardApiService`.
- [`Future<ProfileResponseModel> getProfile()`](../lib/service/medicard_api_service.dart#L93) — يجلب `get profile` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<ProfileSummaryResponseModel> getProfileSummary()`](../lib/service/medicard_api_service.dart#L96) — يجلب `get profile summary` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<CardDataResponseModel> getCardData()`](../lib/service/medicard_api_service.dart#L99) — يجلب `get card data` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<ProfileResponseModel> deleteProfileImage()`](../lib/service/medicard_api_service.dart#L102) — يحذف أو يمسح `delete profile image` داخل `MedicardApiService`.
- [`Future<MemberCardActivationResponseModel> activateMemberCard(@Body() Map<String, dynamic> body)`](../lib/service/medicard_api_service.dart#L105) — ينفّذ منطق `activate member card` داخل `MedicardApiService`.
- [`Future<ProfileResponseModel> updateProfileV2(@Part(name: 'FirstName') String firstName, @Part(name: 'LastName') String lastName, @Part(name: 'PhoneNumber') String phoneNumber, @Part(name: 'NationalId') String nationalId, @Part(name: 'PassportNumber') String? passportNumber, @Part(name: 'IsMale') bool isMale, @Part(name: 'BirthDate') String birthDate, @Part(name: 'Image') MultipartFile? image)`](../lib/service/medicard_api_service.dart#L110) — يحدّث `update profile v2` داخل `MedicardApiService`.
- [`Future<ChangePasswordResponseModel> changePassword(@Header('Authorization') String token, @Body() Map<String, dynamic> body)`](../lib/service/medicard_api_service.dart#L125) — يحدّث `change password` داخل `MedicardApiService`.
- [`Future<ChangeLanguageResponseModel> changeLanguage(@Header('Authorization') String token, @Body() ChangeLanguageRequestModel body)`](../lib/service/medicard_api_service.dart#L131) — يحدّث `change language` داخل `MedicardApiService`.
- [`Future<ContentResponseModel> getContent(@Path('slug') String slug)`](../lib/service/medicard_api_service.dart#L139) — يجلب `get content` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<GetFamilyMembersResponseModel> getFamilyMembers()`](../lib/service/medicard_api_service.dart#L144) — يجلب `get family members` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<GetFamilyMemberResponseModel> getFamilyMember(@Path('id') int id)`](../lib/service/medicard_api_service.dart#L147) — يجلب `get family member` من مصدر البيانات المناسب داخل `MedicardApiService`.
- [`Future<FamilyMemberOperationResponseModel> createFamilyMember(@Body() CreateFamilyMemberRequestModel request)`](../lib/service/medicard_api_service.dart#L152) — ينشئ أو يضيف `create family member` داخل `MedicardApiService`.
- [`Future<FamilyMemberOperationResponseModel> updateFamilyMember(@Path('id') int id, @Body() CreateFamilyMemberRequestModel request)`](../lib/service/medicard_api_service.dart#L157) — يحدّث `update family member` داخل `MedicardApiService`.
- [`Future<FamilyMemberOperationResponseModel> deleteFamilyMember(@Path('id') int id)`](../lib/service/medicard_api_service.dart#L163) — يحذف أو يمسح `delete family member` داخل `MedicardApiService`.
- [`Future<GuestHomeResponseModel> getGuestHomeData(@Query('latitude') double? latitude, @Query('longitude') double? longitude)`](../lib/service/medicard_api_service.dart#L170) — يجلب `get guest home data` من مصدر البيانات المناسب داخل `MedicardApiService`.

