import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/widgets/app_simple_header.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../cart/domain/models/provider_option.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/widgets/order_steps_indicator.dart';
import '../../../cart/presentation/widgets/provider_selection_summary.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ChooseProviderScreen extends StatefulWidget {
  /// Reuse the existing cart when the user explicitly reviews their services.
  final bool returnToPreviousCart;

  const ChooseProviderScreen({super.key, this.returnToPreviousCart = false});

  @override
  State<ChooseProviderScreen> createState() => _ChooseProviderScreenState();
}

class _ChooseProviderScreenState extends State<ChooseProviderScreen> {
  bool _showSummary = false;
  int? _confirmedProviderId;
  CartOrderKind? _confirmedOrderKind;

  void _reviewCart() {
    if (widget.returnToPreviousCart && context.canPop()) {
      context.pop();
    } else {
      context.pushReplacement('/cart');
    }
  }

  void _continueOrder(int providerId, CartOrderKind orderKind) {
    // Keep this route alive: it may own the cubit shared with checkout.
    context.push(
      '/checkout',
      extra: {
        'cubit': context.read<CartCubit>(),
        'providerId': providerId,
        'orderKind': orderKind,
      },
    );
  }

  void _onConfirmed(int providerId) {
    final cubit = context.read<CartCubit>();
    final cart = cubit.state.cart;
    final orderKind =
        cubit.state.providerSelectionKind ?? CartOrderKind.services;
    setState(() {
      _confirmedProviderId = providerId;
      _confirmedOrderKind = orderKind;
      _showSummary = true;
    });
    showSuccessToast('cart.provider_saved_toast'.tr());
    if (cart != null &&
        cart.items.isNotEmpty &&
        cart.items.every(
          (item) =>
              item.providerId == providerId && item.orderKind == orderKind,
        )) {
      _continueOrder(providerId, orderKind);
    }
  }

