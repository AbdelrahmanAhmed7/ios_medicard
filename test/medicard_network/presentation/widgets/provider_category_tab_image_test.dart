import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/theming/app_colors.dart';
import 'package:medicard/core/utils/image_url_resolver.dart';
import 'package:medicard/core/widgets/category_image.dart';

void main() {
  test('renders absolute SVG URLs using SvgPicture.network', () {
    final image = buildCategoryImageContent(
      imageUrl: 'https://example.com/uploads/categories/radiology.svg',
      fit: BoxFit.cover,
      placeholder: const SizedBox.shrink(),
      errorWidget: const Icon(Icons.error),
    );

    expect(image, isA<SvgPicture>());
    expect(
      (image as SvgPicture).colorFilter,
      const ColorFilter.mode(AppColors.brandBlueClr, BlendMode.srcIn),
    );
  });

  test('uses the selected foreground color for SVGs on selected chips', () {
    final image = buildCategoryImageContent(
      imageUrl: 'https://example.com/uploads/categories/radiology.svg',
      fit: BoxFit.cover,
      svgColor: Colors.white,
      placeholder: const SizedBox.shrink(),
      errorWidget: const Icon(Icons.error),
    );

    expect(
      (image as SvgPicture).colorFilter,
      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  });

  test('keeps raster category URLs on CachedNetworkImage', () {
    final image = buildCategoryImageContent(
      imageUrl: 'https://example.com/uploads/categories/radiology.png',
      fit: BoxFit.cover,
      placeholder: const SizedBox.shrink(),
      errorWidget: const Icon(Icons.error),
    );

    expect(image, isA<CachedNetworkImage>());
  });

  test('resolves relative category URLs before selecting the renderer', () {
    final imageUrl = resolveImageUrl('/uploads/categories/radiology.svg')!;
    final image = buildCategoryImageContent(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: const SizedBox.shrink(),
      errorWidget: const Icon(Icons.error),
    );

    expect(
      imageUrl,
      'https://medicard-api-v2.medicardeg.com/uploads/categories/radiology.svg',
    );
    expect(image, isA<SvgPicture>());
  });
}
