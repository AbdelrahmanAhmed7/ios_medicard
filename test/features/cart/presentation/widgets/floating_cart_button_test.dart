import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/routing/app_router.dart';
import 'package:medicard/features/cart/domain/models/cart.dart';
import 'package:medicard/features/cart/domain/repository/cart_repository.dart';
import 'package:medicard/features/cart/domain/services/cart_sync_service.dart';
import 'package:medicard/features/cart/presentation/widgets/floating_cart_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCartRepository extends Fake implements CartRepository {
  @override
  Future<ApiResult<Cart>> getCart() async => const ApiResult.success(
    Cart(items: [], totalCount: 3, categoryCounters: []),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'restores normalized placement, avoids keyboard, and persists a drag',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({
        SharedPrefKeys.cartFabPositionSaved: true,
        SharedPrefKeys.cartFabDockedRight: false,
        SharedPrefKeys.cartFabVerticalRatio: 0.8,
      });
      await sl.reset();
      addTearDown(sl.reset);

      final repository = _FakeCartRepository();
      sl.registerSingleton<CartRepository>(repository);
      sl.registerSingleton<CartSyncService>(CartSyncService());
      AppRouter.currentLocation.value = '/medicard-home';
      addTearDown(() => AppRouter.currentLocation.value = '');

      final keyboardInset = ValueNotifier<double>(0);
      addTearDown(keyboardInset.dispose);
      await tester.pumpWidget(_testApp(keyboardInset));
      await tester.pumpAndSettle();

      AnimatedPositioned position() =>
          tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned));

      expect(position().left, 8);
      final originalTop = position().top!;

      keyboardInset.value = 300;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(position().top!, lessThan(originalTop));

      keyboardInset.value = 0;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(position().top!, closeTo(originalTop, 0.01));

      await tester.drag(
        find.byIcon(Icons.shopping_cart_outlined),
        const Offset(340, -160),
      );
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool(SharedPrefKeys.cartFabPositionSaved), isTrue);
      expect(preferences.getBool(SharedPrefKeys.cartFabDockedRight), isTrue);
      expect(
        preferences.getDouble(SharedPrefKeys.cartFabVerticalRatio),
        inInclusiveRange(0.0, 1.0),
      );
    },
  );

  testWidgets(
    'remains hidden on /checkout even if route name is empty or popup is open',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      await sl.reset();
      addTearDown(sl.reset);

      sl.registerSingleton<CartRepository>(_FakeCartRepository());
      sl.registerSingleton<CartSyncService>(CartSyncService());
      AppRouter.currentLocation.value = '/checkout';
      addTearDown(() => AppRouter.currentLocation.value = '');

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => const MaterialApp(
            home: Stack(
              children: [SizedBox.expand(), FloatingCartButton()],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
    },
  );
}

Widget _testApp(ValueNotifier<double> keyboardInset) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(
      home: ValueListenableBuilder<double>(
        valueListenable: keyboardInset,
        builder: (context, inset, _) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(viewInsets: EdgeInsets.only(bottom: inset)),
          child: const Stack(
            children: [SizedBox.expand(), FloatingCartButton()],
          ),
        ),
      ),
    ),
  );
}
