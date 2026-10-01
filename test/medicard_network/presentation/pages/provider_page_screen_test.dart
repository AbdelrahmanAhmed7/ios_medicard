import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/features/cart/domain/repository/cart_repository.dart';
import 'package:medicard/features/cart/domain/services/cart_sync_service.dart';
import 'package:medicard/medicard_network/logic/provider_page_cubit.dart';
import 'package:medicard/medicard_network/presentation/pages/provider_page_screen.dart';
import 'package:medicard/medicard_network/presentation/widgets/provider_service_card.dart';
import 'package:medicard/medicard_network/repository/medicard_network_repository.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import 'package:medicard/network/data/provider_services_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMedicardNetworkRepository implements MedicardNetworkRepository {
  int servicesCalls = 0;
  String? lastSearch;

  @override
  Future<ApiResult<ProviderPageResponse>> getProviderPage({
    required int providerId,
  }) async {
    return ApiResult<ProviderPageResponse>.success(
      ProviderPageResponse(
        succeeded: true,
        data: ProviderPageData(
          id: providerId,
          name: 'Test Clinic',
          categoryName: 'Labs',
          imageUrl: '',
        ),
      ),
    );
  }

  @override
  Future<ApiResult<ProviderServicesResponse>> getProviderServices({
    required int providerId,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    servicesCalls++;
    lastSearch = search;
    return ApiResult<ProviderServicesResponse>.success(
      ProviderServicesResponse(
        succeeded: true,
        data: ProviderServicesData(
          items: [
            ProviderService(id: 1, serviceName: 'CBC', priceAfter: 150),
            ProviderService(id: 2, serviceName: 'Lipid', priceAfter: 250),
          ],
          totalPages: 1,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeInvoiceRepository implements InvoiceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCartRepository implements CartRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _testApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(fontFamily: 'Cairo'),
          home: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  group('ProviderPageScreen scoped rebuilds', () {
    late _FakeMedicardNetworkRepository repo;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      final fontLoader = FontLoader('Cairo')
        ..addFont(rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-Medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-SemiBold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
      await fontLoader.load();
    });

    setUp(() async {
      await sl.reset();
      repo = _FakeMedicardNetworkRepository();
      sl.registerFactoryParam<ProviderPageCubit, int, void>(
        (providerId, _) => ProviderPageCubit(
          repo,
          _FakeInvoiceRepository(),
          _FakeCartRepository(),
          CartSyncService(),
          providerId,
        ),
      );
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('search keeps focus, text, and cards after debounce', (
      tester,
    ) async {
      await tester.pumpWidget(
        _testApp(const ProviderPageScreen(providerId: 7)),
      );
      await tester.pumpAndSettle();

      // Initial load: page + services.
      expect(find.byType(ProviderServiceCard), findsNWidgets(2));
      final initialCalls = repo.servicesCalls;
      expect(initialCalls, greaterThanOrEqualTo(1));

      // Type a query: the field keeps focus and text across frames.
      final field = find.byType(TextField);
      await tester.tap(field);
      await tester.enterText(field, 'lab');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('lab'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue,
      );

      // Past the 300ms debounce the filtered fetch fires…
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(repo.servicesCalls, greaterThan(initialCalls));
      expect(repo.lastSearch, 'lab');

      // …and the screen is intact: text kept, focus kept, cards kept.
      expect(find.byType(ProviderServiceCard), findsNWidgets(2));
      expect(find.text('lab'), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue,
      );
    });
  });
}
