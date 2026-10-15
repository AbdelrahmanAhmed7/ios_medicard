import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/theming/app_spacing.dart';
import 'package:medicard/core/widgets/app_simple_header.dart';

void main() {
  testWidgets('title starts at the shared page gutter', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const MaterialApp(
          home: Scaffold(
            body: AppSimpleHeader(title: 'Profile', showBack: false),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Profile')).dx,
      moreOrLessEquals(AppSpacing.pageHorizontal, epsilon: 0.01),
    );
  });
}
