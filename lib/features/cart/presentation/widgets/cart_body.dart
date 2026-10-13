import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/category_counter.dart';
import '../cubit/cart_cubit.dart';
import 'cart_actions_header.dart';
import 'cart_item_card.dart';
import 'cart_sync_warning.dart';
import 'category_badges_row.dart';

/// Cart grouped by provider: every assigned provider gets its own section
/// with a scoped checkout button (its own totals, its own invoice).
/// Unassigned items keep the "needs provider" banner instead of checkout.
class CartBody extends StatelessWidget {
  final List<CartItem> items;
  final List<CategoryCounter> categoryCounters;
  final int? initialProviderId;
  final ProviderBranch? initialBranch;
  final String? syncError;
  final bool isBusy;

  const CartBody({super.key,
    required this.items,
    required this.categoryCounters,
    this.initialProviderId,
    this.initialBranch,
    this.syncError,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    final unassigned = items.where((i) => i.providerId == null).toList();
    final groups = <int, List<CartItem>>{};
    for (final item in items) {
      final pid = item.providerId;
      if (pid != null) groups.putIfAbsent(pid, () => []).add(item);
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        if (syncError != null) ...[
          CartSyncWarning(message: syncError!),
          SizedBox(height: 12.h),
        ],
        CartActionsHeader(itemCount: items.length, isBusy: isBusy),
        SizedBox(height: 14.h),
        if (categoryCounters.isNotEmpty) ...[
          CategoryBadgesRow(counters: categoryCounters),
          SizedBox(height: 16.h),
        ],

        if (unassigned.isNotEmpty) ...[
          _NeedsProviderBanner(
            onTap: () {
              final cubit = context.read<CartCubit>();
              cubit.loadCartAndProviders();
              context.push('/choose-provider', extra: cubit);
            },
          ),
          SizedBox(height: 16.h),
          ...unassigned.map((item) => CartItemCard(item: item)),
          SizedBox(height: 8.h),
        ],

        for (final entry in groups.entries) ...[
          _ProviderGroupSection(
            providerId: entry.key,
            items: entry.value,
            initialBranch: initialBranch,
          ),
        ],

        SizedBox(height: 24.h),
      ],
    );
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
    final name = items
        .map((i) => i.providerName)
        .firstWhere(
          (n) => n != null && n.isNotEmpty,
          orElse: () => null,
        ) ??
        '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                name.isNotEmpty ? name : 'cart.provider'.tr(),
                style: AppTextStyles.of(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${items.length}',
                style: AppTextStyles.of(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...items.map((item) => CartItemCard(item: item)),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
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
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'cart.checkout'.tr(),
              style: AppTextStyles.of(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
