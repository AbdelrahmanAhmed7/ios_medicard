import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/utils/shimmer_card.dart';
import 'package:medicard/features/home/presentation/widgets/ecard_preview_card.dart';
import 'package:medicard/features/home/presentation/widgets/home_shimmer.dart';

void main() {
  for (final width in [320.0, 375.0, 430.0]) {
    testWidgets('renders inside the home scroll view at width $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp(const HomeShimmer()));
      await tester.pump();

      expect(find.byType(SmoothShimmer), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byKey(const ValueKey('home-shimmer-promo')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('home-shimmer-appointments')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('home-shimmer-providers')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('home-shimmer-services')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('guest variant does not show appointments', (tester) async {
    await tester.pumpWidget(
      _testApp(const HomeShimmer(showAppointments: false)),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('home-shimmer-appointments')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('home-shimmer-providers')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-shimmer-services')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eCard shimmer matches the rendered card footprint', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_testApp(const ECardPreviewShimmer()));
    await tester.pump();

    final placeholder = find.byKey(const ValueKey('home-shimmer-ecard'));
    expect(placeholder, findsOneWidget);
    expect(find.byType(SmoothShimmer), findsOneWidget);

    final size = tester.getSize(placeholder);
    expect(size.width, 375 - 32);
    expect(size.width / size.height, closeTo(1024 / 596, 0.001));
    expect(tester.getTopLeft(placeholder).dx, 16);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget shimmer) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, _) => MaterialApp(
      home: Scaffold(
        body: CustomScrollView(slivers: [SliverToBoxAdapter(child: shimmer)]),
      ),
    ),
  );
}
