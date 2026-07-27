import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medicard/features/home/data/home_mock_data.dart';

import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/theming/app_snack_bar.dart';
import '../../../../features/activity/presentation/cubit/activity_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_state.dart';
import '../../../../features/profile/presentation/widgets/profile_content.dart';
import '../../../../features/profile/presentation/widgets/profile_error_view.dart';
import '../../../../features/profile/presentation/widgets/profile_shimmer.dart';
import '../../data/models/home_response_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../cubit/location_cubit.dart';
import '../mappers/home_mappers.dart';
import '../widgets/activity_screen.dart';
import '../widgets/ecard_screen.dart';
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
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => sl<HomeCubit>()..getHomeData(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) {
            if (kDebugMode) {
              debugPrint('[ProfileFlow] ProfileCubit created for HomeScreen');
            }
            return sl<ProfileCubit>();
          },
        ),
        BlocProvider<LocationCubit>(
          create: (context) => sl<LocationCubit>()..loadLocation(),
        ),
        BlocProvider<ActivityCubit>(
          create: (context) => sl<ActivityCubit>()..loadInvoices(),
        ),
        BlocProvider<AppRefreshCubit>.value(value: sl<AppRefreshCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppRefreshCubit, AppRefreshState>(
            listener: (context, state) {
              state.maybeWhen(
                languageChanged: () {
                  context.read<HomeCubit>().getHomeData();
                  if (_currentIndex == 3) {
                    context.read<ProfileCubit>().loadProfile(
                      forceRefresh: true,
                    );
                  }
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop || _currentIndex == 0) return;
            setState(() => _currentIndex = 0);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                _HomeBody(),
                ECardScreen(),
                ActivityScreen(),
                _ProfileBody(),
              ],
            ),
            bottomNavigationBar: Builder(
              builder: (providerContext) => HomeBottomNav(
                currentIndex: _currentIndex,
                onTap: (i) {
                  if (i == 3) {
                    if (kDebugMode) {
                      debugPrint('[ProfileFlow] Profile tab opened');
                    }
                    providerContext.read<ProfileCubit>().loadProfile();
                  }
                  if (i != _currentIndex) setState(() => _currentIndex = i);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        state.maybeWhen(
          refreshFailed: (_, _) => showAppSnackBar(
            context,
            'home.refresh_failed'.tr(),
            type: SnackBarType.error,
            actionLabel: 'common.retry'.tr(),
            onAction: () =>
                context.read<HomeCubit>().getHomeData(refresh: true),
          ),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildShellScrollView(
            slivers: [const SliverToBoxAdapter(child: HomeShimmer())],
          ),
          loading: () => _buildShellScrollView(
            slivers: [const SliverToBoxAdapter(child: HomeShimmer())],
          ),
          success: (data) => _buildLoadedView(context, data),
          failed: (failure, isRetrying) => _buildShellScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeErrorView(
                  failure: failure,
                  isRetrying: isRetrying,
                  onRetry: () => context.read<HomeCubit>().getHomeData(),
                ),
              ),
            ],
          ),
          refreshing: (data) =>
              _buildLoadedView(context, data, isRefreshing: true),
          refreshFailed: (data, _) => _buildLoadedView(context, data),
        );
      },
    );
  }

  Widget _buildLoadedView(
    BuildContext context,
    HomeResponseModel data, {
    bool isRefreshing = false,
  }) {
    final appointments = mapAppointments(data.data?.pendingAppointments ?? []);
    final providers = mapProviders(data.data?.nearestProviders ?? []);
    final banners = mapPromoBanners(data.data?.sliders ?? []);
    final services = mapPackages(data.data?.packages ?? []);

    final hasContent =
        appointments.isNotEmpty ||
        providers.isNotEmpty ||
        services.isNotEmpty ||
        banners.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().getHomeData(refresh: true),
      backgroundColor: Colors.white,
      child: _buildShellScrollView(
        banners: banners,
        isRefreshing: isRefreshing,
        slivers: [
          if (!hasContent)
            const SliverToBoxAdapter(child: HomeEmptyView())
          else ...[
            if (appointments.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: PendingAppointmentsSection(appointments: appointments),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            if (providers.isNotEmpty) ...[
              SliverToBoxAdapter(child: NearestSection(providers: providers)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            if (services.isNotEmpty)
              SliverToBoxAdapter(
                child: FeaturedServicesSection(services: services),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildShellScrollView({
    required List<Widget> slivers,
    List<PromoBanner> banners = const [],
    bool isRefreshing = false,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        if (isRefreshing)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        SliverToBoxAdapter(
          child: QuickActionsRow(actions: HomeMockData.quickActions),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        if (banners.isNotEmpty) ...[
          SliverToBoxAdapter(child: PromoBannerWidget(banners: banners)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],

        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

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
