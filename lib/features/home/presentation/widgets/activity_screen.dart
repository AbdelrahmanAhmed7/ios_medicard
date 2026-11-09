import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import 'activity/activity_error_view.dart';
import 'activity/invoice_list.dart';
import 'activity/invoices_shimmer.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _requestedTab = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    // A new invoice created on the checkout screen asks for a reload so it
    // shows up with no manual refresh or tab switching.
    sl<AppRefreshCubit>().invoicesRefresh.addListener(_onInvoicesRefresh);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ActivityCubit>().loadInvoices(tab: 1);
      }
    });
  }

  void _onInvoicesRefresh() {
    if (!mounted) return;
    context.read<ActivityCubit>().loadInvoices(
      tab: _tabController.index + 1,
      forceRefresh: true,
    );
  }

  @override
  void dispose() {
    sl<AppRefreshCubit>().invoicesRefresh.removeListener(_onInvoicesRefresh);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    final tab = _tabController.index + 1;
    // TabController.indexIsChanging is only true for animateTo (tab taps),
    // not for a user swiping the TabBarView. Dedupe by the selected tab so
    // both interactions trigger exactly one request.
    if (tab == _requestedTab) return;
    _requestedTab = tab;
    context.read<ActivityCubit>().loadInvoices(tab: tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteClr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                16.h,
                AppSpacing.pageHorizontal,
                4.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'home.nav_invoices'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkClr,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'activity.invoices_subtitle'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.exactFF6B7280,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => context.push(
                      '/search/services',
                      extra: const {'enableCartFeatures': true},
                    ),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: kAuthBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.whiteClr,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              const labels = [
                'activity.pending',
                'activity.paid',
                'activity.used',
                'activity.cancelled',
              ];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  12.h,
                  AppSpacing.pageHorizontal,
                  4.h,
                ),
                child: Row(
                  children: List.generate(labels.length, (i) {
                    final isSelected = _tabController.index == i;
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: i == labels.length - 1 ? 0 : 8.w,
                      ),
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(i),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 9.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? kAuthBlue : AppColors.whiteClr,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? kAuthBlue
                                  : AppColors.exactFFE5E7EB,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            labels[i].tr(),
                            style: AppTextStyles.of(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.whiteClr
                                  : AppColors.exactFF4B5563,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ActivityTabView(
                  tab: 1,
                  key: ValueKey('pending'),
                  emptyTitleKey: 'activity.empty_pending_title',
                  emptyMessageKey: 'activity.empty_pending_message',
                  emptyIcon: Icons.event_available_outlined,
                ),
                _ActivityTabView(
                  tab: 2,
                  key: ValueKey('paid'),
                  emptyTitleKey: 'activity.empty_paid_title',
                  emptyMessageKey: 'activity.empty_paid_message',
                  emptyIcon: Icons.account_balance_wallet_outlined,
                ),
                _ActivityTabView(
                  tab: 3,
                  key: ValueKey('used'),
                  emptyTitleKey: 'activity.empty_used_title',
                  emptyMessageKey: 'activity.empty_used_message',
                  emptyIcon: Icons.receipt_long_outlined,
                ),
                _ActivityTabView(
                  tab: 4,
                  key: ValueKey('cancelled'),
                  emptyTitleKey: 'activity.empty_cancelled_title',
                  emptyMessageKey: 'activity.empty_cancelled_message',
                  emptyIcon: Icons.cancel_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTabView extends StatefulWidget {
  final int tab;
  final String emptyTitleKey;
  final String emptyMessageKey;
  final IconData emptyIcon;

  const _ActivityTabView({
    super.key,
    required this.tab,
    required this.emptyTitleKey,
    required this.emptyMessageKey,
    required this.emptyIcon,
  });

  @override
  State<_ActivityTabView> createState() => _ActivityTabViewState();
}

class _ActivityTabViewState extends State<_ActivityTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ActivityCubit>();
      final tabData = _safeGetTabData(cubit, widget.tab, cubit.state);
      if (tabData.items == null && !tabData.isLoading) {
        cubit.loadInvoices(tab: widget.tab);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final cubit = context.read<ActivityCubit>();
        final tabData = _safeGetTabData(cubit, widget.tab, state);

        if (tabData.isLoading && tabData.items == null) {
          return const InvoicesShimmer();
        }

        if (tabData.error != null && tabData.items == null) {
          return ActivityErrorView(
            error: tabData.error!,
            onRetry: () => cubit.loadInvoices(
              tab: widget.tab,
              forceRefresh: true,
            ),
          );
        }

        final items = tabData.items ?? const [];
        return TabScope(
          tab: widget.tab,
          child: InvoiceList(
            items: items,
            emptyTitleKey: widget.emptyTitleKey,
            emptyMessageKey: widget.emptyMessageKey,
            emptyIcon: widget.emptyIcon,
            isLoadingMore: tabData.isLoadingMore,
            hasMore: tabData.hasMore,
          ),
        );
      },
    );
  }

  TabInvoicesData _safeGetTabData(
    ActivityCubit cubit,
    int tab,
    ActivityState state,
  ) {
    try {
      return cubit.getTabData(tab);
    } catch (_) {
      return state.maybeWhen(
        success: (inv, loadingMore, more) => TabInvoicesData(
          items: inv,
          isLoadingMore: loadingMore,
          hasMore: more,
        ),
        loading: () => const TabInvoicesData(isLoading: true),
        failure: (err) => TabInvoicesData(error: err),
        orElse: () => const TabInvoicesData(items: []),
      );
    }
  }
}

