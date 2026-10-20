import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:medicard/core/widgets/app_simple_header.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';

void main() {
  for (final width in [320.0, 375.0, 430.0]) {
    for (final direction in TextDirection.values) {
      testWidgets('headers align at $width in $direction', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 812);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var backTaps = 0;
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, _) => MaterialApp(
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  appBar: AppBar(
                    leadingWidth: AppHeaderSpacing.contentStart,
                    leading: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: AppHeaderSpacing.start,
                      ),
                      child: AppHeaderBackButton(onPressed: () => backTaps++),
                    ),
                    centerTitle: false,
                    titleSpacing: 0,
                    title: const Text('Family'),
                  ),
                  body: Column(
                    children: [
                      AppSimpleHeader(
                        title: 'Details',
                        onBack: () => backTaps++,
                      ),
                      Padding(
                        padding: AppHeaderSpacing.padding(top: 12, bottom: 6),
                        child: Row(
                          children: [
                            AppHeaderBackButton(onPressed: () => backTaps++),
                            const Expanded(child: Text('Search')),
                          ],
                        ),
                      ),
                      AuthHeader(
                        title: 'Sign in',
                        showBackButton: true,
                        onBack: () => backTaps++,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scale = width / 375;
        final rtl = direction == TextDirection.rtl;
        final arrows = find.byIcon(Icons.arrow_back_ios_new_rounded);
        expect(arrows, findsNWidgets(4));
        for (final arrow in arrows.evaluate()) {
          final finder = find.byWidget(arrow.widget);
          expect(
            tester.getCenter(finder).dx,
            closeTo(rtl ? width - 28 * scale : 28 * scale, 0.01),
          );
          await tester.tap(finder);
        }
        expect(backTaps, 4);
        for (final title in ['Family', 'Details', 'Search']) {
          final rect = tester.getRect(find.text(title));
          expect(
            rtl ? width - rect.right : rect.left,
            closeTo(52 * scale, 0.01),
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final direction in TextDirection.values) {
    testWidgets('title is inline and subtitle aligns with it in $direction', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: AppSimpleHeader(
                  title: 'Reviews',
                  subtitle: 'Clinic name',
                  onBack: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rtl = direction == TextDirection.rtl;
      final arrow = tester.getRect(
        find.byIcon(Icons.arrow_back_ios_new_rounded),
      );
      final title = tester.getRect(find.text('Reviews'));
      final subtitle = tester.getRect(find.text('Clinic name'));

      expect(rtl ? 375 - title.right : title.left, closeTo(52, 0.01));
      expect(rtl ? 375 - subtitle.right : subtitle.left, closeTo(52, 0.01));
      expect(title.top, lessThan(arrow.bottom));
      expect(title.bottom, greaterThan(arrow.top));
      expect(subtitle.top, greaterThan(arrow.bottom));
    });
  }
}
