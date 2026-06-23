import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/network/dio_factory.dart';

import 'core/di/service_locator.dart';
import 'core/services/location_repository.dart';
import 'core/services/location_service.dart';
import 'core/network/connectivity_service.dart';
import 'core/routing/app_router.dart';
import 'core/theming/font_manager.dart';
import 'features/notifications/push_notification_service.dart';

void main() async {
  // Preserve native splash until we explicitly remove it
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // تهيئة EasyLocalization
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.instance.initialize();

  await ConnectivityService.instance.initialize();
  await setupServiceLocator();

  await sl<LocationRepository>().resolve(sl<LocationService>());

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final startLocale = deviceLocale.languageCode == 'ar'
      ? const Locale('ar')
      : const Locale('en');
  DioFactory.setAcceptLanguage(startLocale.languageCode);

  final initialLocation = await AppRouter.getInitialLocation();

  FlutterNativeSplash.remove();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
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
    return ScreenUtilInit(
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
      ),
    );
  }
}
