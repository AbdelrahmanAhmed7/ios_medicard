import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theming/app_text_styles.dart';
import '../utils/image_url_resolver.dart';

/// Circular provider avatar with a logo and an initials fallback.
class ProviderLogo extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const ProviderLogo({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveImageUrl(imageUrl);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: url == null || url.trim().isEmpty
          ? _Initials(name: name, size: size)
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                memCacheWidth: (size * 3).round(),
                memCacheHeight: (size * 3).round(),
                fit: BoxFit.fill,
                placeholder: (_, _) => _Initials(name: name, size: size),
                errorWidget: (_, _, _) => _Initials(name: name, size: size),
              ),
            ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final double size;

  const _Initials({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.of(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF3872B1),
        ),
      ),
    );
  }
}
