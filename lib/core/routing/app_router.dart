import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/activate_card/presentation/pages/activate_card_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/notifications/presentation/cubit/notifivation_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/profile/data/models/profile_response_model.dart';
import '../../features/profile/presentation/cubit/change_password_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/change_password_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/search/presentation/cubit/filter_cubit.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../medicard_network/logic/medicard_network_cubit.dart';
import '../../medicard_network/presentation/medicard_network_screen.dart';
import '../../presentation/logic/medicard_home_cubit.dart';
import '../../presentation/logic/medicard_login_cubit.dart';
import '../../presentation/logic/medicard_support_cubit.dart';
import '../../presentation/medicard_login_screen.dart';
import '../../presentation/medicard_my_card_screen.dart';
import '../../presentation/medicard_onboarding_screen.dart';
import '../../presentation/medicard_selection_screen.dart';
import '../../presentation/medicard_support_screen.dart';
import '../../presentation/register_screen.dart';
import '../../presentation/logic/register_cubit.dart';
import '../constants/constants.dart';
import '../di/service_locator.dart';
import '../helpers/shared_pref_helper.dart';
import '../theming/app_toast.dart';

class AppRouter {
  static Future<String> getInitialLocation() async {
    try {
      // Check for existing auth token first — skip login if still logged in
      final token = await SharedPrefHelper.getSecuredString(
        SharedPrefKeys.userToken,
      );
      if (token.isNotEmpty) {
        return '/medicard-home';
      }

      final hasSeenOnboarding = await SharedPrefHelper.getBool(
        SharedPrefKeys.hasSeenOnboarding,
      );

      if (!hasSeenOnboarding) {
        return '/onboarding';
      }

      return '/medicard-login';
    } catch (e) {
      // Fallback — never leave the user on a blank splash
      if (kDebugMode) debugPrint('AppRouter.getInitialLocation error: $e');
      return '/medicard-login';
    }
  }

  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      navigatorKey: toastNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const MedicardOnboardingScreen(),
        ),
        GoRoute(
          path: '/medicard',
          builder: (context, state) => const MedicardSelectionScreen(),
        ),
        GoRoute(
          path: '/medicard-activation',
          builder: (context, state) => const ActivateCardScreen(),
        ),
        GoRoute(
          path: '/medicard-login',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<MedicardLoginCubit>(),
              child: const MediCardLoginScreen(),
            );
          },
        ),
        GoRoute(
          path: '/medicard-register',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<RegisterCubit>(),
              child: const RegisterScreen(),
            );
          },
        ),
        GoRoute(
          path: '/medicard-home',
          builder: (context, state) => const HomeScreen(),
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
          path: '/medicard-my-card',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final personalData = extra?['personalData'];
            final cardNo = extra?['cardNo'] as String?;
            if (personalData == null || cardNo == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid parameters')),
              );
            }
            return BlocProvider(
              create: (context) => sl<MedicardHomeCubit>(),
              child: MedicardMyCardScreen(
                personalData: personalData,
                cardNo: cardNo,
              ),
            );
          },
        ),
        GoRoute(
          path: '/medicard-network',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final searchQuery = extra?['searchQuery'] as String?;
            return BlocProvider(
              create: (context) => sl<MedicardNetworkCubit>(),
              child: MedicardNetworkScreen(initialSearchQuery: searchQuery),
            );
          },
        ),
        GoRoute(
          path: '/medicard-support',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<MedicardSupportCubit>(),
              child: const MediCardSupportScreen(),
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
            return BlocProvider(
              create: (_) => sl<ProfileCubit>(),
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
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<SearchCubit>()),
                BlocProvider(create: (_) => sl<FilterCubit>()),
              ],
              child: SearchScreen(
                userLatitude: lat,
                userLongitude: lng,
                categoryId: categoryId,
              ),
            );
          },
        ),
      ],
    );
  }
}
