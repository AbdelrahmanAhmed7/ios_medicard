import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import 'package:medicard/core/widgets/app_blue_header.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ActivityCubit>().loadInvoices(tab: 1);
      }
    });
  }

  @override
  void dispose() {
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
          AppBlueHeader(
            title: 'home.nav_activity'.tr(),
            showBack: false,
            contentHeight: kMainTabHeaderContentHeight,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: kAuthBlue,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: kAuthBlue,
            unselectedLabelColor: const Color(0xFF4B5563),
            labelStyle: AppTextStyles.of(fontSize: 14.sp, fontWeight: FontWeight.w500),
            unselectedLabelStyle: AppTextStyles.of(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: 'activity.pending'.tr()),
              Tab(text: 'activity.paid'.tr()),
              Tab(text: 'activity.used'.tr()),
              Tab(text: 'activity.cancelled'.tr()),
            ],
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
