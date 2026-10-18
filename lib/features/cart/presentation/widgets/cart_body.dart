import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart_item.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_item_card.dart';
import 'cart_sync_warning.dart';
import 'checkout_summary_row.dart';
import 'provider_checkout_notice.dart';

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
        final unassigned = items.where((i) => i.providerId == null).toList();
        final groups = <int, List<CartItem>>{};
        for (final item in items) {
          final pid = item.providerId;
          if (pid != null) groups.putIfAbsent(pid, () => []).add(item);
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 24.h),
          children: [
            if (syncError != null) ...[
              CartSyncWarning(message: syncError!),
              SizedBox(height: 14.h),
            ],
            _CartSummaryCard(
              itemCount: items.length,
              total: items.fold<double>(
                0,
                (sum, i) => sum + (i.priceAfter ?? i.priceBefore ?? 0),
              ),
              isBusy: isBusy,
              onClear: () => _showClearCartSheet(context),
            ),
            SizedBox(height: 12.h),
            ProviderCheckoutNotice(message: 'cart.provider_checkout_hint'.tr()),
            SizedBox(height: 20.h),
            if (unassigned.isNotEmpty) ...[
              _NeedsProviderBanner(
                onTap: () {
                  final cubit = context.read<CartCubit>();
                  cubit.loadCartAndProviders();
                  context.push('/choose-provider', extra: cubit);
                },
              ),
              SizedBox(height: 14.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE5E9F0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < unassigned.length; i++)
                      CartItemCard(
                        item: unassigned[i],
                        showDivider: i < unassigned.length - 1,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],

            for (final entry in groups.entries) ...[
              _ProviderGroupSection(
                providerId: entry.key,
                items: entry.value,
                initialBranch: initialBranch,
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
  final double total;
  final bool isBusy;
  final VoidCallback onClear;

  const _CartSummaryCard({
    required this.itemCount,
    required this.total,
    required this.isBusy,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 21.sp,
              color: const Color(0xFF2563EB),
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
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'cart.egp_amount'.tr(args: [checkoutMoney(total)]),
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
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
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      );
    }
    return Tooltip(
      message: 'cart.clear_cart'.tr(),
      child: Material(
        color: const Color(0xFFFEE2E2),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFFDC2626),
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
    backgroundColor: Colors.white,
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
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: 54.r,
                height: 54.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFDC2626),
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'cart.clear_cart_question'.tr(),
                style: AppTextStyles.of(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'cart.clear_cart_confirmation'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  height: 1.35,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
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
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
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

  const _NeedsProviderBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFFB923C)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFF97316),
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'cart.some_items_need_provider'.tr(),
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  color: const Color(0xFFC2410C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFFF97316),
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
  final List<CartItem> items;
  final ProviderBranch? initialBranch;

  const _ProviderGroupSection({
    required this.providerId,
    required this.items,
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
      (sum, i) => sum + (i.priceAfter ?? i.priceBefore ?? 0),
    );
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Row(
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: AppTextStyles.of(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'cart.provider'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'cart.items_in_cart'.tr(args: ['${items.length}']),
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
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
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Text(
                  'cart.egp_amount'.tr(args: [checkoutMoney(subtotal)]),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/checkout',
                    extra: {
                      'cubit': context.read<CartCubit>(),
                      'providerId': providerId,
                      'selectedBranch': initialBranch,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3872B1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'cart.checkout'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
