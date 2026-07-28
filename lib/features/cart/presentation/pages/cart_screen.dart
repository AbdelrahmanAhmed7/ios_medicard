import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_blue_header.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/category_counter.dart';

class CartScreen extends StatefulWidget {
  final int? initialProviderId;
  final ProviderBranch? initialBranch;

  const CartScreen({super.key, this.initialProviderId, this.initialBranch});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // لون مقارب لخلفية الصورة
      body: Column(
        children: [
          const AppBlueHeader(title: 'Cart', bottomRadius: 20),
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final items = state.cart?.items ?? [];
                if (state.isCartLoading && items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                  );
                }
                if (state.cartError != null && items.isEmpty) {
                  return _ErrorView(
                    message: state.cartError!,
                    onRetry: () => context.read<CartCubit>().loadCart(),
                  );
                }
                if (items.isEmpty) {
                  return _EmptyCartView(
                    onExplore: () => context.go('/medicard-home'),
                  );
                }
                return _CartBody(
                  items: items,
                  categoryCounters: state.cart?.categoryCounters ?? [],
                  initialProviderId: widget.initialProviderId,
                  initialBranch: widget.initialBranch,
                  syncError: state.cartError,
                  isBusy: state.isCartLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body (Scrollable for all sections) ───────────────────────────────────────

class _CartBody extends StatelessWidget {
  final List<CartItem> items;
  final List<CategoryCounter> categoryCounters;
  final int? initialProviderId;
  final ProviderBranch? initialBranch;
  final String? syncError;
  final bool isBusy;

  const _CartBody({
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
                _CartSyncWarning(message: syncError!),
                SizedBox(height: 12.h),
              ],
              _CartActionsHeader(itemCount: items.length, isBusy: isBusy),
              SizedBox(height: 14.h),
              // ── Category badges row (إذا أردت الإبقاء عليها كما هي باللوجيك)
              if (categoryCounters.isNotEmpty) ...[
                _CategoryBadgesRow(counters: categoryCounters),
                SizedBox(height: 16.h),
              ],

              // ── Cart Items
              ...items.map((item) => _CartItemCard(item: item)),

              SizedBox(height: 24.h),
            ],
          ),
        ),

        // ── Bottom action bar ────────────────────────────────────────────────
        _CartBottomBar(
          hasUnassigned: hasUnassigned,
          hasAssigned: hasAssigned,
          initialProviderId: initialProviderId,
          initialBranch: initialBranch,
        ),
      ],
    );
  }
}

class _CartActionsHeader extends StatelessWidget {
  final int itemCount;
  final bool isBusy;

  const _CartActionsHeader({required this.itemCount, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'} in cart',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: isBusy ? null : () => _showClearCartSheet(context),
          icon: isBusy
              ? SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete_sweep_outlined, size: 18.sp),
          label: const Text('Clear cart'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            disabledForegroundColor: const Color(0xFF94A3B8),
          ),
        ),
      ],
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
                'Clear cart?',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'All selected services will be removed from your cart.',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      child: const Text('Cancel'),
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
                      child: const Text('Clear cart'),
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

  if (confirmed == true) {
    cubit.clearCart();
  }
}

// ─── Category Badges Row ──────────────────────────────────────────────────────

class _CategoryBadgesRow extends StatelessWidget {
  final List<CategoryCounter> counters;

