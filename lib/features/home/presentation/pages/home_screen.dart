import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/utils/location_permission_dialog.dart';

import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_state.dart';
import '../../../../features/profile/presentation/widgets/profile_content.dart';
import '../../../../features/profile/presentation/widgets/profile_error_view.dart';
import '../../../../features/profile/presentation/widgets/profile_shimmer.dart';
import '../../data/home_mock_data.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/models/featured_service_model.dart';
import '../../domain/models/provider_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../cubit/location_cubit.dart';
import '../mappers/home_mappers.dart';
import '../widgets/featured_services_section.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_header.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/nearest_section.dart';
import '../widgets/pending_appointments_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/quick_actions_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit = sl<HomeCubit>()..getHomeData();
  late final ProfileCubit _profileCubit = sl<ProfileCubit>()..loadProfile();
  late final LocationCubit _locationCubit = sl<LocationCubit>()..loadLocation();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set the onShowRationaleDialog callback
    _locationCubit.onShowRationaleDialog = (completer) {
      LocationPermissionDialog.show(
        context,
        onEnablePressed: () => completer.complete(true),
        onMaybeLaterPressed: () => completer.complete(false),
      );
    };
    // Listen to AppRefreshCubit to refresh data when language changes
    sl<AppRefreshCubit>().stream.listen((state) {
      state.maybeWhen(
        languageChanged: () {
          _homeCubit.getHomeData();
          _profileCubit.loadProfile();
        },
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    // Clear the callback to prevent memory leaks
    _locationCubit.onShowRationaleDialog = null;
    _homeCubit.close();
    _profileCubit.close();
    _locationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: _homeCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        BlocProvider<LocationCubit>.value(value: _locationCubit),
        BlocProvider<AppRefreshCubit>.value(value: sl<AppRefreshCubit>()),
      ],
      child: BlocBuilder<AppRefreshCubit, AppRefreshState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                _HomeBody(),
                Center(child: Text('E-card')),
                Center(child: Text('Providers')),
                _ProfileBody(),
              ],
            ),
            bottomNavigationBar: HomeBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — listens to HomeCubit and delegates to the right view
// ─────────────────────────────────────────────────────────────────────────────

/// Stateless body that rebuilds only when [HomeState] changes.
/// All mapping logic lives in [home_mappers.dart], not here.
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),

          loading: () => _buildShellScrollView(child: const HomeShimmer()),

          success: (data) {
            final appointments = mapAppointments(
              data.data?.pendingAppointments ?? [],
            );
            final providers = mapProviders(data.data?.nearestProviders ?? []);
            final banners = mapPromoBanners(data.data?.sliders ?? []);
            final services = mapPackages(data.data?.packages ?? []);

            final hasContent =
                appointments.isNotEmpty ||
                providers.isNotEmpty ||
                services.isNotEmpty ||
                banners.isNotEmpty;

            return _buildShellScrollView(
              banners: banners,
              child: hasContent
                  ? _HomeSuccessContent(
                      appointments: appointments,
                      providers: providers,
                      services: services,
                    )
                  : const HomeEmptyView(),
            );
          },

          failed: (error) => _buildShellScrollView(
            child: HomeErrorView(
              message: error,
              onRetry: () => context.read<HomeCubit>().getHomeData(),
            ),
          ),
        );
      },
    );
  }

  /// Builds the shared sliver shell (header + quick actions + optional banner)
  /// and places [child] below inside a [SliverToBoxAdapter].
  Widget _buildShellScrollView({
    required Widget child,
    List<PromoBanner> banners = const [],
  }) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(
          child: QuickActionsRow(actions: HomeMockData.quickActions),
        ),
        if (banners.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: PromoBannerWidget(banners: banners),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
        SliverToBoxAdapter(child: child),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Body
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.maybeWhen(
          failed: (error) => showErrorToast(error),
          updated: (data) {},
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const ProfileShimmer(),
          success: (data) => ProfileContent(data: data),
          updating: (data) => ProfileContent(data: data),
          updated: (data) => ProfileContent(data: data),
          failed: (_) => const ProfileErrorView(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success content — purely presentational, receives mapped domain models
// ─────────────────────────────────────────────────────────────────────────────

class _HomeSuccessContent extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final List<ProviderModel> providers;
  final List<FeaturedServiceModel> services;

  const _HomeSuccessContent({
    required this.appointments,
    required this.providers,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appointments.isNotEmpty) ...[
          PendingAppointmentsSection(appointments: appointments),
          const SizedBox(height: 24),
        ],
        if (providers.isNotEmpty) ...[
          NearestSection(providers: providers),
          const SizedBox(height: 24),
        ],
        if (services.isNotEmpty) FeaturedServicesSection(services: services),
      ],
    );
  }
}
