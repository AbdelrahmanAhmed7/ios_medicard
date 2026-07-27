import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/cubit/app_refresh_cubit.dart';
import 'core/cubit/localization_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/dio_factory.dart';
import 'core/routing/app_router.dart';
import 'core/services/app_language_manager.dart';
import 'core/theming/font_manager.dart';
import 'features/notifications/push_notification_service.dart';
import 'firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  if (_shouldInitializeFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (kDebugMode) {
    debugPrint('[Startup] Firebase disabled for iOS debug run.');
  }
  await AppLanguageManager.instance.initialize();
  await setupServiceLocator();

  // Session refresh can involve a network request. Never let it block the
  // first Flutter frame indefinitely.
  final initialLocation = await AppRouter.getInitialLocation().timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      if (kDebugMode) {
        debugPrint('[Startup] Initial route timed out; opening guest home.');
      }
      return '/guest-home';
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
  widgetsBinding.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    unawaited(_initializeNonBlockingServices());
  });
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
  // Firebase iOS SwiftPM/GoogleDataTransport is crashing on the simulator in
  // this Flutter/Xcode setup. Keep it enabled for release builds and non-iOS
  // targets while allowing local iOS UI development to start normally.
  if (!kReleaseMode && Platform.isIOS) return false;
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
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            title: 'MediCard',
            theme: ThemeData(
              fontFamily: FontManager.getFontFamily(context),
              useMaterial3: true,
            ),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            builder: (context, child) {
              return child!;
            },
          ),
        ),
      ),
    );
  }
}
