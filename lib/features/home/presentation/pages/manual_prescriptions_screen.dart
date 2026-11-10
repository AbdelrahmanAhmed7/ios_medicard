import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_header_back_button.dart';
import '../../../../core/utils/shimmer_card.dart';
import '../../../../data/manual_prescription_response_model.dart';
import '../../../../domain/medicard_repository.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../../medicard_network/logic/provider_page_state.dart';
import '../../../../medicard_network/presentation/widgets/provider_shared_widgets.dart';
import '../../../notifications/push_notification_service.dart';

class ManualPrescriptionsScreen extends StatefulWidget {
  const ManualPrescriptionsScreen({super.key});

  @override
  State<ManualPrescriptionsScreen> createState() =>
      _ManualPrescriptionsScreenState();
}

class _ManualPrescriptionsScreenState extends State<ManualPrescriptionsScreen> {
  static const _pageSize = 10;
  final _scrollController = ScrollController();
  Timer? _refreshTimer;
  StreamSubscription<RemoteMessage>? _prescriptionNotificationSubscription;
  final _statuses = <String?>[null, 'Pending', 'Processed', 'Rejected'];
  List<ManualPrescriptionItemModel> _items = [];
  String? _status;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _loadingRequest = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(_load());
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_load(refresh: true)),
    );
    _prescriptionNotificationSubscription = PushNotificationService
        .instance
        .onMessageReceived
        .where(_isPrescriptionNotification)
        .listen((_) => unawaited(_load(refresh: true)));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _prescriptionNotificationSubscription?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool _isPrescriptionNotification(RemoteMessage message) {
    final data = message.data;
    final body = (data['Body'] ?? data['body'])?.toString().trim();
    return body?.toLowerCase() == 'prescription';
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 180.h) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loadingMore || _loadingRequest) return;
    _loadingRequest = true;
    setState(() {
      _loading = !refresh || _items.isEmpty;
      _error = null;
      _page = 1;
    });
    final result = await sl<MedicardRepository>().getManualPrescriptions(
      pageNumber: 1,
      pageSize: _pageSize,
      status: _status,
    );
    if (!mounted) return;
    result.when(
      success: (data) => setState(() {
        _items = data.items;
        _totalPages = data.totalPages;
        _loading = false;
      }),
      failure: (message) => setState(() {
        _loading = false;
        _error = message;
      }),
    );
    _loadingRequest = false;
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final result = await sl<MedicardRepository>().getManualPrescriptions(
      pageNumber: nextPage,
      pageSize: _pageSize,
      status: _status,
    );
    if (!mounted) return;
    result.when(
      success: (data) => setState(() {
        _page = nextPage;
        _totalPages = data.totalPages;
        _items.addAll(data.items);
        _loadingMore = false;
      }),
      failure: (_) => setState(() => _loadingMore = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteClr,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
              child: Row(
                children: [
                  AppHeaderBackButton(
                    color: AppColors.inkClr,
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'manual_prescription.list_title'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkClr,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/manual-prescription'),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: AppColors.brandBlueClr,
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
            _StatusFilters(
              selected: _status,
              statuses: _statuses,
              onChanged: (status) {
                setState(() => _status = status);
                unawaited(_load());
              },
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/manual-prescription');
          if (mounted) unawaited(_load(refresh: true));
        },
        backgroundColor: AppColors.brandBlueClr,
        foregroundColor: AppColors.whiteClr,
        icon: const Icon(Icons.upload_file_outlined),
        label: Text('manual_prescription.add'.tr()),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const _PrescriptionsLoadingList();
    if (_error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: () => unawaited(_load()),
          icon: const Icon(Icons.refresh),
          label: Text(_error!),
        ),
      );
    }
    if (_items.isEmpty) {
      return _EmptyPrescriptionsView(
        onAdd: () => context.push('/manual-prescription'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) {
          if (index == _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return _PrescriptionCard(
            item: _items[index],
            onTap: _items[index].items.isEmpty
                ? null
                : () => _showItemsPopup(_items[index]),
            onRejectionTap: _items[index].rejectionReasons.isEmpty
                ? null
                : () => _showRejectionDialog(_items[index]),
          );
        },
      ),
    );
  }

  Future<void> _showItemsPopup(ManualPrescriptionItemModel prescription) async {
    final cartItems = sl<CartCubit>().state.cart?.items ?? const [];
    final hasPrescriptionItemsInCart = prescription.items.any(
      (prescriptionItem) => cartItems.any(
        (cartItem) => cartItem.serviceId == prescriptionItem.serviceId,
      ),
    );
    final action = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.whiteClr,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: _PrescriptionItemsSheet(
          prescription: prescription,
          showCartAction: hasPrescriptionItemsInCart,
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action) {
      context.push('/cart');
    } else {
      context.go('/medicard-home?tab=activity');
    }
  }

  void _showRejectionDialog(ManualPrescriptionItemModel prescription) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('manual_prescription.rejection_title'.tr()),
        content: SizedBox(
          width: 0.78.sw,
          height: math.min(
            0.45.sh,
            math.max(72.h, prescription.rejectionReasons.length * 48.h),
          ),
          child: ListView.separated(
            itemCount: prescription.rejectionReasons.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, index) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 19.sp,
                  color: AppColors.errorClr,
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(prescription.rejectionReasons[index])),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('manual_prescription.close'.tr()),
          ),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final String? selected;
  final List<String?> statuses;
  final ValueChanged<String?> onChanged;

  const _StatusFilters({
    required this.selected,
    required this.statuses,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54.h,
    child: ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      itemCount: statuses.length,
      separatorBuilder: (_, _) => SizedBox(width: 8.w),
      itemBuilder: (_, index) {
        final status = statuses[index];
        return CategoryTabChip(
          tab: CategoryTab(categoryId: index, categoryName: _label(status)),
          isSelected: status == selected,
          onTap: () => onChanged(status),
        );
      },
    ),
  );

  String _label(String? status) => status == null
      ? 'manual_prescription.all'.tr()
      : 'manual_prescription.status_${status.toLowerCase()}'.tr();
}

class _PrescriptionCard extends StatelessWidget {
  final ManualPrescriptionItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onRejectionTap;

  const _PrescriptionCard({
    required this.item,
    this.onTap,
    this.onRejectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status.toLowerCase()) {
      'pending' => AppColors.warningClr,
      'processed' => AppColors.successClr,
      'rejected' => AppColors.errorClr,
      _ => AppColors.inkMutedClr,
    };
    final date = item.createdAt == null
        ? ''
        : DateFormat(
            'dd/MM/yyyy - hh:mm a',
            context.locale.languageCode,
          ).format(item.createdAt!.toLocal());
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.whiteClr,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.lineClr),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 72.w,
                height: 72.w,
                child: item.imageUrl == null
                    ? const ColoredBox(
                        color: AppColors.exactFFF1F5F9,
                        child: Icon(Icons.receipt_long_outlined),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        cacheKey: _stableImageCacheKey(item.imageUrl!),
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        placeholder: (_, _) => SmoothShimmer(
                          child: ColoredBox(
                            color: AppColors.exactFFE8E8E8,
                            child: SizedBox(width: 72.w, height: 72.w),
                          ),
                        ),
                        errorWidget: (_, _, _) => const ColoredBox(
                          color: AppColors.exactFFF1F5F9,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${'manual_prescription.number'.tr()} #${item.id}',
                          style: AppTextStyles.of(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkClr,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'manual_prescription.status_${item.status.toLowerCase()}'
                              .tr(),
                          style: TextStyle(color: statusColor, fontSize: 11.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    date,
                    style: TextStyle(
                      color: AppColors.inkMutedClr,
                      fontSize: 12.sp,
                    ),
                  ),
                  if (item.items.isNotEmpty) ...[
                    SizedBox(height: 7.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dropdownHoverClr,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 16.sp,
                            color: AppColors.brandBlueClr,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '${item.items.length} ${'manual_prescription.items_count'.tr()}',
                            style: TextStyle(
                              color: AppColors.brandBlueClr,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'manual_prescription.tap_for_details'.tr(),
                            style: TextStyle(
                              color: AppColors.inkSoftClr,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.status.toLowerCase() == 'rejected' &&
                      item.rejectionReasons.isNotEmpty) ...[
                    SizedBox(height: 7.h),
                    InkWell(
                      onTap: onRejectionTap,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorClr.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.errorClr.withValues(alpha: .25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 16.sp,
                              color: AppColors.errorClr,
                            ),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                'manual_prescription.view_rejection_reason'
                                    .tr(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.errorClr,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 17.sp,
                              color: AppColors.errorClr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _stableImageCacheKey(String url) {
  final parsed = Uri.tryParse(url);
  return parsed == null || parsed.path.isEmpty ? url : parsed.path;
}

class _PrescriptionsLoadingList extends StatelessWidget {
  const _PrescriptionsLoadingList();

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
    itemCount: 5,
    separatorBuilder: (_, _) => SizedBox(height: 12.h),
    itemBuilder: (_, _) => const _PrescriptionCardSkeleton(),
  );
}

class _PrescriptionCardSkeleton extends StatelessWidget {
  const _PrescriptionCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 112.h,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.whiteClr,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.lineClr),
    ),
    child: SmoothShimmer(
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.exactFFE8E8E8,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150.w,
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: AppColors.exactFFE8E8E8,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 95.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: AppColors.exactFFE8E8E8,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyPrescriptionsView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPrescriptionsView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 22.h),
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.lineClr),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlueClr.withValues(alpha: .08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 108.r,
                  height: 108.r,
                  decoration: const BoxDecoration(
                    color: AppColors.dropdownHoverClr,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 54.sp,
                        color: AppColors.brandBlueClr,
                      ),
                      Positioned(
                        right: 8.r,
                        bottom: 10.r,
                        child: Container(
                          width: 30.r,
                          height: 30.r,
                          decoration: const BoxDecoration(
                            color: AppColors.brandBlueClr,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 20.sp,
                            color: AppColors.whiteClr,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'manual_prescription.empty'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkClr,
                  ),
                ),
                SizedBox(height: 9.h),
                Text(
                  'manual_prescription.empty_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: AppColors.inkMutedClr,
                    height: 1.55,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: Icon(Icons.upload_file_outlined, size: 19.sp),
                    label: Text('manual_prescription.empty_action'.tr()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBlueClr,
                      foregroundColor: AppColors.whiteClr,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionItemsSheet extends StatelessWidget {
  final ManualPrescriptionItemModel prescription;
  final bool showCartAction;

  const _PrescriptionItemsSheet({
    required this.prescription,
    required this.showCartAction,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final dialogHeight = math.min(
      0.78.sh,
      190.h + (prescription.items.length * 88.h),
    );
    return SizedBox(
      height: dialogHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lineClr,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'manual_prescription.items_title'.tr(),
                    style: AppTextStyles.of(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkClr,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.inkMutedClr,
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${prescription.items.length} ${'manual_prescription.items_count'.tr()}',
              style: TextStyle(
                color: AppColors.brandBlueClr,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView(
                children: prescription.items
                    .map(
                      (item) =>
                          _PrescriptionItemRow(item: item, isArabic: isArabic),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(showCartAction),
                icon: Icon(
                  showCartAction
                      ? Icons.shopping_cart_outlined
                      : Icons.receipt_long_outlined,
                  size: 19.sp,
                ),
                label: Text(
                  (showCartAction ? 'cart.go_to_cart' : 'cart.view_invoices')
                      .tr(),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlueClr,
                  foregroundColor: AppColors.whiteClr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionItemRow extends StatelessWidget {
  final ManualPrescriptionEntryModel item;
  final bool isArabic;
  const _PrescriptionItemRow({required this.item, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final name =
        (isArabic ? item.serviceArName : item.serviceEnName) ??
        item.serviceArName ??
        item.serviceEnName ??
        '—';
    final provider =
        (isArabic ? item.providerArName : item.providerEnName) ??
        item.providerArName ??
        item.providerEnName;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.exactFFF1F5F9,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            item.isMedicine
                ? Icons.medication_outlined
                : Icons.medical_services_outlined,
            color: AppColors.brandBlueClr,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkClr,
                  ),
                ),
                if (provider?.isNotEmpty == true)
                  Text(
                    provider!,
                    style: TextStyle(
                      color: AppColors.inkMutedClr,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${'manual_prescription.quantity'.tr()}: ${item.quantityAdded}',
            style: TextStyle(
              color: AppColors.brandBlueClr,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
