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

  for (final textScale in [0.8, 1.0, 1.3, 1.6, 2.0]) {
    testWidgets(
      'home card footers keep the same bottom inset at text scale $textScale',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(430, 812);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(_testApp(textScale: textScale));
        await tester.pumpAndSettle();

        final packageBottom = tester
            .getBottomRight(find.byType(FeaturedServiceCard))
            .dy;
        final packageFooterBottom = tester
            .getBottomRight(
              find.byKey(const ValueKey('featured-package-footer')),
            )
            .dy;
        final providerBottom = tester
            .getBottomRight(find.byType(NearestProviderCard))
            .dy;
        final providerFooterBottom = tester
            .getBottomRight(
              find.byKey(const ValueKey('nearest-provider-footer')),
            )
            .dy;

        expect(
          packageBottom - packageFooterBottom,
          HomeHorizontalCardStyle.footerBottomInset,
        );
        expect(
          providerBottom - providerFooterBottom,
          HomeHorizontalCardStyle.footerBottomInset,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _testApp({double textScale = 1}) {
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: HomeHorizontalCardStyle.height,
                  child: NearestProviderCard(provider: provider),
                ),
                SizedBox(
                  height: HomeHorizontalCardStyle.height,
                  child: FeaturedServiceCard(service: package),
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
