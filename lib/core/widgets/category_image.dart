import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theming/app_colors.dart';
import '../utils/image_url_resolver.dart';

class CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;
  final Color svgColor;

  const CategoryImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.placeholder,
    required this.errorWidget,
    this.fit = BoxFit.cover,
    this.svgColor = AppColors.brandBlueClr,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = resolveImageUrl(imageUrl);
    if (resolvedUrl == null) {
      return SizedBox(width: width, height: height, child: errorWidget);
    }

    return SizedBox(
      width: width,
      height: height,
      child: buildCategoryImageContent(
        imageUrl: resolvedUrl,
        fit: fit,
        svgColor: svgColor,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}

@visibleForTesting
Widget buildCategoryImageContent({
  required String imageUrl,
  required BoxFit fit,
  Color svgColor = AppColors.brandBlueClr,
  required Widget placeholder,
  required Widget errorWidget,
}) {
  if (isSvgImageUrl(imageUrl)) {
    return SvgPicture.network(
      imageUrl,
      fit: fit,
      colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
      placeholderBuilder: (_) => placeholder,
      errorBuilder: (_, _, _) => errorWidget,
    );
  }

  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    placeholder: (_, _) => placeholder,
    errorWidget: (_, _, _) => errorWidget,
  );
}
