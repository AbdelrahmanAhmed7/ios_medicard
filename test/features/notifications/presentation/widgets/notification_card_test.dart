import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/presentation/widgets/notification_card.dart';
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
  });

  String resolve(String language, String key, [String? arg]) {
    final value =
        translations[language]!['notifications'] as Map<String, dynamic>;
    var text = value[key] as String;
    if (arg != null) text = text.replaceFirst('{}', arg);
    return text;
  }

  NotificationModel notification({required bool isRead}) => NotificationModel(
    id: 1,
    title: 'Your appointment is confirmed',
    body: 'Your appointment at MediCard is confirmed for tomorrow at 10:00 AM.',
    imageUrl: '',
    isRead: isRead,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  );

  for (final language in ['en', 'ar']) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('$language, text scale $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(375, 812);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var taps = 0;
        var markAsRead = 0;
        final ago = resolve(language, 'hours_ago', '3');

        Future<void> pumpCard(Widget child) async {
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
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: Scaffold(body: child!),
                  ),
                  home: Align(alignment: Alignment.topCenter, child: child),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        // Read item: flat row with no mark-as-read action.
        await pumpCard(
          NotificationCard(
            notification: notification(isRead: true),
            onTap: () => taps++,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(CachedNetworkImage), findsNothing);
        expect(find.text(ago), findsOneWidget);
        expect(
          find.byKey(const ValueKey('mark-notification-read-1')),
          findsNothing,
        );

        await tester.tap(find.byType(NotificationCard));
        await tester.pumpAndSettle();
        expect(taps, 1);

        // Unread item: compact trailing icon action inside the same flat row.
        await pumpCard(
          NotificationCard(
            notification: notification(isRead: false),
            onTap: () => taps++,
            onMarkAsRead: () => markAsRead++,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text(ago), findsOneWidget);
        expect(
          find.byKey(const ValueKey('mark-notification-read-1')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('mark-notification-read-1')),
        );
        await tester.pumpAndSettle();
        expect(markAsRead, 1);
        expect(taps, 1, reason: 'mark-as-read must not open the notification');
      });
    }
  }
}
