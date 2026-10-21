import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_refresh_service.dart';
import '../../core/auth/auth_session_storage.dart';
import '../../features/activate_card/presentation/pages/activate_card_screen.dart';
import '../../features/activity/domain/models/invoice_item.dart';
import '../../features/activity/presentation/pages/invoice_details_screen.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/cart/presentation/pages/checkout_screen.dart';
import '../../features/ecard/presentation/cubit/ecard_cubit.dart';
import '../../features/ecard/presentation/pages/digital_membership_screen.dart';
import '../../features/content/domain/models/content_type.dart';
import '../../features/content/presentation/cubit/content_cubit.dart';
import '../../features/content/presentation/pages/content_screen.dart';
import '../../features/family_members/data/models/family_member_model.dart';
import '../../features/family_members/presentation/cubit/family_members_cubit.dart';
import '../../features/family_members/presentation/pages/add_edit_family_member_screen.dart';
import '../../features/family_members/presentation/pages/family_members_list_screen.dart';
import '../../features/addresses/data/models/user_address_model.dart';
import '../../features/addresses/presentation/cubit/addresses_cubit.dart';
import '../../features/addresses/presentation/cubit/address_form_cubit.dart';
import '../../features/addresses/presentation/pages/add_edit_address_screen.dart';
import '../../features/addresses/presentation/pages/addresses_list_screen.dart';
import '../../features/guest_home/presentation/pages/guest_home_screen.dart';
import '../../features/help_center/presentation/pages/help_center_screen.dart';
import '../../features/home/domain/models/appointment_model.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/widgets/pending_appointment_details_screen.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/packages/presentation/pages/all_packages_screen.dart';
import '../../features/profile/data/models/profile_response_model.dart';
import '../../features/profile/presentation/cubit/change_password_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/search/presentation/cubit/filter_cubit.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/screens/choose_provider_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../medicard_network/logic/provider_page_cubit.dart';
import '../../medicard_network/presentation/pages/branches_screen.dart';
import '../../medicard_network/presentation/pages/provider_page_screen.dart';
import '../../medicard_network/presentation/pages/reviews_screen.dart';
import '../../network/data/provider_page_response_model.dart';
import '../../presentation/logic/medicard_login_cubit.dart';
import '../../presentation/logic/register_cubit.dart';
import '../../presentation/medicard_login_screen.dart';
import '../../presentation/register_screen.dart';
import '../constants/constants.dart';
import '../cubit/app_refresh_cubit.dart';
import '../di/service_locator.dart';
import '../helpers/shared_pref_helper.dart';
import '../theming/app_toast.dart';

class AppRouter {
  /// Live router instance, set by [createRouter]. Used by widgets that live
  /// outside the router subtree (e.g. app-wide overlays in MaterialApp
  /// builder) and therefore can't use `context.push`.
  static GoRouter? current;

  /// Current location path, updated by [_LocationObserver]. Overlays listen
  /// to hide themselves on specific screens (e.g. floating cart on cart).
  static final ValueNotifier<String> currentLocation = ValueNotifier('');

