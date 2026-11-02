import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medicard/core/utils/image_url_resolver.dart';
import 'package:medicard/features/search/data/models/category_model.dart';
import 'package:medicard/features/search/presentation/widgets/category_chip.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, String imageUrl) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: CategoryModel(
                id: 37,
                name: 'Radiology',
                imageUrl: imageUrl,
              ),
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  test('detects SVG URLs regardless of case or query parameters', () {
    expect(
      isSvgImageUrl('https://example.com/category/radiology.SVG?version=2'),
      isTrue,
    );
    expect(isSvgImageUrl('https://example.com/category/labs.webp'), isFalse);
  });

  testWidgets('keeps raster categories on CachedNetworkImage', (tester) async {
    await pumpChip(tester, 'https://example.com/category/labs.webp');

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