  void _chooseRemaining() {
    setState(() => _showSummary = false);
    final cubit = context.read<CartCubit>();
    final remaining = cubit.state.cart?.items
        .where((item) => item.providerId == null)
        .firstOrNull;
    cubit.loadCartAndProviders(orderKind: remaining?.orderKind);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final selectionKind =
            state.providerSelectionKind ?? CartOrderKind.services;
        final orderItems =
            state.cart?.items
                .where(
                  (item) =>
                      item.orderKind == selectionKind &&
                      item.providerId == null,
                )
                .toList() ??
            <CartItem>[];
        final remaining = orderItems;
        final providers = state.providers
            .map((provider) => provider.forItems(orderItems))
            .where((provider) => provider.coveredCount > 0)
            .toList();
        final isMedicine = selectionKind == CartOrderKind.medicines;
        final selected = providers
            .where(
              (provider) =>
                  provider.providerId == state.selectedProvider?.providerId,
            )
            .firstOrNull;
        final showSummary =
            state.cart != null &&
            (_showSummary || (!state.isProvidersLoading && orderItems.isEmpty));
        return Scaffold(
          backgroundColor: AppColors.whiteClr,
          body: Column(
            children: [
              AppSimpleHeader(
                title:
                    (showSummary
                            ? 'cart.your_orders'
                            : isMedicine
                            ? 'cart.choose_pharmacy'
                            : 'cart.choose_provider')
                        .tr(),
                onBack: _reviewCart,
                subtitle: !showSummary && providers.isNotEmpty
                    ? 'cart.providers_available'.tr(
                        args: ['${providers.length}'],
                      )
                    : null,
              ),
              OrderStepsIndicator(currentStep: showSummary ? 1 : 0),
              if (!showSummary &&
                  !state.isProvidersLoading &&
                  remaining.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (isMedicine
                                ? 'cart.choose_pharmacy_hint'
                                : 'cart.choose_provider_hint')
                            .tr(),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          color: AppColors.inkMutedClr,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'cart.choosing_for_count'.tr(
                          args: ['${remaining.length}'],
                        ),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        remaining
                            .map((item) => item.serviceName)
                            .join(
                              context.locale.languageCode == 'ar' ? '، ' : ', ',
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: showSummary
                    ? ProviderSelectionSummary(
                        cart: state.cart!,
                        selectedProviderId: _confirmedProviderId,
                        selectedOrderKind: _confirmedOrderKind,
                        onContinue: _continueOrder,
                        onChooseRemaining: _chooseRemaining,
                        onReviewCart: _reviewCart,
                      )
                    : _buildBody(context, state, providers),
              ),
              // Bottom bar — only when a provider is selected
              if (!showSummary && !state.isProvidersLoading && selected != null)
                _ChooseProviderBottomBar(
                  provider: selected,
                  onConfirmed: _onConfirmed,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartState state,
    List<ProviderOption> providers,
  ) {
    if (state.isProvidersLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandBlueClr),
      );
    }

    if (state.providersError != null || state.cartError != null) {
      return _ErrorView(
        message: state.providersError ?? state.cartError!,
        onRetry: () => context.read<CartCubit>().loadCartAndProviders(
          orderKind: state.providerSelectionKind,
        ),
      );
    }

    if (providers.isEmpty) {
      return _EmptyView(onBack: _reviewCart);
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        final isSelected =
            state.selectedProvider?.providerId == provider.providerId;
        return _ProviderCard(
          provider: provider,
          isSelected: isSelected,
          onTap: () {
            if (!state.isAssigningProvider) {
              context.read<CartCubit>().selectProvider(provider);
            }
          },
        );
      },
    );
  }
}

/// Small coverage pill under the provider name.
class _CoveragePill extends StatelessWidget {
  final ProviderOption provider;

  const _CoveragePill({required this.provider});

  @override
  Widget build(BuildContext context) {
    final coversAll = provider.coversAll;
    final background = coversAll
        ? AppColors.exactFFD1FAE5
        : AppColors.exactFFFEF3C7;
    final foreground = coversAll
        ? AppColors.exactFF047857
        : AppColors.exactFFB45309;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            coversAll
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            size: 13.sp,
            color: foreground,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              coversAll
                  ? 'cart.covers_all_services'.tr(
                      args: ['${provider.totalCount}'],
                    )
                  : 'cart.covers_partial_services'.tr(
                      args: [
                        '${provider.coveredCount}',
                        '${provider.totalCount}',
                      ],
                    ),
              style: AppTextStyles.of(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderOption provider;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.exactFFF5F9FF : AppColors.whiteClr,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandBlueClr
                    : AppColors.exactFFE8EDF3,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: logo + name + radio ─────────────────────────────
                Row(
                  children: [
                    // Logo
                    Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lineClr,
                          width: 1.5,
                        ),
                      ),
                      padding: EdgeInsets.all(6.r),
                      child: ClipOval(
                        child:
                            provider.providerImageUrl != null &&
                                provider.providerImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: provider.providerImageUrl!,
                                fit: BoxFit.fill,
                                errorWidget: (_, _, _) =>
                                    _Initials(name: provider.providerName),
                              )
                            : _Initials(name: provider.providerName),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Name + coverage pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.providerName,
                            style: AppTextStyles.of(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.exactFF0F172A,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.h),
                          _CoveragePill(provider: provider),
                        ],
                      ),
                    ),

                    // Radio indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandBlueClr
                              : AppColors.exactFFCBD5E1,
                          width: isSelected ? 0 : 1.5,
                        ),
                        color: isSelected
                            ? AppColors.brandBlueClr
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: AppColors.whiteClr,
                              size: 15.sp,
                            )
                          : null,
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ── Covered services ───────────────────────────────────────────
                ...provider.coveredServices.map(
                  (service) => Padding(
                    padding: EdgeInsets.only(bottom: 5.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.serviceName,
                            style: AppTextStyles.of(
                              fontSize: 12.5.sp,
                              color: AppColors.exactFF334155,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (service.priceBefore != null &&
                            service.priceBefore! > (service.priceAfter ?? 0) &&
                            service.priceBefore! > 0) ...[
                          Text(
                            formatPrice(
                              service.priceBefore,
                              showFreeWhenZero: false,
                            ),
                            style: AppTextStyles.of(
                              fontSize: 11.sp,
                              color: AppColors.inkFaintClr,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 5.w),
                        ],
                        Text(
                          service.priceAfter == null &&
                                  service.priceBefore == null
                              ? 'cart.price_unavailable'.tr()
                              : formatPrice(
                                  service.priceAfter ??
                                      service.priceBefore ??
                                      0,
                                ),
                          style: AppTextStyles.of(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.exactFF0F172A,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (provider.uncoveredServices.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14.sp,
                        color: AppColors.exactFF9CA3AF,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'cart.unavailable_services'.tr(
                            args: [
                              provider.uncoveredServices
                                  .map((s) => s.serviceName)
                                  .where((n) => n.isNotEmpty)
                                  .join(', '),
                            ],
                          ),
                          style: AppTextStyles.of(
                            fontSize: 12.sp,
                            color: AppColors.exactFF9CA3AF,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 10.h),
                const Divider(color: AppColors.exactFFEEF1F5, height: 1),
                SizedBox(height: 10.h),

                // ── Total row ────────────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cart.available_services_total'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 13.sp,
                        color: AppColors.inkMutedClr,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (!provider.hasMissingPrices &&
                            provider.totalPriceBefore >
                                provider.totalPriceAfter &&
                            provider.totalPriceBefore > 0)
                          Text(
                            formatPrice(
                              provider.totalPriceBefore,
                              showFreeWhenZero: false,
                            ),
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              color: AppColors.inkFaintClr,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          provider.hasMissingPrices
                              ? 'cart.price_unavailable'.tr()
                              : formatPrice(provider.totalPriceAfter),
                          style: AppTextStyles.of(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandBlueClr,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChooseProviderBottomBar extends StatelessWidget {
  final ProviderOption provider;
  final ValueChanged<int> onConfirmed;

  const _ChooseProviderBottomBar({
    required this.provider,
    required this.onConfirmed,
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
        color: AppColors.whiteClr,
        border: Border(top: BorderSide(color: AppColors.lineClr)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  provider.providerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.exactFF0F172A,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                provider.hasMissingPrices
                    ? 'cart.price_unavailable'.tr()
                    : formatPrice(provider.totalPriceAfter),
                style: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandBlueClr,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Confirm button
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final isLoading = state.isAssigningProvider;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final didAssign = await context
                              .read<CartCubit>()
                              .assignProvider(provider);
                          if (context.mounted) {
                            if (didAssign) {
                              onConfirmed(provider.providerId);
                            } else {
                              final error = context
                                  .read<CartCubit>()
                                  .state
                                  .assignProviderError;
                              showErrorToast(
                                error ?? 'cart.failed_to_update_provider'.tr(),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlueClr,
                    disabledBackgroundColor: AppColors.exactFFCBD5E1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.whiteClr,
                          ),
                        )
                      : Text(
                          'cart.confirm_provider'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteClr,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.of(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brandBlueClr,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64.sp,
              color: AppColors.exactFFD1D5DB,
            ),
            SizedBox(height: 16.h),
            Text(
              'search.no_providers_found'.tr(),
              style: AppTextStyles.of(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.exactFF6B7280,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'cart.no_providers_available'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 13.sp,
                color: AppColors.exactFF9CA3AF,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlueClr,
                  side: const BorderSide(color: AppColors.brandBlueClr),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'cart.back_to_cart'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
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
              color: AppColors.exactFFD1D5DB,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: AppColors.exactFF6B7280,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlueClr,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'common.retry'.tr(),
                style: AppTextStyles.of(
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteClr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

