import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/provider_logo.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';
import 'checkout_summary_row.dart';

/// Shows what was saved and lets the user continue an order or prepare the rest.
class ProviderSelectionSummary extends StatelessWidget {
  final Cart cart;
  final int? selectedProviderId;
  final ValueChanged<int> onContinue;
  final VoidCallback onChooseRemaining;
  final VoidCallback onReviewCart;

  const ProviderSelectionSummary({
    super.key,
    required this.cart,
    this.selectedProviderId,
    required this.onContinue,
    required this.onChooseRemaining,
    required this.onReviewCart,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = cart.items
        .where((item) => item.providerId == null)
        .toList();
    final groups = <int, List<CartItem>>{};
    for (final item in cart.items) {
      final id = item.providerId;
      if (id != null) groups.putIfAbsent(id, () => []).add(item);
    }
    final ids = groups.keys.toList();
    if (ids.remove(selectedProviderId)) ids.insert(0, selectedProviderId!);

    final focusedId = ids.firstOrNull;
    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const PageStorageKey('provider-selection-summary'),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              Text(
                (remaining.isEmpty
                        ? 'cart.all_places_selected'
                        : 'cart.place_saved')
                    .tr(),
                style: AppTextStyles.of(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                (remaining.isEmpty
                        ? 'cart.orders_ready_hint'
                        : 'cart.prepared_order_hint')
                    .tr(),
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              if (focusedId != null) ...[
                SizedBox(height: 16.h),
                _OrderCard(
                  items: groups[focusedId]!,
                  highlighted: true,
                  onContinue: () => onContinue(focusedId),
                ),
              ],
              if (remaining.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'cart.remaining_services_count'.tr(
                          args: ['${remaining.length}'],
                        ),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        remaining
                            .map((item) => item.serviceName)
                            .join(
                              context.locale.languageCode == 'ar' ? '، ' : ', ',
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'cart.remaining_saved_hint'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              for (var i = 1; i < ids.length; i++) ...[
                SizedBox(height: 18.h),
                _OrderCard(
                  items: groups[ids[i]]!,
                  onContinue: () => onContinue(ids[i]),
                ),
              ],
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onReviewCart,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3872B1),
                ),
                child: Text('cart.review_services'.tr()),
              ),
            ],
          ),
        ),
        _NextStepsBar(
          items: focusedId == null ? const [] : groups[focusedId]!,
          onContinue: focusedId == null ? null : () => onContinue(focusedId),
          onChooseRemaining: remaining.isEmpty ? null : onChooseRemaining,
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final List<CartItem> items;
  final VoidCallback onContinue;
  final bool highlighted;

  const _OrderCard({
    required this.items,
    required this.onContinue,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final providerName = items.first.providerName?.trim();
    final hasProviderName = providerName != null && providerName.isNotEmpty;
    final name = hasProviderName ? providerName : 'cart.provider'.tr();
    final missingPrice = items.any(
      (item) => item.priceAfter == null && item.priceBefore == null,
    );
    final total = items.fold(
      0.0,
      (sum, item) => sum + (item.priceAfter ?? item.priceBefore ?? 0),
    );
    return Container(
      key: highlighted ? const ValueKey('selected-provider-order') : null,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF0F7FF) : Colors.white,
        border: Border.all(
          color: highlighted
              ? const Color(0xFF3872B1)
              : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProviderLogo(
                imageUrl: items.first.providerImageUrl,
                name: name,
                size: 40.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'cart.provider'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.of(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text('cart.order_services_count'.tr(args: ['${items.length}'])),
          SizedBox(height: 12.h),
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.serviceName,
                      style: AppTextStyles.of(fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item.priceAfter == null && item.priceBefore == null
                        ? 'cart.price_unavailable'.tr()
                        : 'cart.egp_amount'.tr(
                            args: [
                              checkoutMoney(
                                item.priceAfter ?? item.priceBefore ?? 0,
                              ),
                            ],
                          ),
                    style: AppTextStyles.of(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          Text(
            missingPrice
                ? 'cart.price_unavailable'.tr()
                : 'cart.order_total_amount'.tr(args: [checkoutMoney(total)]),
            style: AppTextStyles.of(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3872B1),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'cart.branch_chosen_at_checkout'.tr(),
            style: AppTextStyles.of(
              fontSize: 11.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          if (!highlighted) ...[
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'cart.continue_provider_order'.tr(args: [name]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStepsBar extends StatelessWidget {
  final List<CartItem> items;
  final VoidCallback? onContinue;
  final VoidCallback? onChooseRemaining;

  const _NextStepsBar({
    required this.items,
    this.onContinue,
    this.onChooseRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final name = items.firstOrNull?.providerName ?? 'cart.provider'.tr();
    final missingPrice = items.any(
      (item) => item.priceAfter == null && item.priceBefore == null,
    );
    final total = items.fold(
      0.0,
      (sum, item) => sum + (item.priceAfter ?? item.priceBefore ?? 0),
    );
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onContinue != null) ...[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  missingPrice
                      ? 'cart.price_unavailable'.tr()
                      : 'cart.order_total_amount'.tr(
                          args: [checkoutMoney(total)],
                        ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(fontSize: 13.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  key: const ValueKey('continue-selected-order'),
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3872B1),
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(48.h),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'cart.continue_selected_order'.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (onChooseRemaining != null) ...[
                SizedBox(height: 8.h),
                OutlinedButton(
                  key: const ValueKey('choose-remaining-places'),
                  onPressed: onChooseRemaining,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3872B1),
                    side: const BorderSide(color: Color(0xFF3872B1)),
                    minimumSize: Size.fromHeight(46.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'cart.choose_remaining_places'.tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
