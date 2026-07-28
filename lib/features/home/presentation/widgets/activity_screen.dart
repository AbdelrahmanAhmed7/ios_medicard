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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            unselectedLabelStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: 'activity.pending'.tr()),
              Tab(text: 'activity.used'.tr()),
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
                    onRetry: () => context.read<ActivityCubit>().loadInvoices(),
                  ),
                  success: (invoices) {
                    final pending = invoices.where((i) => !i.isUsed).toList();
                    final used = invoices.where((i) => i.isUsed).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _InvoiceList(items: pending),
                        _InvoiceList(items: used),
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

class _InvoiceList extends StatelessWidget {
  final List<InvoiceItem> items;

  const _InvoiceList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'activity.no_items'.tr(),
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _InvoiceCard(item: items[index]),
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
      onTap: () => context.push('/invoice-details', extra: item),
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
      onTap: () => context.push('/invoice-details', extra: item),
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
