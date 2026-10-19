import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_body.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_error_view.dart';

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppHeaderBackButton(
                    color: const Color(0xFF111827),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/medicard-home');
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'cart.title'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              // The list renders cart items/loading/error only. Pending-id
              // churn (per-item spinners) and checkout/provider slices have
              // their own scoped builders and must not rebuild the list.
              buildWhen: (previous, current) =>
                  previous.cart != current.cart ||
                  previous.isCartLoading != current.isCartLoading ||
                  previous.cartError != current.cartError,
              builder: (context, state) {
                final items = state.cart?.items ?? [];
                if (state.isCartLoading && items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                  );
                }
                if (state.cartError != null && items.isEmpty) {
                  return CartErrorView(
                    message: state.cartError!,
                    onRetry: () => context.read<CartCubit>().loadCart(),
                  );
                }
                if (items.isEmpty) {
                  return CartEmptyView(
                    onExplore: () => context.go(
                      '/search/services',
                      extra: {'enableCartFeatures': true},
                    ),
                  );
                }
                return CartBody(
                  items: items,
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
