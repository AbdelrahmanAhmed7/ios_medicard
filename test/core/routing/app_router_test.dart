import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/routing/app_router.dart';

void main() {
  const privateRoutes = [
    '/medicard-home',
    '/notifications',
    '/medicard-profile',
    '/medicard-edit-profile-new',
    '/manual-prescription',
    '/change-password',
    '/family-members',
    '/family-members/add',
    '/family-members/edit',
    '/addresses',
    '/addresses/add',
    '/addresses/edit',
    '/digital-membership',
    '/cart',
    '/checkout',
    '/invoice-details',
    '/choose-provider',
    '/pending-appointment-details',
  ];

  const publicRoutes = [
    '/guest-home',
    '/medicard-login',
    '/medicard-register',
    '/forgot-password',
    '/forgot-password/verify',
    '/forgot-password/reset',
    '/medicard-activation',
    '/search',
    '/packages',
    '/help-center',
    '/privacy-policy',
    '/refund-policy',
    '/terms-and-conditions',
    '/provider-page',
    '/provider-branches',
    '/provider-reviews',
  ];

  test('unauthenticated private routes redirect to login', () async {
    for (final route in privateRoutes) {
      final redirect = await AppRouter.redirectForTest(
        location: route,
        authenticated: false,
      );
      expect(redirect, startsWith('/medicard-login?redirect='), reason: route);
      expect(
        Uri.decodeComponent(Uri.parse(redirect!).queryParameters['redirect']!),
        route,
      );
    }
  });

  test('unauthenticated public routes remain accessible', () async {
    for (final route in publicRoutes) {
      expect(
        await AppRouter.redirectForTest(
          location: route,
          authenticated: false,
        ),
        isNull,
        reason: route,
      );
    }
  });

  test('authenticated users can open private routes and avoid auth loops', () async {
    for (final route in privateRoutes) {
      expect(
        await AppRouter.redirectForTest(
          location: route,
          authenticated: true,
        ),
        isNull,
        reason: route,
      );
    }
    expect(
      await AppRouter.redirectForTest(
        location: '/medicard-login?redirect=%2Fcart',
        authenticated: true,
      ),
      '/medicard-home',
    );
  });

  test('private destination preserves query parameters safely', () async {
    final redirect = await AppRouter.redirectForTest(
      location: '/cart?providerId=7',
      authenticated: false,
    );
    expect(
      Uri.decodeComponent(Uri.parse(redirect!).queryParameters['redirect']!),
      '/cart?providerId=7',
    );
  });
}
