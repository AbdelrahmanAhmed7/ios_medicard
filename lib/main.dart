import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/cubit/app_refresh_cubit.dart';
import 'core/cubit/localization_cubit.dart';
import 'core/di/service_locator.dart';
import 'core/network/dio_factory.dart';
import 'core/services/app_language_manager.dart';
import 'core/network/connectivity_service.dart';
import 'core/routing/app_router.dart';
import 'core/theming/font_manager.dart';
import 'firebase_options.dart';
import 'features/notifications/push_notification_service.dart';

void main() async {
  // Preserve native splash until we explicitly remove it
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Step 1: Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Step 2: Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Step 3: Initialize Push Notifications
  await PushNotificationService.instance.initialize();

  // Step 4: Initialize Connectivity
  await ConnectivityService.instance.initialize();

  // Step 5: Initialize AppLanguageManager FIRST (this also handles SharedPreferences)
  await AppLanguageManager.instance.initialize();

  // Step 6: Setup Service Locator (now that AppLanguageManager is initialized)
  await setupServiceLocator();

  // Step 7: Get Initial Location
  final initialLocation = await AppRouter.getInitialLocation();

  // Remove splash
  FlutterNativeSplash.remove();

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
