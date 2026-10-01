import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/theming/app_toast.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';

/// Bottom "view cart" bar. Visible only when the cart has items, and rebuilds
/// only when the cart count changes — list/scroll/pending churn never touches
/// it.
class ProviderCartBar extends StatelessWidget {
  final int providerId;
  final ProviderBranch? selectedBranch;

  const ProviderCartBar({
    super.key,
    required this.providerId,
    required this.selectedBranch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isCartBarSliceChanged,
      builder: (context, state) {
        if (state.getCartItemCount() == 0) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          child: GestureDetector(
            onTap: () async {
              final authed = await context
                  .read<ProviderPageCubit>()
                  .requireAuth();
              if (!context.mounted) return;
              if (!authed) {
                showLoginRequiredMessage(context);
                return;
              }
              context.push(
                '/cart',
                extra: {
                  'providerId': providerId,
                  'selectedBranch': selectedBranch,
                },
              );
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF3872B1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${state.getCartItemCount()}',
                        style: AppTextStyles.of(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      'cart.view_cart'.tr(),
                      style: AppTextStyles.of(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
