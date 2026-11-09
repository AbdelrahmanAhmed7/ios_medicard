import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/provider_logo.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/provider_option.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Quick provider picker used when a single service is still waiting for a
/// provider. The user always makes the choice; nothing is preselected.
Future<void> showProviderQuickPickSheet(
  BuildContext context, {
  required CartCubit cubit,
  required VoidCallback onViewAll,
  CartOrderKind? orderKind,
  List<CartItem>? items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ProviderQuickPickSheet(
        onViewAll: onViewAll,
        orderKind: orderKind,
        items: items,
      ),
    ),
  );
}

class _ProviderQuickPickSheet extends StatelessWidget {
  final VoidCallback onViewAll;
  final CartOrderKind? orderKind;
  final List<CartItem>? items;

  const _ProviderQuickPickSheet({
    required this.onViewAll,
    this.orderKind,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('quick-pick-sheet'),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final selectionKind = orderKind ??
                  state.providerSelectionKind ??
                  CartOrderKind.services;
              final remaining = items ??
                  state.cart?.items
                      .where(
                        (item) =>
                            item.providerId == null &&
                            item.orderKind == selectionKind,
                      )
                      .toList() ??
                  const <CartItem>[];
              final providers = state.providers
                  .map((provider) => provider.forItems(remaining))
                  .where((provider) => provider.coveredCount > 0)
                  .toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.h),
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.exactFFE5E7EB,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 14.h, 8.w, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (selectionKind == CartOrderKind.medicines
                                    ? 'cart.choose_pharmacy'
                                    : 'cart.choose_provider')
                                .tr(),
                            style: AppTextStyles.of(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkClr,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.inkMutedClr,
                          tooltip: 'common.cancel'.tr(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          remaining
                              .map((item) => item.serviceName)
                              .join(
                                context.locale.languageCode == 'ar'
                                    ? '، '
                                    : ', ',
                              ),
                          style: AppTextStyles.of(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.exactFF334155,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'cart.quick_pick_hint'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 12.sp,
                            color: AppColors.inkMutedClr,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.lineClr),
                  if (state.isProvidersLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandBlueClr,
                        ),
                      ),
                    )
                  else if (state.providersError != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                      child: Column(
                        children: [
                          Text(
                            state.providersError!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.of(
                              fontSize: 13.sp,
                              color: AppColors.inkMutedClr,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextButton(
                            onPressed: () =>
                                context.read<CartCubit>().loadCartAndProviders(
                                  orderKind: state.providerSelectionKind,
                                ),
                            child: Text('common.retry'.tr()),
                          ),
                        ],
                      ),
                    )
                  else if (providers.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Text(
                        'cart.no_providers_available'.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.of(
                          fontSize: 13.sp,
                          color: AppColors.inkMutedClr,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: providers.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppColors.exactFFF1F5F9,
                        ),
                        itemBuilder: (context, index) => _ProviderTile(
                          provider: providers[index],
                          isBusy: state.isAssigningProvider,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                    child: OutlinedButton(
                      key: const ValueKey('view-all-providers'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onViewAll();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandBlueClr,
                        side: const BorderSide(color: AppColors.brandBlueClr),
                        minimumSize: Size.fromHeight(46.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'cart.view_all_providers'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final ProviderOption provider;
  final bool isBusy;

  const _ProviderTile({required this.provider, required this.isBusy});

  Future<void> _pick(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final didAssign = await cubit.assignProvider(provider);
    if (!context.mounted) return;
    if (didAssign) {
      Navigator.of(context).pop();
      showSuccessToast('cart.provider_saved_toast'.tr());
    } else {
      showErrorToast(
        cubit.state.assignProviderError ??
            'cart.failed_to_update_provider'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteClr,
      child: InkWell(
        onTap: isBusy ? null : () => _pick(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              ProviderLogo(
                imageUrl: provider.providerImageUrl,
                name: provider.providerName,
                size: 40.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.of(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.exactFF0F172A,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      provider.coversAll
                          ? 'cart.covers_all_services'.tr(
                              args: ['${provider.totalCount}'],
                            )
                          : 'cart.covers_partial_services'.tr(
                              args: [
                                '${provider.coveredCount}',
                                '${provider.totalCount}',
                              ],
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.of(
                        fontSize: 11.5.sp,
                        color: provider.coversAll
                            ? AppColors.exactFF047857
                            : AppColors.exactFFB45309,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                provider.hasMissingPrices
                    ? 'cart.price_unavailable'.tr()
                    : formatPrice(provider.totalPriceAfter),
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkClr,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColors.inkFaintClr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

