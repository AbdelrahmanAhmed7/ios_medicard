import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/medicard_network/presentation/widgets/provider_package_card.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';

void main() {
  for (final cardWidth in [146.0, 173.5, 201.0]) {
    testWidgets(
      'package footer stays close to description at card width $cardWidth',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(430, 812);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        for (final textScale in [0.8, 1.0, 1.3, 1.6, 2.0]) {
          await tester.pumpWidget(
            _testApp(cardWidth: cardWidth, textScale: textScale),
          );
          await tester.pumpAndSettle();

          final descriptionBottom = tester
              .getBottomLeft(
                find.text(
                  'A package with several diagnostic services included',
                ),
              )
              .dy;
          final footerTop = tester
              .getTopLeft(find.byKey(const ValueKey('provider-package-footer')))
              .dy;
          final cardBottom = tester
              .getBottomRight(find.byType(ProviderPackageCard))
              .dy;
          final footerBottom = tester
              .getBottomRight(
                find.byKey(const ValueKey('provider-package-footer')),
              )
              .dy;
          expect(
            footerTop - descriptionBottom,
            lessThanOrEqualTo(18),
            reason: 'the price and add button should follow the description',
          );
          expect(
            cardBottom - footerBottom,
            lessThanOrEqualTo(7),
            reason: 'the card should not leave excess space below its footer',
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}

Widget _testApp({required double cardWidth, required double textScale}) {
  final package = ProviderPackage(
    id: 1,
    name: 'Comprehensive health package',
    imageUrl: '',
    description: 'A package with several diagnostic services included',
    priceBefore: 1200,
    priceAfter: 900,
  );

  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, _) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: cardWidth,
            child: ProviderPackageCard(packageData: package, onQuickAdd: () {}),
          ),
        ),
      ),
    ),
  );
}
