import 'package:medicard/core/widgets/app_simple_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/domain/models/provider_option.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/widgets/provider_checkout_notice.dart';

import '../../../../core/theming/app_text_styles.dart';

class ChooseProviderScreen extends StatelessWidget {
  /// When opened from the cart, confirming a provider should return to the
  /// existing cart (and its shared cubit) instead of creating a checkout.
  final bool returnToPreviousCart;

  const ChooseProviderScreen({super.key, this.returnToPreviousCart = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              AppSimpleHeader(
                title: 'cart.choose_provider'.tr(),
                subtitle: state.providers.isNotEmpty
                    ? 'cart.providers_available'.tr(
                        args: ['${state.providers.length}'],
                      )
                    : null,
              ),
              if (!state.isProvidersLoading && state.providers.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: ProviderCheckoutNotice(
                    message: 'cart.choose_provider_hint'.tr(),
                  ),
                ),
              Expanded(child: _buildBody(context, state)),
              // Bottom bar — only when a provider is selected
              if (state.selectedProvider != null)
                _ChooseProviderBottomBar(
                  provider: state.selectedProvider!,
                  returnToPreviousCart: returnToPreviousCart,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state.isProvidersLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      );
    }

    if (state.providersError != null) {
      return _ErrorView(
        message: state.providersError!,
        onRetry: () => context.read<CartCubit>().loadProviders(),
      );
    }

    if (state.providers.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: state.providers.length,
      itemBuilder: (context, index) {
        final provider = state.providers[index];
        final isSelected =
            state.selectedProvider?.providerId == provider.providerId;
        return _ProviderCard(
          provider: provider,
          isSelected: isSelected,
          onTap: () => context.read<CartCubit>().selectProvider(provider),
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
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFFEF3C7);
    final foreground = coversAll
        ? const Color(0xFF047857)
        : const Color(0xFFB45309);

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3872B1)
                : const Color(0xFFE8EDF3),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
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
                            fit: BoxFit.contain,
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
                          color: const Color(0xFF0F172A),
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
                          ? const Color(0xFF3872B1)
                          : const Color(0xFFCBD5E1),
                      width: isSelected ? 0 : 1.5,
                    ),
                    color: isSelected
                        ? const Color(0xFF3872B1)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
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
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if ((service.discountPercentage ?? 0) > 0) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '-${service.discountPercentage!.toStringAsFixed(0)}%',
                          style: AppTextStyles.of(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    if (service.priceBefore != null)
                      Text(
                        'cart.egp_amount'.tr(
                          args: [_money(service.priceBefore!)],
                        ),
                        style: AppTextStyles.of(
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    SizedBox(width: 5.w),
                    Text(
                      'cart.egp_amount'.tr(
                        args: [
                          _money(
                            service.priceAfter ?? service.priceBefore ?? 0,
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
            ),

            if (provider.uncoveredServices.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14.sp,
                    color: const Color(0xFF9CA3AF),
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
                        color: const Color(0xFF9CA3AF),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 10.h),
            const Divider(color: Color(0xFFEEF1F5), height: 1),
            SizedBox(height: 10.h),

            // ── Total row ────────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'cart.total_amount'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Text(
                  'cart.egp_amount'.tr(
                    args: [_money(provider.totalPriceBefore)],
                  ),
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'cart.egp_amount'.tr(
                    args: [_money(provider.totalPriceAfter)],
                  ),
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3872B1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooseProviderBottomBar extends StatelessWidget {
  final ProviderOption provider;
  final bool returnToPreviousCart;

  const _ChooseProviderBottomBar({
    required this.provider,
    required this.returnToPreviousCart,
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
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.providerName,
                style: AppTextStyles.of(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'cart.egp_amount'.tr(args: [_money(provider.totalPriceAfter)]),
                style: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3872B1),
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
                              // Provider selection only assigns the covered
                              // items. Checkout remains scoped to each provider
                              // group on the cart screen.
                              if (returnToPreviousCart && context.canPop()) {
                                context.pop();
                              } else {
                                context.pushReplacement('/cart');
                              }
                            } else {
                              final error = context
                                  .read<CartCubit>()
                                  .state
                                  .assignProviderError;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error ??
                                        'cart.failed_to_update_provider'.tr(),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3872B1),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
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
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'cart.confirm_provider'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.of(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3872B1),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64.sp,
            color: const Color(0xFFD1D5DB),
          ),
          SizedBox(height: 16.h),
          Text(
            'search.no_providers_found'.tr(),
            style: AppTextStyles.of(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'cart.no_providers_available'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 13.sp,
              color: const Color(0xFF9CA3AF),
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
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
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
              child: Text(
                'common.retry'.tr(),
                style: AppTextStyles.of(
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

/// Same rule as the checkout/invoice totals: whole for integers, two
/// decimals otherwise — so this screen never disagrees with checkout.
String _money(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
