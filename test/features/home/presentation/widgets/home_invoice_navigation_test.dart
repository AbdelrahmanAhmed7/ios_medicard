import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/cubit/app_refresh_cubit.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/routing/app_router.dart';
import 'package:medicard/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:medicard/features/activity/presentation/cubit/activity_state.dart';
import 'package:medicard/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:medicard/features/cart/presentation/cubit/cart_state.dart';
import 'package:medicard/features/ecard/presentation/cubit/ecard_cubit.dart';
import 'package:medicard/features/ecard/presentation/cubit/ecard_state.dart';
import 'package:medicard/features/home/data/models/home_response_model.dart';
import 'package:medicard/features/home/presentation/cubit/home_cubit.dart';
import 'package:medicard/features/home/presentation/cubit/home_state.dart';
import 'package:medicard/features/home/presentation/cubit/location_cubit.dart';
import 'package:medicard/features/home/presentation/cubit/location_state.dart';
import 'package:medicard/features/home/presentation/pages/home_screen.dart';
import 'package:medicard/features/home/presentation/widgets/home_bottom_nav.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:medicard/features/notifications/presentation/cubit/notification_state.dart';
import 'package:medicard/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:medicard/features/profile/presentation/cubit/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'view invoices opens invoices on the retained home page, including repeat orders',
    (tester) async {
      await sl.reset();
      final refresh = AppRefreshCubit();
      sl.registerSingleton<AppRefreshCubit>(refresh);
      sl.registerFactory<HomeCubit>(_HomeCubit.new);
      sl.registerFactory<ProfileCubit>(_ProfileCubit.new);
      sl.registerFactory<LocationCubit>(_LocationCubit.new);
      final activityCubit = _ActivityCubit();
      sl.registerFactory<ActivityCubit>(() => activityCubit);
      sl.registerFactory<ECardCubit>(_ECardCubit.new);
      sl.registerSingleton<NotificationCubit>(
        _NotificationCubit(),
        dispose: (cubit) => cubit.close(),
      );
      sl.registerFactoryParam<CartCubit, int?, void>((_, _) => _CartCubit());
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = AppRouter.createRouter('/medicard-home');
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
          assetLoader: const _TranslationsLoader(),
          child: Builder(
            builder: (context) => ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, _) => MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final originalState = tester.state(find.byType(HomeScreen));
      expect(
        tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).currentIndex,
        0,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('notification-unread-badge')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      for (var order = 0; order < 2; order++) {
        router.push('/cart');
        await tester.pumpAndSettle();
        // The destination used by the real order-confirmation action.
        router.go('/medicard-home?tab=activity');
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(HomeScreen)), same(originalState));
        expect(
          tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).currentIndex,
          1,
        );
        expect(find.text('Invoices').hitTestable(), findsWidgets);
        if (order == 0) {
          expect(activityCubit.loadedTabs, contains(1));
          await tester.drag(
            find.byType(TabBarView).hitTestable(),
            const Offset(-320, 0),
          );
          await tester.pumpAndSettle();
          expect(activityCubit.loadedTabs.last, 2);
        }
        tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onTap(0);
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/medicard-home',
        );
        expect(
          tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).currentIndex,
          0,
        );
      }
      tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onTap(2);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.queryParameters['tab'],
        'profile',
      );
      expect(
        tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).currentIndex,
        2,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await refresh.close();
      await sl.reset();
    },
  );
}

class _TranslationsLoader extends AssetLoader {
  const _TranslationsLoader();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

class _HomeCubit extends Cubit<HomeState> implements HomeCubit {
  _HomeCubit() : super(const HomeState.success(HomeResponseModel()));
  @override
  Future<void> getHomeData({bool refresh = false}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _ProfileCubit() : super(const ProfileState.initial());
  @override
  Future<void> loadProfile({bool forceRefresh = false}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LocationCubit extends Cubit<LocationState> implements LocationCubit {
  _LocationCubit() : super(const LocationInitial());
  @override
  void Function(Completer<bool>)? onShowRationaleDialog;
  @override
  Future<void> loadLocation() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActivityCubit extends Cubit<ActivityState> implements ActivityCubit {
  _ActivityCubit() : super(const ActivityState.success(invoices: []));

  final List<int> loadedTabs = [];

  @override
  Future<void> loadInvoices({int tab = 1, bool forceRefresh = false}) async {
    loadedTabs.add(tab);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ECardCubit extends Cubit<ECardState> implements ECardCubit {
  _ECardCubit() : super(const ECardState.initial());
  @override
  Future<void> loadCardData({bool forceRefresh = false}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NotificationCubit extends Cubit<NotificationState>
    implements NotificationCubit {
  _NotificationCubit()
    : super(
        NotificationState(
          items: [
            _notification(id: 1, isRead: false),
            _notification(id: 2, isRead: true),
            _notification(id: 3, isRead: false),
          ],
        ),
      );

  static NotificationModel _notification({
    required int id,
    required bool isRead,
  }) => NotificationModel(
    id: id,
    title: 'Notification $id',
    body: 'Body',
    imageUrl: '',
    isRead: isRead,
    createdAt: DateTime(2026),
  );

  @override
  Future<void> init() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CartCubit extends Cubit<CartState> implements CartCubit {
  _CartCubit() : super(const CartState());
  Future<void> loadCart() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
