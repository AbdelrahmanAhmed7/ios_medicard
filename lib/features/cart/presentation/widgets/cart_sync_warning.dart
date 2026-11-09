import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../cubit/cart_cubit.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CartSyncWarning extends StatelessWidget {
  final String message;

  const CartSyncWarning({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.exactFFFFFBEB,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.exactFFFBBF24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.exactFFD97706,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.of(
                fontSize: 12.sp,
                color: AppColors.exactFF92400E,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.read<CartCubit>().loadCart(),
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

