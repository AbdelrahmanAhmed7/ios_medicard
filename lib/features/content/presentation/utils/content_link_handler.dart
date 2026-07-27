import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';

enum ContentLinkAction {
  ignoredRelative,
  email,
  phone,
  whatsapp,
  web,
  unsupported,
}

class ContentLinkHandler {
  final UrlLauncherService _launcher;

  const ContentLinkHandler(this._launcher);

  static ContentLinkAction classifyUrl(String? rawUrl) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) return ContentLinkAction.unsupported;

    final uri = Uri.tryParse(value);
    if (uri == null) return ContentLinkAction.unsupported;

    if (!uri.hasScheme) {
      return value == '/'
          ? ContentLinkAction.ignoredRelative
          : ContentLinkAction.unsupported;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'mailto') return ContentLinkAction.email;
    if (scheme == 'tel') return ContentLinkAction.phone;
    if (scheme == 'http' || scheme == 'https') {
      final host = uri.host.toLowerCase();
      if (host.contains('wa.me') || host.contains('whatsapp.com')) {
        return ContentLinkAction.whatsapp;
      }
      return ContentLinkAction.web;
    }

    return ContentLinkAction.unsupported;
  }

  ContentLinkAction classify(String? rawUrl) => classifyUrl(rawUrl);

  Future<bool> handle(BuildContext context, String? rawUrl) async {
    final value = rawUrl?.trim();
    switch (classify(value)) {
      case ContentLinkAction.ignoredRelative:
        if (context.mounted) context.go('/medicard-home');
        return true;
      case ContentLinkAction.email:
        final uri = Uri.parse(value!);
        return _launcher.launchEmail(uri.path);
      case ContentLinkAction.phone:
        final uri = Uri.parse(value!);
        return _launcher.makePhoneCall(uri.path);
      case ContentLinkAction.whatsapp:
      case ContentLinkAction.web:
        return _launcher.launchURL(value!);
      case ContentLinkAction.unsupported:
        return false;
    }
  }
}
