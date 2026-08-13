import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_blue_header.dart';

class OrderConfirmedArgs {
  final String orderNumber;

  const OrderConfirmedArgs({required this.orderNumber});
}

class OrderConfirmedScreen extends StatelessWidget {
  final OrderConfirmedArgs args;

  const OrderConfirmedScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          AppBlueHeader(
            title: 'cart.order_confirmed'.tr(),
            bottomRadius: 18,
            onBack: () => context.go('/medicard-home?tab=activity'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 22.h),
              children: [
                Icon(
                  Icons.check_circle,
                  size: 56.sp,
                  color: const Color(0xFF159447),
                ),
                SizedBox(height: 18.h),
                Center(
                  child: Text(
                    'cart.order_placed_successfully'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(child: _OrderBadge(orderNumber: args.orderNumber)),
                SizedBox(height: 34.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => context.go('/medicard-home?tab=activity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3872B1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'cart.view_activity'.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final String orderNumber;

  const _OrderBadge({required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFBFD9F7)),
      ),
      child: Text(
        'activity.order_number'.tr(args: [orderNumber]),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2E73BA),
        ),
      ),
    );
  }
}
