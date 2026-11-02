import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../features/home/presentation/widgets/featured_services_section.dart';
import '../../../../features/home/presentation/widgets/home_error_view.dart';
import '../../../../features/home/presentation/widgets/home_shimmer.dart';
import '../../../../features/home/presentation/widgets/nearest_section.dart';
import '../../../../features/home/presentation/widgets/promo_banner.dart';
import '../../../../features/home/presentation/widgets/quick_actions_row.dart';
import '../../../../features/home/data/home_mock_data.dart';
import '../../../home/domain/models/featured_service_model.dart';
import '../../../home/domain/models/provider_model.dart';
import '../cubit/guest_home_cubit.dart';
import '../cubit/guest_home_state.dart';
import '../mappers/guest_home_mappers.dart';

import '../../../../core/theming/app_text_styles.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  late final GuestHomeCubit _guestHomeCubit = sl<GuestHomeCubit>()
    ..getGuestHomeData();

  @override
  void initState() {
    super.initState();
    sl<AppRefreshCubit>().stream.listen((state) {
      state.maybeWhen(
        languageChanged: () {
          _guestHomeCubit.getGuestHomeData();
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GuestHomeCubit>.value(
      value: _guestHomeCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<GuestHomeCubit, GuestHomeState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => _buildShellScrollView(
                child: const HomeShimmer(showAppointments: false),
              ),
              success: (data) {
                final providers = mapGuestProviders(
                  data.data?.nearestProviders ?? [],
                );
                final banners = mapGuestPromoBanners(data.data?.sliders ?? []);
                final packages = mapGuestPackages(data.data?.packages ?? []);

                final hasContent =
                    providers.isNotEmpty ||
                    packages.isNotEmpty ||
                    banners.isNotEmpty;

                return _buildShellScrollView(
                  banners: banners,
                  child: hasContent
                      ? _GuestHomeSuccessContent(
                          providers: providers,
                          packages: packages,
                        )
                      : const SizedBox(),
                );
              },
              failed: (error) => _buildShellScrollView(
                child: HomeErrorView(
                  message: error,
                  onRetry: () =>
                      context.read<GuestHomeCubit>().getGuestHomeData(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShellScrollView({
    required Widget child,
    List<PromoBanner> banners = const [],
  }) {
    return RefreshIndicator(
      onRefresh: _guestHomeCubit.getGuestHomeData,
      backgroundColor: Colors.white,
      color: const Color(0xFF3872B1),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _GuestHomeHeader()),
          const SliverToBoxAdapter(
            child: QuickActionsRow(actions: HomeMockData.guestQuickActions),
          ),
          if (banners.isNotEmpty) ...[
            SliverToBoxAdapter(child: PromoBannerWidget(banners: banners)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
          SliverToBoxAdapter(child: child),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _GuestHomeHeader extends StatelessWidget {
  const _GuestHomeHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEF1F5))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: kAuthBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'guest_home.welcome_title'.tr(),
                      style: AppTextStyles.of(
                        color: kAuthInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'guest_home.explore_health_services'.tr(),
                      style: AppTextStyles.of(
                        color: kAuthGreyText,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () => context.go('/medicard-login'),
                style: TextButton.styleFrom(
                  foregroundColor: kAuthBlue,
                  backgroundColor: const Color(0xFFEFF6FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.login_rounded, size: 17),
                label: Text(
                  'auth.login.loginButton'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestHomeSuccessContent extends StatelessWidget {
  final List<ProviderModel> providers;
  final List<FeaturedServiceModel> packages;

  const _GuestHomeSuccessContent({
    required this.providers,
    required this.packages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (providers.isNotEmpty) ...[
          NearestSection(
            providers: providers,
            onViewAll: () {
              context.push(
                '/search/providers',
                extra: {'enableCartFeatures': false},
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        if (packages.isNotEmpty)
          FeaturedServicesSection(
            services: packages,
            onViewAll: () => context.push('/packages'),
          ),
      ],
    );
  }
}
