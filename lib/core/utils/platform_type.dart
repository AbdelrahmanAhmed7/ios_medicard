import 'package:flutter/foundation.dart';

/// Mirrors the backend `platformType` enum: Android = 0, Ios = 1, Web = 2.
///
/// Resolved from [defaultTargetPlatform] (not `dart:io`) so it compiles on
/// every target, including web. Desktop targets have no backend value, so
/// they fall back to iOS.
enum PlatformType {
  android(0),
  ios(1),
  web(2);

  final int value;

  const PlatformType(this.value);

  static PlatformType get current {
    if (kIsWeb) return PlatformType.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformType.android;
      case TargetPlatform.iOS:
        return PlatformType.ios;
      default:
        return PlatformType.ios;
    }
  }
}
