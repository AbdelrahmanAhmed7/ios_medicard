import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/features/home/data/home_mock_data.dart';
import 'package:medicard/features/home/domain/models/appointment_model.dart';
import 'package:medicard/features/home/domain/models/featured_service_model.dart';
import 'package:medicard/features/home/domain/models/provider_model.dart';

import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_snack_bar.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../features/activity/presentation/cubit/activity_cubit.dart';
import '../../../../features/ecard/presentation/cubit/ecard_cubit.dart';
import '../../../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../../features/profile/presentation/cubit/profile_state.dart';
import '../../../../features/profile/presentation/widgets/profile_content.dart';
import '../../../../features/profile/presentation/widgets/profile_error_view.dart';
import '../../../../features/profile/presentation/widgets/profile_shimmer.dart';
import '../../data/models/home_response_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import '../mappers/home_mappers.dart';
import '../widgets/activity_screen.dart';
import '../widgets/ecard_preview_card.dart';
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
import '../widgets/summer_promo_dialog.dart';

import 'package:medicard/core/theming/app_colors.dart';
class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late final Set<int> _visitedTabs;
  bool _locationLoadStarted = false;
  bool _homeLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _visitedTabs = {_currentIndex};
    // Show the summer promo popup on first frame if within the promo window.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SummerPromoDialog.maybeShow(context);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // GoRouter reuses this page when checkout returns with a different tab.
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
      _visitedTabs.add(_currentIndex);
    }
  }

  void _selectTab(int index) {
    _visitedTabs.add(index);
    if (index != _currentIndex) setState(() => _currentIndex = index);
    // Keep the URL in sync, including when leaving invoices manually. A later
    // "View invoices" action must be a new tab request, even on a reused page.
    context.go(switch (index) {
      1 => '/medicard-home?tab=activity',
      2 => '/medicard-home?tab=profile',
      _ => '/medicard-home',
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (context) => sl<HomeCubit>()),
        BlocProvider<ProfileCubit>(
          create: (context) {
            if (kDebugMode) {
              debugPrint('[ProfileFlow] ProfileCubit created for HomeScreen');
            }
            return sl<ProfileCubit>();
          },
        ),
        BlocProvider<LocationCubit>(create: (context) => sl<LocationCubit>()),
        BlocProvider<ActivityCubit>(create: (context) => sl<ActivityCubit>()),
        BlocProvider<ECardCubit>(create: (context) => sl<ECardCubit>()),
        BlocProvider<NotificationCubit>.value(value: sl<NotificationCubit>()),
        BlocProvider<AppRefreshCubit>.value(value: sl<AppRefreshCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppRefreshCubit, AppRefreshState>(
            listener: (context, state) {
              state.maybeWhen(
                languageChanged: () {
                  context.read<HomeCubit>().getHomeData();
                  context.read<ECardCubit>().loadCardData(forceRefresh: true);
                  context.read<ActivityCubit>().loadInvoices();
                  if (_currentIndex == 2) {
                    context.read<ProfileCubit>().loadProfile(
                      forceRefresh: true,
                    );
                  }
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationLoaded || state is LocationError) {
                final refresh = _homeLoadStarted;
                _homeLoadStarted = true;
                context.read<HomeCubit>().getHomeData(refresh: refresh);
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            final locationCubit = context.read<LocationCubit>();
            // Bypass the custom rationale popup: proceed straight to the
            // native OS permission dialog (Geolocator.requestPermission).
            locationCubit.onShowRationaleDialog = (completer) {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            };
            if (!_locationLoadStarted) {
              _locationLoadStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<LocationCubit>().loadLocation();
                }
              });
            }

            return PopScope(
              canPop: _currentIndex == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop || _currentIndex == 0) return;
                _selectTab(0);
              },
              child: Scaffold(
                backgroundColor: AppColors.whiteClr,
                body: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _HomeBody(onNavigateToTab: _selectTab),
                    // Lazy-loaded on first visit: avoids eagerly firing loadInvoices
                    // or building profile view at cold startup when opening home.
                    _visitedTabs.contains(1)
                        ? const ActivityScreen()
                        : const SizedBox.shrink(),
                    _visitedTabs.contains(2)
                        ? const _ProfileBody()
                        : const SizedBox.shrink(),
                  ],
                ),
                bottomNavigationBar: Builder(
                  builder: (providerContext) => HomeBottomNav(
                    currentIndex: _currentIndex,
                    onTap: (i) {
                      if (i == 2) {
                        if (kDebugMode) {
                          debugPrint('[ProfileFlow] Profile tab opened');
                        }
                        providerContext.read<ProfileCubit>().loadProfile();
                      }
                      _selectTab(i);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;

  const _HomeBody({required this.onNavigateToTab});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  HomeResponseModel? _lastData;
  List<AppointmentModel> _cachedAppointments = const [];
  List<ProviderModel> _cachedProviders = const [];
  List<PromoBanner> _cachedBanners = const [];
  List<FeaturedServiceModel> _cachedServices = const [];

  void _updateCacheIfNeeded(HomeResponseModel data) {
    if (identical(_lastData, data) || _lastData == data) return;
    _lastData = data;
    _cachedAppointments = mapAppointments(data.data?.pendingAppointments ?? []);
    _cachedProviders = mapProviders(data.data?.nearestProviders ?? []);
    _cachedBanners = mapPromoBanners(data.data?.sliders ?? []);
    _cachedServices = mapPackages(data.data?.packages ?? []);
  }

  void _openAllProviders(BuildContext context) {
    context.push('/search/providers', extra: {'enableCartFeatures': true});
  }

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
            showQuickActions: false,
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
    _updateCacheIfNeeded(data);
    final appointments = _cachedAppointments;
    final providers = _cachedProviders;
    final banners = _cachedBanners;
    final services = _cachedServices;

    final hasContent =
        appointments.isNotEmpty ||
        providers.isNotEmpty ||
        services.isNotEmpty ||
        banners.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().getHomeData(refresh: true),
      backgroundColor: AppColors.whiteClr,
      child: _buildShellScrollView(
        banners: banners,
        isRefreshing: isRefreshing,
        slivers: [
          if (!hasContent)
            const SliverToBoxAdapter(child: HomeEmptyView())
          else ...[
            if (appointments.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: PendingAppointmentsSection(
                  appointments: appointments,
                  onViewAll: () => widget.onNavigateToTab(1),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            if (providers.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: NearestSection(
                  providers: providers,
                  onViewAll: () => _openAllProviders(context),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            if (services.isNotEmpty)
              SliverToBoxAdapter(
                child: FeaturedServicesSection(
                  services: services,
                  onViewAll: () => context.push('/packages'),
                ),
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
    bool showQuickActions = true,
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        if (isRefreshing)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 6)),
        const SliverToBoxAdapter(child: ECardPreviewCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 6)),

        if (showQuickActions) ...[
          const SliverToBoxAdapter(
            child: QuickActionsRow(
              actions: HomeMockData.quickActions,
              verticalPadding: 8,
            ),
          ),
        ],

        if (banners.isNotEmpty) ...[
          SliverToBoxAdapter(child: PromoBannerWidget(banners: banners)),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],

        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  void initState() {
    super.initState();
    sl<AppRefreshCubit>().profileSummaryRefresh.addListener(
      _onProfileSummaryRefresh,
    );
  }

  void _onProfileSummaryRefresh() {
    if (!mounted) return;
    context.read<ProfileCubit>().refreshSummary();
  }

  @override
  void dispose() {
    sl<AppRefreshCubit>().profileSummaryRefresh.removeListener(
      _onProfileSummaryRefresh,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.maybeWhen(
          failed: (error) => showErrorToast(error),
          updated: (data, summary) {},
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const ProfileShimmer(),
          success: (data, summary) =>
              ProfileContent(data: data, summary: summary),
          updating: (data, summary) =>
              ProfileContent(data: data, summary: summary),
          updated: (data, summary) =>
              ProfileContent(data: data, summary: summary),
          failed: (error) => ProfileErrorView(error: error),
        );
      },
    );
  }
}

