import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/search/data/models/search_provider_model.dart';
import 'package:medicard/features/search/presentation/widgets/provider_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final fontLoader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('contact actions and card order follow LTR and RTL direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const [
        SearchProviderModel(
          providerId: 80,
          providerName: 'Hotline only',
          hotline: '12345',
        ),
        SearchProviderModel(
          providerId: 81,
          providerName: 'WhatsApp only',
          whatsApp: '01006007245',
        ),
        SearchProviderModel(
          providerId: 82,
          providerName: 'LTR card',
          averageRating: 4.8,
          hotline: '12300',
          whatsApp: '01000000001',
        ),
        SearchProviderModel(
          providerId: 83,
          providerName: 'RTL card',
          averageRating: 4.6,
          hotline: '12301',
          whatsApp: '01000000002',
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.phone_in_talk_rounded), findsNWidgets(3));
    expect(find.byKey(const ValueKey('provider_whatsapp_80')), findsNothing);
    expect(find.byKey(const ValueKey('provider_whatsapp_81')), findsOneWidget);

    expect(
      tester.getCenter(find.byKey(const ValueKey('provider_image_82'))).dx,
      lessThan(tester.getCenter(find.text('LTR card')).dx),
    );
    final ltrImageRect = tester.getRect(
      find.byKey(const ValueKey('provider_image_82')),
    );
    final ltrRatingCenter = tester.getCenter(
      find.byKey(const ValueKey('provider_rating_82')),
    );
    expect(ltrImageRect.contains(ltrRatingCenter), isTrue);
    expect(ltrRatingCenter.dx, lessThan(ltrImageRect.center.dx));
    expect(
      tester.getCenter(find.byKey(const ValueKey('provider_phone_82'))).dx,
      lessThan(
        tester.getCenter(find.byKey(const ValueKey('provider_whatsapp_82'))).dx,
      ),
    );

    expect(
      tester.getCenter(find.byKey(const ValueKey('provider_image_83'))).dx,
      greaterThan(tester.getCenter(find.text('RTL card')).dx),
    );
    final rtlImageRect = tester.getRect(
      find.byKey(const ValueKey('provider_image_83')),
    );
    final rtlRatingCenter = tester.getCenter(
      find.byKey(const ValueKey('provider_rating_83')),
    );
    expect(rtlImageRect.contains(rtlRatingCenter), isTrue);
    expect(rtlRatingCenter.dx, greaterThan(rtlImageRect.center.dx));
    expect(
      tester.getCenter(find.byKey(const ValueKey('provider_phone_83'))).dx,
      greaterThan(
        tester.getCenter(find.byKey(const ValueKey('provider_whatsapp_83'))).dx,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(List<SearchProviderModel> providers) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(fontFamily: 'Cairo'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: providers
                    .map(
                      (provider) => Directionality(
                        textDirection: provider.providerId == 83
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        child: ProviderCard(provider: provider),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
