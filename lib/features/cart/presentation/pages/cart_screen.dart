import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_blue_header.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/category_counter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

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
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const AppBlueHeader(title: 'Cart', bottomRadius: 0),
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state.isCartLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                  );
                }
                if (state.cartError != null) {
                  return _ErrorView(
                    message: state.cartError!,
                    onRetry: () => context.read<CartCubit>().loadCart(),
                  );
                }
                final items = state.cart?.items ?? [];
                if (items.isEmpty) {
                  return const _EmptyCartView();
                }
                return _CartBody(
                  items: items,
                  categoryCounters: state.cart?.categoryCounters ?? [],
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

  const _CartBody({required this.items, required this.categoryCounters});

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    double totalAfter = 0;

    for (var item in items) {
      final original = item.priceBefore ?? item.priceAfter ?? 0;
      final current = item.priceAfter ?? item.priceBefore ?? 0;
      subtotal += original;
      totalAfter += current;
    }

    final double discount = subtotal - totalAfter;

    // Items that still have no provider assigned
    final hasUnassigned = items.any((i) => i.providerId == null);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              // ── Category badges row
              if (categoryCounters.isNotEmpty) ...[
                _CategoryBadgesRow(counters: categoryCounters),
                SizedBox(height: 16.h),
              ],

              // ── Cart Items
              ...items.map((item) => _CartItemCard(item: item)),

              SizedBox(height: 24.h),

              // ── Suggested Offers
              const _SuggestedOffersSection(),

              SizedBox(height: 24.h),

              // ── Payment Summary
              _PaymentSummarySection(
                subtotal: subtotal,
                discount: discount,
                total: totalAfter,
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),

        // ── Bottom action bar ────────────────────────────────────────────────
        _CartBottomBar(hasUnassigned: hasUnassigned, total: totalAfter),
      ],
    );
  }
}

// ─── Category Badges Row ──────────────────────────────────────────────────────

/// Horizontal row of category chips, each with a badge showing the
/// number of selected services in that category.
///
/// Sourced from [Cart.categoryCounters] which comes from the
/// `GET /Cart` response — no extra API call required.
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

/// A single category chip with a floating badge showing [CategoryCounter.count].
class _CategoryChip extends StatelessWidget {
  final CategoryCounter counter;

  const _CategoryChip({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Chip body
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

        // ── Badge — only shown when count > 0
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
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Provider name — shown if assigned, warning if not
                        if (item.providerName != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 13.sp,
                                color: const Color(0xFF3872B1),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.providerName!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF3872B1),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 13.sp,
                                color: const Color(0xFFF97316),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'No provider selected',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFFF97316),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (isPending)
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
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
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE0E7FF),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: const Color(0xFF3872B1),
                          size: 18.sp,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Badges & Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badges
                  Row(
                    children: [
                      _buildBadge(
                        'No Fasting',
                        const Color(0xFFFEF3C7),
                        const Color(0xFFD97706),
                        true,
                      ),
                      SizedBox(width: 8.w),
                      _buildBadge(
                        '10%Off',
                        const Color(0xFFDBEAFE),
                        const Color(0xFF2563EB),
                        false,
                      ),
                    ],
                  ),
                  // Prices
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (item.priceBefore != null)
                        Text(
                          '${item.priceBefore!.toStringAsFixed(0)} EGP',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 6.w),
                      if (item.priceAfter != null)
                        Text(
                          '${item.priceAfter!.toStringAsFixed(0)} EGP',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3872B1),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(
    String text,
    Color bgColor,
    Color textColor,
    bool showIcon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: bgColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.access_time, size: 12.sp, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Bottom Bar ──────────────────────────────────────────────────────────

class _CartBottomBar extends StatelessWidget {
  final bool hasUnassigned;
  final double total;

  const _CartBottomBar({required this.hasUnassigned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Choose Provider" banner — shown only when there are unassigned items
          if (hasUnassigned) ...[
            GestureDetector(
              onTap: () {
                final cubit = context.read<CartCubit>();
                cubit.loadProviders();
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
            height: 52.h,
            child: ElevatedButton(
              onPressed: hasUnassigned
                  ? null
                  : () {
                      // TODO: navigate to checkout
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                hasUnassigned
                    ? 'Choose providers first'
                    : 'Checkout  •  EGP ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
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

// ─── Suggested Offers Section ─────────────────────────────────────────────────

class _SuggestedOffersSection extends StatelessWidget {
  const _SuggestedOffersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Offers',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Mock data count
            itemBuilder: (context, index) {
              return Container(
                width: 140.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Placeholder
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15.r),
                          ),
                          child: Container(
                            height: 100.h,
                            width: double.infinity,
                            color: const Color(0xFFE2E8F0), // Placeholder color
                            // يمكنك استبداله بصورة حقيقية لاحقاً:
                            // child: Image.network('url', fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFF3872B1),
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Vitamin Test',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                '150 EGP',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '135 EGP',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3872B1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Payment Summary Section ──────────────────────────────────────────────────

class _PaymentSummarySection extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;

  const _PaymentSummarySection({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'EGP ${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '- EGP ${discount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF22C55E), // Green color
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Divider(color: Color(0xFFE2E8F0), height: 1),
              ),

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total amount',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'EGP ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Empty & error states ─────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 72.sp,
            color: const Color(0xFFD1D5DB),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add services from a provider page to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
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
