import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../cubit/cart_cubit.dart';

class CartBottomBar extends StatelessWidget {
  final bool hasUnassigned;
  final int? initialProviderId;
  final ProviderBranch? initialBranch;

  const CartBottomBar({super.key,
    required this.hasUnassigned,
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
            ),
            SizedBox(height: 10.h),
          ],

          // Checkout button — hidden while the "needs provider" warning is
          // shown; the warning banner itself leads to provider selection.
          if (!hasUnassigned)
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () {
                  final cubit = context.read<CartCubit>();
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
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'cart.checkout'.tr(),
                style: AppTextStyles.of(
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
