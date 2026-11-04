import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:video_player/video_player.dart';

import 'core/cubit/app_refresh_cubit.dart';
import 'core/cubit/localization_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/dio_factory.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_language_manager.dart';
import 'core/theming/app_colors.dart';
import 'core/theming/app_text_styles.dart';
import 'core/theming/font_manager.dart';
import 'features/notifications/push_notification_service.dart';
import 'features/cart/presentation/widgets/floating_cart_button.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureHighRefreshRate();

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    initializeDateFormatting('ar'),
    initializeDateFormatting('en'),
    if (_shouldInitializeFirebase)
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
  ]);

  if (!_shouldInitializeFirebase && kDebugMode) {
    debugPrint('[Startup] Firebase disabled for iOS debug run.');
  }

  await setupServiceLocator();

  // Session refresh can involve a network request. Never let it block the
  // first Flutter frame indefinitely.
  var safeTimeoutFallback = '/guest-home';
  final initialLocation =
      await AppRouter.getInitialLocation(
        onSafeTimeoutFallback: (location) {
          safeTimeoutFallback = location;
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint(
              '[Startup] Initial route timed out; opening $safeTimeoutFallback.',
            );
          }
          return safeTimeoutFallback;
        },
      );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(sl<AppLanguageManager>().currentLanguage),
      useOnlyLangCode: true,
      child: MyApp(initialLocation: initialLocation),
    ),
  );

  // Remove the native splash only after Flutter has rendered successfully.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeNonBlockingServices());
  });
}

/// Requests the highest supported Android refresh rate without making display
/// configuration a startup requirement. iOS ProMotion is enabled through
/// CADisableMinimumFrameDurationOnPhone in Runner/Info.plist.
Future<void> _configureHighRefreshRate() async {
  if (!Platform.isAndroid) return;
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[Startup] High refresh rate setup skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

Future<void> _initializeNonBlockingServices() async {
  try {
    await ConnectivityService.instance.initialize();
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[Startup] Connectivity initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  try {
    if (Firebase.apps.isNotEmpty) {
      await PushNotificationService.instance.initialize();
    }
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[Startup] Push notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

bool get _shouldInitializeFirebase {
  // Previously disabled for iOS debug due to a Firebase iOS
  // SwiftPM/GoogleDataTransport simulator crash in an older Flutter/Xcode
  // setup. Re-enabled: the sibling app issues FCM tokens fine on the same
  // simulator, so this needs re-verification, not a blanket ban.
  // If the old crash reproduces, gate this behind a dart-define instead.
  return true;
}

class MyApp extends StatefulWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  var _showSplash = true;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AppRefreshCubit>()),
        BlocProvider.value(value: sl<LocalizationCubit>()),
      ],
      child: BlocListener<AppRefreshCubit, AppRefreshState>(
        bloc: sl<AppRefreshCubit>(),
        listener: (context, state) {
          state.maybeWhen(
            sessionExpired: () {
              // Clear the singleton Dio header so no stale token is sent.
              DioFactory.clearTokenFromHeader();
              // Navigate to login from anywhere in the app.
              _router.go('/medicard-login');
            },
            orElse: () {},
          );
        },
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: Stack(
            textDirection: ui.TextDirection.ltr,
            children: [
              MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: _router,
                title: 'MediCard',
                theme: ThemeData(
                  fontFamily: FontManager.getFontFamily(context),
                  useMaterial3: true,
                  textTheme: TextTheme(
                    displayLarge: AppTextStyles.of(
                      fontSize: AppFontSizes.s48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackClr,
                    ),
                    displayMedium: AppTextStyles.of(
                      fontSize: AppFontSizes.s24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackClr,
                    ),
                    displaySmall: AppTextStyles.of(
                      fontSize: AppFontSizes.s22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackClr,
                    ),
                    headlineMedium: AppTextStyles.of(
                      fontSize: AppFontSizes.s20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackClr,
                    ),
                    headlineSmall: AppTextStyles.of(
                      fontSize: AppFontSizes.s18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackClr,
                    ),
                    titleLarge: AppTextStyles.of(
                      fontSize: AppFontSizes.s16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackClr,
                    ),
                    titleMedium: AppTextStyles.of(
                      fontSize: AppFontSizes.s14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackClr,
                    ),
                    titleSmall: AppTextStyles.of(
                      fontSize: AppFontSizes.s12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackClr,
                    ),
                    bodyLarge: AppTextStyles.of(
                      fontSize: AppFontSizes.s15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackClr,
                    ),
                    bodyMedium: AppTextStyles.of(
                      fontSize: AppFontSizes.s14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackClr,
                    ),
                    bodySmall: AppTextStyles.of(
                      fontSize: AppFontSizes.s12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyClr,
                    ),
                    labelLarge: AppTextStyles.of(
                      fontSize: AppFontSizes.s14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryClr,
                    ),
                    labelMedium: AppTextStyles.of(
                      fontSize: AppFontSizes.s12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryClr,
                    ),
                    labelSmall: AppTextStyles.of(
                      fontSize: AppFontSizes.s10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyClr,
                    ),
                  ),
                ),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                builder: (context, child) {
                  return Stack(
                    children: [
                      child!,
                      const FloatingCartButton(),
                    ],
                  );
                },
              ),
              if (_showSplash)
                AppVideoSplash(
                  onFinished: () {
                    if (!mounted) return;
                    setState(() => _showSplash = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppVideoSplash extends StatefulWidget {
  final VoidCallback onFinished;

  const AppVideoSplash({super.key, required this.onFinished});

  @override
  State<AppVideoSplash> createState() => _AppVideoSplashState();
}

class _AppVideoSplashState extends State<AppVideoSplash> {
  static const _assetPath =
      'assets/splash/animate_logo_on_white_background_3sec.mp4';

  late final VideoPlayerController _controller;
  Timer? _fallbackTimer;
  var _isReady = false;
  var _didFinish = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_assetPath)
      ..setLooping(false)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _isReady = true);
            _controller
              ..addListener(_handleVideoProgress)
              ..play();
          })
          .catchError((error, stackTrace) {
            if (kDebugMode) {
              debugPrint('[Startup] Splash video failed: $error');
              debugPrintStack(stackTrace: stackTrace);
            }
            _finish();
          });

    _fallbackTimer = Timer(const Duration(seconds: 4), _finish);
  }

  void _handleVideoProgress() {
    final value = _controller.value;
    if (!value.isInitialized || value.isPlaying) return;

    final duration = value.duration;
    final position = value.position;
    if (duration != Duration.zero &&
        position >= duration - const Duration(milliseconds: 120)) {
      _finish();
    }
  }

  void _finish() {
    if (_didFinish) return;
    _didFinish = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeListener(_handleVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SizedBox.expand(
        child: _isReady
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