  const _CategoryBadgesRow({required this.counters});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: counters
                .map(
                  (c) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 10.w),
                    child: _CategoryChip(counter: c),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _CartSyncWarning extends StatelessWidget {
  final String message;

  const _CartSyncWarning({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFFD97706),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.read<CartCubit>().loadCart(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryCounter counter;

  const _CategoryChip({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF3872B1), width: 1.2),
          ),
          child: Text(
            counter.categoryName,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3872B1),
            ),
          ),
        ),
        if (counter.count > 0)
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Container(
              constraints: BoxConstraints(minWidth: 20.r, minHeight: 20.r),
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              decoration: BoxDecoration(
                color: const Color(0xFF3872B1),
                shape: counter.count > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: counter.count > 9
                    ? BorderRadius.circular(10.r)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${counter.count}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Cart item card ───────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isPending = state.pendingServiceIds.contains(item.serviceId);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Remove Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.serviceName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // ليتناسب مع الصورة
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (isPending)
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3872B1),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => context.read<CartCubit>().removeFromCart(
                        serviceId: item.serviceId,
                        categoryId: item.categoryId,
                      ),
                      child: Icon(
                        Icons.remove_circle_outline, // أيقونة متطابقة مع الصورة
                        color: const Color(0xFF3872B1),
                        size: 24.sp,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // Bottom Row: Tags (Provider/Category/Discount) & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tags Row
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Yellowish Tag (Used for Provider Name or Category to match UI)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB), // لون أصفر فاتح
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(
                                0xFFFBBF24,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.providerName != null
                                    ? Icons.storefront_outlined
                                    : Icons.warning_amber_rounded,
                                size: 12.sp,
                                color: const Color(0xFFD97706),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.providerName ?? 'No provider selected',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFD97706),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Discount Tag (Blue)
                        if (item.discountPercentage != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(
                                  0xFF3872B1,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${item.discountPercentage!.toStringAsFixed(0)}%Off',
                              style: TextStyle(
                                color: const Color(0xFF3872B1),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price Section
                  if (item.priceBefore != null || item.priceAfter != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.priceBefore != null)
                          Text(
                            '${item.priceBefore!.toStringAsFixed(0)} EGP',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black, // نفس اللون في الصورة
                              decoration: item.priceAfter != null
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        if (item.priceBefore != null && item.priceAfter != null)
                          SizedBox(width: 6.w),
                        if (item.priceAfter != null)
                          Text(
                            '${item.priceAfter!.toStringAsFixed(0)} EGP',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(
                                0xFF3872B1,
                              ), // الأزرق في الصورة
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      'Price unavailable',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Cart Bottom Bar ──────────────────────────────────────────────────────────

class _CartBottomBar extends StatelessWidget {
  final bool hasUnassigned;
  final bool hasAssigned;
  final int? initialProviderId;
  final ProviderBranch? initialBranch;

  const _CartBottomBar({
    required this.hasUnassigned,
    required this.hasAssigned,
    this.initialProviderId,
    this.initialBranch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9), // يتناسق مع الخلفية في التصميم السفلي
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnassigned) ...[
            GestureDetector(
              onTap: () {
                final cubit = context.read<CartCubit>();
                cubit.loadCartAndProviders();
                context.push('/choose-provider', extra: cubit);
              },
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
                        'Some items need a provider — tap to choose',
                        style: TextStyle(
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
            ),
            SizedBox(height: 10.h),
          ],

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<CartCubit>();
                if (!hasAssigned) {
                  cubit.loadCartAndProviders();
                  context.push('/choose-provider', extra: cubit);
                  return;
                }
                context.push(
                  '/checkout',
                  extra: {
                    'cubit': cubit,
                    'providerId': initialProviderId,
                    'selectedBranch': initialBranch,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8.r,
                  ), // مطابق لحواف الزر بالصورة
                ),
                elevation: 0,
              ),
              child: Text(
                hasAssigned
                    ? 'cart.checkout'.tr()
                    : 'cart.choose_provider'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600, // خط عريض وواضح
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty & error states ─────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  final VoidCallback onExplore;

  const _EmptyCartView({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 108.r,
            height: 108.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_cart_checkout_rounded,
              size: 50.sp,
              color: const Color(0xFF3872B1),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Your cart is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose services from providers and they will appear here before checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: onExplore,
              icon: Icon(Icons.search_rounded, size: 19.sp),
              label: const Text('Explore services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52.sp,
              color: const Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