  /// Determines the initial route based on the stored session state.
  ///
  /// Decision tree:
  /// 1. No session → check onboarding flag → /onboarding or /guest-home
  /// 2. Refresh token definitely expired → clear session → /medicard-login
  /// 3. Access token still valid → /medicard-home
  /// 4. Access token expired but refresh token valid → attempt refresh
  ///    → success: /medicard-home | failure: /medicard-login
  static Future<String> getInitialLocation() async {
    try {
      final sessionStorage = const AuthSessionStorage();
      final session = await sessionStorage.getSession();

      // No stored session at all.
      if (session == null) {
        return _loginOrOnboarding();
      }

      // If an old session only has an access token, keep it while it is still
      // valid. Once expired there is no refresh token to recover it.
      if (!session.hasRefreshToken) {
        if (session.accessTokenExpiresAt != null &&
            session.isAccessTokenExpiredOrAboutToExpire) {
          await sessionStorage.clearSession();
          return '/medicard-login';
        }
        return '/medicard-home';
      }

      if (session.isRefreshTokenExpired) {
        await sessionStorage.clearSession();
        return '/medicard-login';
      }

      // Access token is still valid — go straight home.
      if (!session.isAccessTokenExpiredOrAboutToExpire) {
        return '/medicard-home';
      }

      // Access token expired but refresh token is valid — try to refresh
      // silently so the user lands directly on the home screen.
      if (kDebugMode) {
        debugPrint(
          '[AppRouter] Access token expired at startup — refreshing silently',
        );
      }

      final refreshService = sl<AuthRefreshService>();
      final newSession = await refreshService.refreshToken();
      if (newSession != null) {
        return '/medicard-home';
      }

      final retainedSession = await sessionStorage.getSession();
      if (retainedSession != null && retainedSession.hasRefreshToken) {
        return '/medicard-home';
      }

      // Refresh failed.
      return '/medicard-login';
    } catch (e) {
      if (kDebugMode) debugPrint('[AppRouter] getInitialLocation error: $e');
      return '/guest-home';
    }
  }

  static Future<String> _loginOrOnboarding() async {
    final hasSeenOnboarding = await SharedPrefHelper.getBool(
      SharedPrefKeys.hasSeenOnboarding,
    );
    return hasSeenOnboarding ? '/guest-home' : '/onboarding';
  }

  static String normalizeLocation(String location) {
    final trimmed = location.trim();
    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';

    switch (normalized.toLowerCase()) {
      case '/':
        return '/guest-home';
      case '/home':
      case '/medicardhome':
      case '/medicard-home':
        return '/medicard-home';
      case '/guesthome':
      case '/guest-home':
      case '/onboarding':
        return '/guest-home';
      case '/login':
      case '/medicard-login':
        return '/medicard-login';
      case '/register':
      case '/medicard-register':
        return '/medicard-register';
      default:
        return normalized;
    }
  }

