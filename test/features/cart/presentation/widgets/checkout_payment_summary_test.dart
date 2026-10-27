import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/cart/domain/models/provider_option.dart';
import 'package:medicard/features/cart/presentation/cubit/cart_state.dart';
import 'package:medicard/features/cart/presentation/widgets/checkout_payment_summary.dart';
import 'package:medicard/features/cart/presentation/widgets/checkout_pricing.dart';
import 'package:medicard/features/home/presentation/widgets/order_placed_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('package pricing calculates the saving percentage', () {
    final pricing = CheckoutPricing.fromState(_packageState());

    expect(pricing.subtotal, 600);
    expect(pricing.total, 480);
    expect(pricing.discount, 120);
    expect(pricing.discountPercentage, 20);
  });

  testWidgets('package summary shows identity, services and expands safely', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(_packageState()));
    await tester.pumpAndSettle();

    expect(find.text('Alfa Labs'), findsOneWidget);
    expect(find.text('alfa lab package'), findsOneWidget);
    expect(find.text('Annual subscription'), findsOneWidget);
    expect(find.text('Vitamin D'), findsNothing);
    expect(find.text('Show all services'), findsOneWidget);

    await tester.tap(find.text('Show all services'));
    await tester.pumpAndSettle();

    expect(find.text('Vitamin D'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final remaining in [0, 2]) {
    testWidgets(
      'order confirmation returns the next step with $remaining services remaining',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        bool? continueRemaining;
        await tester.pumpWidget(
          _testApp(
            _packageState(),
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  continueRemaining = await OrderPlacedDialog.maybeShow(
                    context,
                    orderNumber: '314',
                    remainingServices: remaining,
                  );
                },
                child: const Text('Open confirmation'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open confirmation'));
        await tester.pumpAndSettle();
        expect(find.text('Order confirmed'), findsOneWidget);
        expect(find.text('Payment Successful'), findsNothing);
        final nextStep = find.text(
          remaining > 0 ? 'Continue with remaining services' : 'View invoices',
        );
        await tester.ensureVisible(nextStep);
        await tester.tap(nextStep);
        await tester.pumpAndSettle();
        expect(continueRemaining, remaining > 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

CartState _packageState() {
  return const CartState(
    checkoutProvider: ProviderOption(
      providerId: 80,
      providerName: 'Alfa Labs',
      coveredCount: 0,
      uncoveredCount: 0,
      totalCount: 0,
      totalPriceBefore: 0,
      totalPriceAfter: 0,
      coveredServices: [],
      uncoveredServices: [],
    ),
    checkoutPackageId: 21,
    checkoutPackageName: 'alfa lab package',
    checkoutPackageServiceNames: [
      'ECG',
      'CT Scan',
      'Annual subscription',
      'Vitamin D',
    ],
    checkoutPackagePriceBefore: 600,
    checkoutPackagePriceAfter: 480,
  );
}

Widget _testApp(CartState state, {Widget? child}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    useOnlyLangCode: true,
    assetLoader: const _TestTranslationsLoader(),
    child: Builder(
      builder: (context) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child ?? CheckoutPaymentSummary(state: state),
            ),
          ),
        ),
      ),
    ),
  );
}

class _TestTranslationsLoader extends AssetLoader {
  const _TestTranslationsLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}
