import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../cubit/cart_cubit.dart';

class CartActionsHeader extends StatelessWidget {
  final int itemCount;
  final bool isBusy;

  const CartActionsHeader({super.key, required this.itemCount, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'cart.items_in_cart'.tr(args: ['$itemCount']),
            style: AppTextStyles.of(
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
          label: Text('cart.clear_cart'.tr()),
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
                'cart.clear_cart_question'.tr(),
                style: AppTextStyles.of(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'cart.clear_cart_confirmation'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
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
                      child: Text('common.cancel'.tr()),
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
                      child: Text('cart.clear_cart'.tr()),
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

  if (confirmed == true && !cubit.isClosed) {
    cubit.clearCart();
  }
}
