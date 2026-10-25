import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/theming/app_toast.dart';

void main() {
  tearDown(dismissActiveToast);

  testWidgets('does not stack the same toast while it is visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: toastNavigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    showInfoToast('Shown once');
    showInfoToast('Shown once');
    await tester.pump();

    expect(find.text('Shown once'), findsOneWidget);

    dismissActiveToast();
    await tester.pump();
  });

  testWidgets('a new toast replaces the currently visible toast', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: toastNavigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    showInfoToast('First');
    showErrorToast('Second');
    await tester.pump();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    dismissActiveToast();
    await tester.pump();
  });
}
