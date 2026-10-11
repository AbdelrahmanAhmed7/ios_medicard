import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import 'activity/activity_error_view.dart';
import 'activity/invoice_list.dart';

import '../../../../core/theming/app_text_styles.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    if (!_tabController.indexIsChanging || !mounted) return;
    final tab = _tabController.index + 1;
    context.read<ActivityCubit>().loadInvoices(tab: tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
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
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'activity.invoices_subtitle'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
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
                        color: Colors.white,
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
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
                            color: isSelected
                                ? kAuthBlue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? kAuthBlue
                                  : const Color(0xFFE5E7EB),
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
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
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
            child: BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: kAuthBlue),
                  ),
                  failure: (error) => ActivityErrorView(
                    error: error,
                    onRetry: () => context
                        .read<ActivityCubit>()
                        .loadInvoices(tab: _tabController.index + 1),
                  ),
                  success: (invoices, isLoadingMore, hasMore) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        TabScope(
                          tab: 1,
                          child: InvoiceList(
                            key: const ValueKey('pending'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_pending_title',
                            emptyMessageKey: 'activity.empty_pending_message',
                            emptyIcon: Icons.event_available_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        TabScope(
                          tab: 2,
                          child: InvoiceList(
                            key: const ValueKey('paid'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_paid_title',
                            emptyMessageKey: 'activity.empty_paid_message',
                            emptyIcon: Icons.account_balance_wallet_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        TabScope(
                          tab: 3,
                          child: InvoiceList(
                            key: const ValueKey('used'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_used_title',
                            emptyMessageKey: 'activity.empty_used_message',
                            emptyIcon: Icons.receipt_long_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        TabScope(
                          tab: 4,
                          child: InvoiceList(
                            key: const ValueKey('cancelled'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_cancelled_title',
                            emptyMessageKey: 'activity.empty_cancelled_message',
                            emptyIcon: Icons.cancel_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
