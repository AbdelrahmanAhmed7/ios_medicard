import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/category_counter.dart';
import 'cart_actions_header.dart';
import 'cart_bottom_bar.dart';
import 'cart_item_card.dart';
import 'cart_sync_warning.dart';
import 'category_badges_row.dart';

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
    final hasUnassigned = items.any((i) => i.providerId == null);
    final hasAssigned = items.any((i) => i.providerId != null);

    return Column(
      children: [
        Expanded(
          child: ListView(
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

              ...items.map((item) => CartItemCard(item: item)),

              SizedBox(height: 24.h),
            ],
          ),
        ),

        CartBottomBar(
          hasUnassigned: hasUnassigned,
          hasAssigned: hasAssigned,
          initialProviderId: initialProviderId,
          initialBranch: initialBranch,
        ),
      ],
    );
  }
}
