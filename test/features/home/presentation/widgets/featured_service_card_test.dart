import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/features/home/domain/models/featured_service_model.dart';
import 'package:medicard/features/home/presentation/widgets/featured_service_card.dart';
import 'package:medicard/medicard_network/repository/medicard_network_repository.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMedicardNetworkRepository implements MedicardNetworkRepository {
  int getPackageDetailsCallCount = 0;
  final List<int> requestedPackageIds = [];

  @override
  Future<ApiResult<PackageDetailsResponse>> getPackageDetails({
    required int packageId,
  }) async {
    getPackageDetailsCallCount++;
    requestedPackageIds.add(packageId);
    return ApiResult<PackageDetailsResponse>.success(
      PackageDetailsResponse(
        succeeded: true,
        data: PackageDetailsData(
          id: packageId,
          name: 'Full Check-up',
          description: 'Includes lab tests',
          priceBefore: 1200,
          priceAfter: 900,
          serviceNames: const ['CBC', 'Lipid panel'],
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FeaturedServiceModel _featuredService() {
  return const FeaturedServiceModel(
    packageId: 42,
    providerId: 3,
    imageUrl: 'https://example.com/promo.png',
    providerLogoUrl: 'https://example.com/logo.png',
    providerName: 'Clinic',
    serviceName: 'Full Check-up',
    location: 'Maadi, Cairo',
    originalPrice: 1200,
    discountedPrice: 900,
    rating: 4.5,
    reviewCount: 10,
  );
}

Widget _testApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // The app's styles inherit the family from ThemeData; the default test
        // font is a fixed-width box per glyph, which overflows the 270dp card.
        theme: ThemeData(fontFamily: 'Cairo'),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('FeaturedServiceCard package details sheet', () {
    late _FakeMedicardNetworkRepository fake;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      // Load the app's real font so glyph widths are realistic; the default
      // test font renders every glyph at fontSize and overflows the 270dp card.
      final fontLoader = FontLoader('Cairo')
        ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-Medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
      await fontLoader.load();
    });

    setUp(() async {
      await sl.reset();
      fake = _FakeMedicardNetworkRepository();
      sl.registerSingleton<MedicardNetworkRepository>(fake);
      // Wide surface + small DPR so dp width is large enough that the card's
      // Rows (price + CTA) don't overflow during layout in tests.
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          .physicalSize = const Size(1400, 2000);
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          .devicePixelRatio = 1.0;
    });

    tearDown(() async {
      await sl.reset();
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          .resetPhysicalSize();
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          .resetDevicePixelRatio();
    });

    testWidgets('fetches package details exactly once per sheet open', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(FeaturedServiceCard(service: _featuredService())),
      );
      await tester.pumpAndSettle();

      // No request before the sheet is opened.
      expect(fake.getPackageDetailsCallCount, 0);

      await tester.tap(find.byType(FeaturedServiceCard));
      await tester.pumpAndSettle();

      expect(fake.requestedPackageIds, [42]);
      expect(fake.getPackageDetailsCallCount, 1);

      // Force repeated rebuilds of the sheet subtree (media/layout changes).
      // The old inline `future:` re-issued a network call on every rebuild.
      await tester.binding.setSurfaceSize(const Size(540, 960));
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(360, 800));
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(null);
      await tester.pumpAndSettle();

      // Still exactly one request, and it was for the right package.
      expect(fake.getPackageDetailsCallCount, 1);
      expect(fake.requestedPackageIds, [42]);
    });
  });
}
