import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const ProfileAvatar({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();
    if (image == null || image.isEmpty) return _fallbackAvatar();

    final file = File(image);
    if (!image.startsWith('http') && file.existsSync()) {
      return ClipOval(
        child: Image.file(file, width: 64.r, height: 64.r, fit: BoxFit.cover),
      );
    }

    final uri = Uri.tryParse(image);
    final hasRemoteImage =
        uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.pathSegments.where((s) => s.isNotEmpty).isNotEmpty;

    if (!hasRemoteImage) return _fallbackAvatar();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: 64.r,
        height: 64.r,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: 32.r,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, color: Colors.white, size: 32.sp),
    );
  }
}
