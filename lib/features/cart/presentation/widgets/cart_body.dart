import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/provider_logo.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_item_card.dart';
import 'cart_sync_warning.dart';
import 'provider_checkout_notice.dart';
import 'provider_quick_pick_sheet.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Cart grouped by provider: every assigned provider gets its own bordered
/// section (header + divider-separated items + subtotal + scoped checkout).
/// Unassigned items sit under the warning banner with no checkout of
/// their own.
class CartBody extends StatelessWidget {
  final List<CartItem> items;
  final int? initialProviderId;
  final ProviderBranch? initialBranch;
  final String? syncError;
  final bool isBusy;

  const CartBody({
    super.key,
    required this.items,
    this.initialProviderId,
    this.initialBranch,
    this.syncError,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (previous, current) =>
          previous.cart != current.cart ||
          previous.isCartLoading != current.isCartLoading,
      builder: (context, state) {
        final unassignedGroups = <CartOrderKind, List<CartItem>>{
          for (final kind in CartOrderKind.values)
            kind: items
                .where(
                  (item) => item.providerId == null && item.orderKind == kind,
                )
                .toList(),
        };
        final groups = <(CartOrderKind, int), List<CartItem>>{};
        for (final item in items) {
          final pid = item.providerId;
          if (pid != null) {
            groups.putIfAbsent((item.orderKind, pid), () => []).add(item);
          }
        }
        final pricedItems = items
            .where(
              (item) =>
                  item.providerId != null &&
                  (item.totalPriceAfter != null ||
                      item.totalPriceBefore != null),
            )
            .toList();

        return ListView(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 24.h),
          children: [
            if (syncError != null) ...[
              CartSyncWarning(message: syncError!),
              SizedBox(height: 14.h),
            ],
            _CartSummaryCard(
              itemCount: items.length,
              total: pricedItems.isEmpty
                  ? null
                  : pricedItems.fold<double>(
                      0,
                      (sum, i) =>
                          sum + (i.totalPriceAfter ?? i.totalPriceBefore ?? 0),
                    ),
              hasIncompletePrices: pricedItems.length != items.length,
              isBusy: isBusy,
              onClear: () => _showClearCartSheet(context),
            ),
            if (groups.length > 1) ...[
              SizedBox(height: 12.h),
              ProviderCheckoutNotice(
                message: 'cart.provider_checkout_hint'.tr(),
              ),
            ],
            SizedBox(height: 20.h),
            for (final entry in unassignedGroups.entries)
              if (entry.value.isNotEmpty) ...[
                _NeedsProviderBanner(
                  key: ValueKey('unassigned-${entry.key.name}'),
                  count: entry.value.length,
                  orderKind: entry.key,
                  onTap: () {
                    final cubit = context.read<CartCubit>();
                    cubit.loadCartAndProviders(orderKind: entry.key);
                    if (entry.value.length == 1) {
                      showProviderQuickPickSheet(
                        context,
                        cubit: cubit,
                        orderKind: entry.key,
                        onViewAll: () {
                          if (context.mounted) {
                            context.push('/choose-provider', extra: cubit);
                          }
                        },
                      );
                    } else {
                      context.push('/choose-provider', extra: cubit);
                    }
                  },
                ),
                SizedBox(height: 14.h),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.exactFFE5E9F0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < entry.value.length; i++)
                        CartItemCard(
                          item: entry.value[i],
                          showDivider: i < entry.value.length - 1,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],

            for (final (index, entry) in groups.entries.indexed) ...[
              _ProviderGroupSection(
                providerId: entry.key.$2,
                orderKind: entry.key.$1,
                items: entry.value,
                orderPosition: groups.length > 1 ? index + 1 : null,
                ordersCount: groups.length,
                initialBranch: entry.key.$2 == initialProviderId
                    ? initialBranch
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final int itemCount;
  final double? total;
  final bool hasIncompletePrices;
  final bool isBusy;
  final VoidCallback onClear;

  const _CartSummaryCard({
    required this.itemCount,
    required this.total,
    required this.hasIncompletePrices,
    required this.isBusy,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.exactFFEFF6FF,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              color: AppColors.whiteClr,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 21.sp,
              color: AppColors.exactFF2563EB,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'cart.items_in_cart'.tr(args: ['$itemCount']),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkClr,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  total == null
                      ? 'cart.price_after_place'.tr()
                      : formatPrice(total),
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.exactFF2563EB,
                  ),
                ),
                if (total != null && hasIncompletePrices) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'cart.partial_total_hint'.tr(),
                    style: AppTextStyles.of(
                      fontSize: 12.sp,
                      color: AppColors.inkMutedClr,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _ClearCartButton(isBusy: isBusy, onTap: onClear),
        ],
      ),
    );
  }
}

class _ClearCartButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const _ClearCartButton({required this.isBusy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: 42.r,
        height: 42.r,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.exactFF2563EB,
            ),
          ),
        ),
      );
    }
    return Tooltip(
      message: 'cart.clear_cart'.tr(),
      child: Material(
        color: AppColors.exactFFFEE2E2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.exactFFDC2626,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showClearCartSheet(BuildContext context) async {
  final cubit = context.read<CartCubit>();
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.whiteClr,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.exactFFE5E7EB,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: 54.r,
                height: 54.r,
                decoration: const BoxDecoration(
                  color: AppColors.exactFFFEE2E2,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.exactFFDC2626,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'cart.clear_cart_question'.tr(),
                style: AppTextStyles.of(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkClr,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'cart.clear_cart_confirmation'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  height: 1.35,
                  color: AppColors.exactFF6B7280,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.exactFF334155,
                        side: const BorderSide(color: AppColors.exactFFD1D5DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: Text('common.cancel'.tr()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.exactFFDC2626,
                        foregroundColor: AppColors.whiteClr,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: Text('cart.clear_cart'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirmed == true && !cubit.isClosed) {
    cubit.clearCart();
  }
}

class _NeedsProviderBanner extends StatelessWidget {
  final VoidCallback onTap;
  final int count;
  final CartOrderKind orderKind;

  const _NeedsProviderBanner({
    super.key,
    required this.onTap,
    required this.count,
    required this.orderKind,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.exactFFFFF7ED,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.exactFFFB923C),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.exactFFF97316,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                (orderKind == CartOrderKind.medicines
                        ? 'cart.choose_pharmacy_count'
                        : 'cart.choose_places_count')
                    .tr(args: ['$count']),
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  color: AppColors.exactFFC2410C,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.exactFFF97316,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderGroupSection extends StatelessWidget {
  final int providerId;
  final CartOrderKind orderKind;
  final List<CartItem> items;
  final int? orderPosition;
  final int ordersCount;
  final ProviderBranch? initialBranch;

  const _ProviderGroupSection({
    required this.providerId,
    required this.orderKind,
    required this.items,
    this.orderPosition,
    this.ordersCount = 1,
    this.initialBranch,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        items
            .map((i) => i.providerName)
            .firstWhere((n) => n != null && n.isNotEmpty, orElse: () => null) ??
        '';
    final subtotal = items.fold<double>(
      0,
      (sum, i) => sum + (i.totalPriceAfter ?? i.totalPriceBefore ?? 0),
    );
    final hasMissingPrice = items.any(
      (item) => item.totalPriceAfter == null && item.totalPriceBefore == null,
    );
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.exactFFE5E9F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Row(
              children: [
                ProviderLogo(
                  imageUrl: items.first.providerImageUrl,
                  name: name,
                  size: 34.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (orderPosition != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            'cart.order_position'.tr(
                              args: ['$orderPosition', '$ordersCount'],
                            ),
                            style: AppTextStyles.of(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMutedClr,
                            ),
                          ),
                        ),
                      Text(
                        name.isNotEmpty ? name : 'cart.provider'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkClr,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        (orderKind == CartOrderKind.medicines
                                ? 'cart.medicines'
                                : 'cart.services')
                            .tr(),
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBlueClr,
                        ),
                      ),
                      Text(
                        'cart.order_services_count'.tr(
                          args: ['${items.length}'],
                        ),
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          color: AppColors.exactFF6B7280,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => CartItemCard(item: item)),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
            child: Row(
              children: [
                Text(
                  'cart.subtotal'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: AppColors.exactFF6B7280,
                  ),
                ),
                const Spacer(),
                Text(
                  hasMissingPrice
                      ? 'cart.price_unavailable'.tr()
                      : formatPrice(subtotal),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkClr,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: double.infinity,
                minHeight: 48.h,
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/checkout',
                    extra: {
                      'cubit': context.read<CartCubit>(),
                      'providerId': providerId,
                      'orderKind': orderKind,
                      'selectedBranch': initialBranch,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlueClr,
                  foregroundColor: AppColors.whiteClr,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'cart.continue_provider_order'.tr(
                    args: [name.isNotEmpty ? name : 'cart.provider'.tr()],
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 10.w, bottom: 4.h),
              child: TextButton.icon(
                onPressed: () {
                  final cubit = context.read<CartCubit>();
                  cubit.loadCartAndProviders(orderKind: orderKind);
                  showProviderQuickPickSheet(
                    context,
                    cubit: cubit,
                    orderKind: orderKind,
                    items: items,
                    onViewAll: () {
                      if (context.mounted) {
                        context.push('/choose-provider', extra: cubit);
                      }
                    },
                  );
                },
                icon: Icon(Icons.edit_outlined, size: 15.sp),
                label: Text(
                  'cart.change_provider'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandBlueClr,
                  minimumSize: Size(0, 34.h),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

