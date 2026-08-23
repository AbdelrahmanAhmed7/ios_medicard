import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import 'package:medicard/core/widgets/app_blue_header.dart';
import '../../../activity/domain/models/invoice_item.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';

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
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            unselectedLabelStyle: TextStyle(
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
                  failure: (error) => _ErrorView(
                    error: error,
                    onRetry: () => context
                        .read<ActivityCubit>()
                        .loadInvoices(tab: _tabController.index + 1),
                  ),
                  success: (invoices, isLoadingMore, hasMore) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _TabScope(
                          tab: 1,
                          child: _InvoiceList(
                            key: const ValueKey('pending'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_pending_title',
                            emptyMessageKey: 'activity.empty_pending_message',
                            emptyIcon: Icons.event_available_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        _TabScope(
                          tab: 2,
                          child: _InvoiceList(
                            key: const ValueKey('paid'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_paid_title',
                            emptyMessageKey: 'activity.empty_paid_message',
                            emptyIcon: Icons.account_balance_wallet_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        _TabScope(
                          tab: 3,
                          child: _InvoiceList(
                            key: const ValueKey('used'),
                            items: invoices,
                            emptyTitleKey: 'activity.empty_used_title',
                            emptyMessageKey: 'activity.empty_used_message',
                            emptyIcon: Icons.receipt_long_outlined,
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                        _TabScope(
                          tab: 4,
                          child: _InvoiceList(
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

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: kAuthBlue),
              child: Text(
                'common.retry'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceList extends StatefulWidget {
  final List<InvoiceItem> items;
  final String emptyTitleKey;
  final String emptyMessageKey;
  final IconData emptyIcon;
  final bool isLoadingMore;
  final bool hasMore;

  const _InvoiceList({
    super.key,
    required this.items,
    required this.emptyTitleKey,
    required this.emptyMessageKey,
    required this.emptyIcon,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  State<_InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<_InvoiceList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _InvoiceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.hasMore != widget.hasMore ||
        oldWidget.isLoadingMore != widget.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrefetchMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<ActivityCubit>().loadMore();
    }
  }

  void _maybePrefetchMore() {
    if (!mounted || !widget.hasMore || widget.isLoadingMore) return;
    if (!_scrollController.hasClients) {
      if (widget.items.isEmpty) {
        context.read<ActivityCubit>().loadMore();
      }
      return;
    }
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<ActivityCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore && !widget.hasMore) {
      return _ActivityEmptyView(
        title: widget.emptyTitleKey.tr(),
        message: widget.emptyMessageKey.tr(),
        icon: widget.emptyIcon,
      );
    }

    if (widget.items.isEmpty && (widget.isLoadingMore || widget.hasMore)) {
      return const Center(
        child: CircularProgressIndicator(color: kAuthBlue),
      );
    }

    final itemCount =
        widget.items.length + (widget.isLoadingMore || widget.hasMore ? 1 : 0);

    return RefreshIndicator(
      color: kAuthBlue,
      onRefresh: () => context
          .read<ActivityCubit>()
          .loadInvoices(tab: _TabScope.of(context)),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: widget.isLoadingMore
                    ? const CircularProgressIndicator(color: kAuthBlue)
                    : const SizedBox.shrink(),
              ),
            );
          }
          return _InvoiceCard(item: widget.items[index]);
        },
      ),
    );
  }
}

class _TabScope extends InheritedWidget {
  final int tab;
  const _TabScope({required this.tab, required super.child});

  static int of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TabScope>()!.tab;
  }

  @override
  bool updateShouldNotify(_TabScope oldWidget) => tab != oldWidget.tab;
}

class _ActivityEmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _ActivityEmptyView({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD8E8FA)),
              ),
              child: Icon(icon, size: 34.r, color: kAuthBlue),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.45,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceItem item;

  const _InvoiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.date);
    const baseImageUrl =
        'https://medicard-api-v2.medicardeg.com/uploads/providers/';
    final imageUrl =
        (item.providerImageUrl != null && item.providerImageUrl!.isNotEmpty)
        ? '$baseImageUrl${item.providerImageUrl}'
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () async {
        final tab = _TabScope.of(context);
        final result = await context.push('/invoice-details', extra: {'invoice': item, 'tab': tab});
        if (result == true && context.mounted) {
          context.read<ActivityCubit>().loadInvoices(tab: tab, forceRefresh: true);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56.r,
              height: 56.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  Container(color: Colors.grey[100]),
                              errorWidget: (_, _, _) => _providerInitial(),
                            )
                          : _providerInitial(),
                    ),
                  ),
                  if (item.isUsed)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 11.r,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.providerName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.branchName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.beneficiaryName != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14.r,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            item.beneficiaryName!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      _InvoiceActionButton(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerInitial() {
    return CircleAvatar(
      backgroundColor: Colors.grey[100],
      child: const Icon(Icons.local_hospital, color: kAuthBlue),
    );
  }
}

class _InvoiceActionButton extends StatelessWidget {
  final InvoiceItem item;

  const _InvoiceActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final tab = _TabScope.of(context);
        final result = await context.push('/invoice-details', extra: {'invoice': item, 'tab': tab});
        if (result == true && context.mounted) {
          context.read<ActivityCubit>().loadInvoices(tab: tab, forceRefresh: true);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 16.r, color: kAuthBlue),
          SizedBox(width: 4.w),
          Text(
            'activity.details'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: kAuthBlue,
              decoration: TextDecoration.underline,
              decorationColor: kAuthBlue,
            ),
          ),
        ],
      ),
    );
  }
}