  static GoRouter createRouter(String initialLocation) {
    final router = GoRouter(
      navigatorKey: toastNavigatorKey,
      observers: [_LocationObserver()],
      initialLocation: normalizeLocation(initialLocation),
      // Rebuilds all route pages when the language changes so that every
      // `.tr()` / `context.tr()` re-evaluates against the new locale.
      refreshListenable: sl<AppRefreshCubit>().languageRefresh,
      onException: (context, state, router) {
        final fallbackLocation = normalizeLocation(state.uri.toString());
        router.go(
          fallbackLocation == state.uri.toString()
              ? '/guest-home'
              : fallbackLocation,
        );
      },
      routes: [
        GoRoute(path: '/', redirect: (context, state) => '/guest-home'),
        GoRoute(path: '/Home', redirect: (context, state) => '/medicard-home'),
        GoRoute(path: '/home', redirect: (context, state) => '/medicard-home'),
        GoRoute(
          path: '/medicard-login',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<MedicardLoginCubit>(),
              child: const MediCardLoginScreen(),
            );
          },
        ),
        GoRoute(
          path: '/medicard-register',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<RegisterCubit>(),
              child: const RegisterScreen(),
            );
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<ForgotPasswordCubit>(),
              child: const ForgotPasswordScreen(),
            );
          },
        ),
        GoRoute(
          path: '/forgot-password/verify',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider(
              create: (_) => sl<ForgotPasswordCubit>(),
              child: OtpVerificationScreen(
                phoneNumber: extra['phoneNumber'] as String,
                otp: extra['otp'] as String,
              ),
            );
          },
        ),
        GoRoute(
          path: '/forgot-password/reset',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return BlocProvider(
              create: (_) => sl<ForgotPasswordCubit>(),
              child: ResetPasswordScreen(
                phoneNumber: extra['phoneNumber'] as String,
                token: extra['token'] as String,
              ),
            );
          },
        ),
        GoRoute(
          path: '/onboarding',
          redirect: (context, state) => '/guest-home',
        ),
        GoRoute(
          path: '/medicard-activation',
          builder: (context, state) => const ActivateCardScreen(),
        ),
        GoRoute(
          path: '/guest-home',
          builder: (context, state) => const GuestHomeScreen(),
        ),
        GoRoute(
          path: '/medicard-home',
          builder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            return HomeScreen(
              initialIndex: switch (tab) {
                'activity' => 1,
                'profile' => 2,
                _ => 0,
              },
            );
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<NotificationCubit>()..init(),
              child: const NotificationsScreen(),
            );
          },
        ),

        GoRoute(
          path: '/medicard-profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/medicard-edit-profile-new',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final profileData = extra['profileData'] as ProfileData;
            final profileCubit = extra['profileCubit'] as ProfileCubit?;
            if (profileCubit == null) {
              return BlocProvider(
                create: (_) => sl<ProfileCubit>(),
                child: EditProfileScreen(profileData: profileData),
              );
            }
            return BlocProvider.value(
              value: profileCubit,
              child: EditProfileScreen(profileData: profileData),
            );
          },
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<ChangePasswordCubit>(),
              child: const ChangePasswordScreen(),
            );
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final lat = extra?['userLatitude'] as double?;
            final lng = extra?['userLongitude'] as double?;
            final categoryId = extra?['categoryId'] as int?;
            final initialTabIndex = extra?['initialTabIndex'] as int? ?? 0;
            final enableCartFeatures =
                extra?['enableCartFeatures'] as bool? ?? true;
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<SearchCubit>()),
                BlocProvider(create: (_) => sl<FilterCubit>()),
              ],
              child: SearchScreen(
                userLatitude: lat,
                userLongitude: lng,
                categoryId: categoryId,
                initialTabIndex: initialTabIndex,
                enableCartFeatures: enableCartFeatures,
              ),
            );
          },
        ),
        GoRoute(
          path: '/search/providers',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final lat = extra?['userLatitude'] as double?;
            final lng = extra?['userLongitude'] as double?;
            final categoryId = extra?['categoryId'] as int?;
            final enableCartFeatures =
                extra?['enableCartFeatures'] as bool? ?? true;
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<SearchCubit>()),
                BlocProvider(create: (_) => sl<FilterCubit>()),
              ],
              child: SearchScreen(
                userLatitude: lat,
                userLongitude: lng,
                categoryId: categoryId,
                initialTabIndex: 0,
                enableCartFeatures: enableCartFeatures,
              ),
            );
          },
        ),
        GoRoute(
          path: '/search/services',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final lat = extra?['userLatitude'] as double?;
            final lng = extra?['userLongitude'] as double?;
            final categoryId = extra?['categoryId'] as int?;
            final enableCartFeatures =
                extra?['enableCartFeatures'] as bool? ?? true;
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<SearchCubit>()),
                BlocProvider(create: (_) => sl<FilterCubit>()),
              ],
              child: SearchScreen(
                userLatitude: lat,
                userLongitude: lng,
                categoryId: categoryId,
                initialTabIndex: 1,
                enableCartFeatures: enableCartFeatures,
              ),
            );
          },
        ),
        GoRoute(
          path: '/packages',
          builder: (context, state) => const AllPackagesScreen(),
        ),
        GoRoute(
          path: '/help-center',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/privacy-policy',
          builder: (context, state) {
            return BlocProvider(
              create: (_) =>
                  sl<ContentCubit>()..loadContent(ContentType.privacyPolicy),
              child: const ContentScreen(
                contentType: ContentType.privacyPolicy,
              ),
            );
          },
        ),
        GoRoute(
          path: '/refund-policy',
          builder: (context, state) {
            return BlocProvider(
              create: (_) =>
                  sl<ContentCubit>()..loadContent(ContentType.refundPolicy),
              child: const ContentScreen(contentType: ContentType.refundPolicy),
            );
          },
        ),
        GoRoute(
          path: '/terms-and-conditions',
          builder: (context, state) {
            return BlocProvider(
              create: (_) =>
                  sl<ContentCubit>()
                    ..loadContent(ContentType.termsAndConditions),
              child: const ContentScreen(
                contentType: ContentType.termsAndConditions,
              ),
            );
          },
        ),
        GoRoute(
          path: '/family-members',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<FamilyMembersCubit>(),
              child: const FamilyMembersListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/family-members/add',
          builder: (context, state) {
            final cubit = state.extra as FamilyMembersCubit?;
            if (cubit == null) {
              return BlocProvider(
                create: (_) => sl<FamilyMembersCubit>(),
                child: const AddEditFamilyMemberScreen(),
              );
            }
            return BlocProvider.value(
              value: cubit,
              child: const AddEditFamilyMemberScreen(),
            );
          },
        ),
        GoRoute(
          path: '/family-members/edit',
          builder: (context, state) {
            final extra = state.extra;
            final member = extra is Map<String, dynamic>
                ? extra['member'] as FamilyMemberModel
                : extra as FamilyMemberModel;
            final cubit = extra is Map<String, dynamic>
                ? extra['cubit'] as FamilyMembersCubit?
                : null;
            if (cubit == null) {
              return BlocProvider(
                create: (_) => sl<FamilyMembersCubit>(),
                child: AddEditFamilyMemberScreen(member: member),
              );
            }
            return BlocProvider.value(
              value: cubit,
              child: AddEditFamilyMemberScreen(member: member),
            );
          },
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<AddressesCubit>(),
              child: const AddressesListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/digital-membership',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<ECardCubit>(),
              child: const DigitalMembershipScreen(),
            );
          },
        ),
        GoRoute(
          path: '/addresses/add',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => sl<AddressFormCubit>(),
              child: const AddEditAddressScreen(),
            );
          },
        ),
        GoRoute(
          path: '/addresses/edit',
          builder: (context, state) {
            final address = state.extra as UserAddressModel?;
            return BlocProvider(
              create: (_) => sl<AddressFormCubit>(),
              child: AddEditAddressScreen(address: address),
            );
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final providerId = extra?['providerId'] as int?;
            final selectedBranch = extra?['selectedBranch'] as ProviderBranch?;
            return BlocProvider(
              create: (_) => sl<CartCubit>(param1: providerId),
              child: CartScreen(
                initialProviderId: providerId,
                initialBranch: selectedBranch,
              ),
            );
          },
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) {
            if (state.extra is Map<String, dynamic>) {
              final extra = state.extra as Map<String, dynamic>;
              final cubit = extra['cubit'] as CartCubit?;
              final providerId = extra['providerId'] as int?;
              final providerName = extra['providerName'] as String?;
              final selectedBranch = extra['selectedBranch'] as ProviderBranch?;
              final packageId = extra['packageId'] as int?;
              final packageName = extra['packageName'] as String?;
              final packageServiceNames =
                  (extra['packageServiceNames'] as List?)
                      ?.whereType<String>()
                      .toList() ??
                  const <String>[];
              final packagePriceBefore = (extra['packagePriceBefore'] as num?)
                  ?.toDouble();
              final packagePriceAfter = (extra['packagePriceAfter'] as num?)
                  ?.toDouble();
              if (cubit != null) {
                return BlocProvider.value(
                  value: cubit,
                  child: CheckoutScreen(
                    initialProviderId: providerId,
                    initialProviderName: providerName,
                    initialBranch: selectedBranch,
                    packageId: packageId,
                    packageName: packageName,
                    packageServiceNames: packageServiceNames,
                    packagePriceBefore: packagePriceBefore,
                    packagePriceAfter: packagePriceAfter,
                  ),
                );
              }
              return BlocProvider(
                create: (_) => sl<CartCubit>(param1: providerId),
                child: CheckoutScreen(
                  initialProviderId: providerId,
                  initialProviderName: providerName,
                  initialBranch: selectedBranch,
                  packageId: packageId,
                  packageName: packageName,
                  packageServiceNames: packageServiceNames,
                  packagePriceBefore: packagePriceBefore,
                  packagePriceAfter: packagePriceAfter,
                ),
              );
            }

            return BlocProvider(
              create: (_) => sl<CartCubit>(),
              child: const CheckoutScreen(),
            );
          },
        ),
        GoRoute(
          path: '/invoice-details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final invoice = extra['invoice'] as InvoiceItem;
            final tab = extra['tab'] as int? ?? 0;
            return InvoiceDetailsScreen(invoice: invoice, tab: tab);
          },
        ),
        GoRoute(
          path: '/choose-provider',
          builder: (context, state) {
            // The CartCubit instance is passed as extra so both screens
            // share the same state. We fall back to creating a new one
            // if extra is absent (e.g. deep-link / dev navigation).
            if (state.extra is CartCubit) {
              return BlocProvider.value(
                value: state.extra as CartCubit,
                child: const ChooseProviderScreen(returnToPreviousCart: true),
              );
            }

            return BlocProvider(
              create: (_) => sl<CartCubit>()..loadCartAndProviders(),
              child: const ChooseProviderScreen(),
            );
          },
        ),
        GoRoute(
          path: '/pending-appointment-details',
          builder: (context, state) {
            final appointment = state.extra as AppointmentModel;
            return PendingAppointmentDetailsScreen(appointment: appointment);
          },
        ),
        GoRoute(
          path: '/provider-page',
          builder: (context, state) {
            // int (legacy callers) or {providerId, autoOpenPackageId?} for
            // notification deep-links that should open a package sheet.
            // Raw Map check: literals infer as Map<String, Object?>/int,
            // which fail a parameterized Map<String, dynamic> check.
            final extra = state.extra;
            if (extra is Map) {
              final providerId = extra['providerId'] as int;
              return ProviderPageScreen(
                providerId: providerId,
                autoOpenPackageId: extra['autoOpenPackageId'] as int?,
              );
            }
            final providerId = extra as int;
            return ProviderPageScreen(providerId: providerId);
          },
        ),
        GoRoute(
          path: '/provider-branches',
          builder: (context, state) {
            final extra = state.extra;
            // Raw Map check (not Map<String, dynamic>): map literals infer
            // as Map<String, Object?>, which fails the parameterized check.
            if (extra is Map) {
              final branches = extra['branches'];
              return BranchesScreen(
                branches: branches is List
                    ? branches.whereType<ProviderBranch>().toList()
                    : const <ProviderBranch>[],
                providerName: extra['providerName'] as String?,
              );
            }
            return BranchesScreen(
              branches: extra is List
                  ? extra.whereType<ProviderBranch>().toList()
                  : const <ProviderBranch>[],
            );
          },
        ),
        GoRoute(
          path: '/provider-reviews',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map) {
              final cubit = extra['cubit'] as ProviderPageCubit?;
              final providerId = (extra['providerId'] as num?)?.toInt() ?? 0;
              final providerName = extra['providerName'] as String?;
              if (cubit != null) {
                return BlocProvider.value(
                  value: cubit,
                  child: ReviewsScreen(
                    providerId: providerId,
                    providerName: providerName,
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    current = router;
    return router;
  }
}

/// Reports the top route path to [AppRouter.currentLocation] on every
/// navigation event so app-wide overlays can react to the current screen.
class _LocationObserver extends NavigatorObserver {
  void _update() {
    final pages = navigator?.widget.pages;
    final name = (pages != null && pages.isNotEmpty)
        ? (pages.last.name ?? '')
        : '';
    if (AppRouter.currentLocation.value != name) {
      AppRouter.currentLocation.value = name;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _update();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _update();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update();
}
