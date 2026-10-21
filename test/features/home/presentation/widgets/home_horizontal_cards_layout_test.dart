import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/home/domain/models/featured_service_model.dart';
import 'package:medicard/features/home/domain/models/provider_model.dart';
import 'package:medicard/features/home/presentation/widgets/featured_service_card.dart';
import 'package:medicard/features/home/presentation/widgets/home_horizontal_card_style.dart';
import 'package:medicard/features/home/presentation/widgets/nearest_provider_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final fontLoader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await fontLoader.load();
  });

  for (final width in [320.0, 375.0, 430.0]) {
    testWidgets('home cards keep matching geometry at width $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      const cardSize = Size(
        HomeHorizontalCardStyle.width,
        HomeHorizontalCardStyle.height,
      );
      final nearestCard = find.byType(NearestProviderCard);
      final packageCard = find.byType(FeaturedServiceCard);

      expect(tester.getSize(nearestCard), cardSize);
      expect(tester.getSize(packageCard), cardSize);

      final providerTitle = find.text('Nearest provider');
      final packageTitle = find.text('Health package');
      expect(
        tester.getTopLeft(providerTitle).dy - tester.getTopLeft(nearestCard).dy,
        tester.getTopLeft(packageTitle).dy - tester.getTopLeft(packageCard).dy,
      );
      expect(tester.widget<Text>(providerTitle).style?.fontSize, 13);
      expect(tester.widget<Text>(packageTitle).style?.fontSize, 13);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _testApp() {
  const provider = ProviderModel(
    providerId: 1,
    imageUrl: '',
    name: 'Nearest provider',
    rating: 4.5,
    reviewCount: 10,
    type: 'Clinic',
    location: 'Maadi, Cairo',
    mapUrl: 'https://example.com',
    distanceKm: 1.2,
  );
  const package = FeaturedServiceModel(
    packageId: 1,
    providerId: 1,
    imageUrl: '',
    providerLogoUrl: '',
    providerName: 'Clinic',
    serviceName: 'Health package',
    location: 'Maadi, Cairo',
    originalPrice: 1200,
    discountedPrice: 900,
    rating: 4.5,
    reviewCount: 10,
  );

  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const _TranslationsLoader(),
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(fontFamily: 'Cairo'),
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: HomeHorizontalCardStyle.height,
                  child: const NearestProviderCard(provider: provider),
                ),
                SizedBox(
                  height: HomeHorizontalCardStyle.height,
                  child: const FeaturedServiceCard(service: package),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _TranslationsLoader extends AssetLoader {
  const _TranslationsLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}
