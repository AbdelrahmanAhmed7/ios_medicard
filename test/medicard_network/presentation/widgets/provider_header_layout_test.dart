import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/medicard_network/presentation/widgets/provider_shared_widgets.dart';
import 'package:medicard/medicard_network/presentation/widgets/provider_top_header.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryTranslations extends AssetLoader {
  final Map<String, Map<String, dynamic>> translations;

  const _MemoryTranslations(this.translations);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      translations[locale.languageCode]!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translations = <String, Map<String, dynamic>>{};

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    for (final language in ['en', 'ar']) {
      translations[language] =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/translations/$language.json',
                ),
              )
              as Map<String, dynamic>;
    }
    for (final family in ['Cairo', 'Roboto']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'))).load();
    }
  });

  for (final language in ['en', 'ar']) {
    for (final width in [320.0, 375.0, 430.0]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('$language, width $width, text scale $scale', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 812);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          var reviewTaps = 0;
          var branchTaps = 0;
          final arabic = language == 'ar';
          final name = arabic
              ? 'المركز المتخصص للتحاليل الطبية والأشعة التشخيصية'
              : 'Specialist Medical Laboratory and Diagnostic Imaging Center';
          final branch = ProviderBranch(
            branchId: 1,
            branchName: arabic
                ? 'فرع مدينة نصر - شارع مصطفى النحاس'
                : 'Nasr City Branch - Mostafa El Nahas Street',
          );
          await tester.pumpWidget(
            EasyLocalization(
              supportedLocales: const [Locale('en'), Locale('ar')],
              startLocale: Locale(language),
              saveLocale: false,
              path: 'assets/translations',
              assetLoader: _MemoryTranslations(translations),
              child: ScreenUtilInit(
                designSize: const Size(375, 812),
                minTextAdapt: true,
                builder: (context, _) => MaterialApp(
                  locale: context.locale,
                  supportedLocales: context.supportedLocales,
                  localizationsDelegates: context.localizationDelegates,
                  theme: ThemeData(fontFamily: arabic ? 'Cairo' : 'Roboto'),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                  home: Scaffold(
                    body: Column(
                      children: [
                        const ProviderTopHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: ProviderInfoRow(
                              data: ProviderPageData(
                                id: 1,
                                name: name,
                                categoryName: arabic
                                    ? 'معامل التحاليل والأشعة'
                                    : 'Laboratory and diagnostic imaging',
                                imageUrl: '',
                                hotLine: '12345',
                                averageRating: 4.8,
                                totalReviews: 12345,
                                branches: [branch],
                              ),
                              servicesCount: 1234,
                              selectedBranch: branch,
                              onBranchTap: () => branchTaps++,
                              onRatingTap: () => reviewTaps++,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(
            find.descendant(
              of: find.byType(ProviderTopHeader),
              matching: find.byType(Text),
            ),
            findsOneWidget,
          );
          expect(
            find.text(arabic ? 'مقدم الخدمة' : 'Provider'),
            findsOneWidget,
          );
          expect(
            tester.getTopLeft(find.text(name)).dy,
            greaterThan(
              tester.getBottomLeft(find.byType(ProviderTopHeader)).dy,
            ),
          );

          // Rating lives on a compact meta line below the provider name.
          final ratingFinder = find.text('4.8');
          expect(ratingFinder, findsOneWidget);
          expect(
            tester.getTopLeft(ratingFinder).dy,
            greaterThan(tester.getTopLeft(find.text(name)).dy),
          );
          expect(
            find.text('provider_page.services_count'.tr(args: ['1234'])),
            findsOneWidget,
          );

          await tester.ensureVisible(ratingFinder);
          await tester.tap(ratingFinder);
          await tester.pumpAndSettle();
          expect(reviewTaps, 1);
          await tester.ensureVisible(find.text(branch.branchName));
          await tester.tap(find.text(branch.branchName));
          await tester.pumpAndSettle();
          expect(branchTaps, 1);
          expect(tester.takeException(), isNull);
          expect(find.byType(ProviderTopHeader).hitTestable(), findsOneWidget);
        });
      }
    }
  }
}
