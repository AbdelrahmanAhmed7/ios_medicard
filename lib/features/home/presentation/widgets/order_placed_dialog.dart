import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

/// Popup shown once after a cash invoice is successfully created,
/// carrying the invoice number. Visa (online) payments don't use it because the
/// payment status can't be verified from the backend on browser return.
class OrderPlacedDialog {
  static Future<bool?> maybeShow(
    BuildContext context, {
    required String? orderNumber,
    int remainingServices = 0,
  }) async {
    if (orderNumber == null || orderNumber.isEmpty) return null;
    if (!context.mounted) return null;

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      barrierDismissible: false,
      builder: (_) => _OrderPlacedDialog(
        orderNumber: orderNumber,
        remainingServices: remainingServices,
      ),
    );
  }
}

class _OrderPlacedDialog extends StatelessWidget {
  final String orderNumber;
  final int remainingServices;

  const _OrderPlacedDialog({
    required this.orderNumber,
    required this.remainingServices,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 22.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 68.r,
                  height: 68.r,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 68.r,
                        height: 68.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF3FB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 32.sp,
                          color: const Color(0xFF3872B1),
                        ),
                      ),
                      PositionedDirectional(
                        end: -2.w,
                        bottom: -2.h,
                        child: Container(
                          width: 25.r,
                          height: 25.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF159447),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'cart.order_confirmed'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: AppFontSizes.s20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'cart.order_created_message'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F7FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFBFD9F7)),
                  ),
                  child: Text(
                    'activity.invoice_number'.tr(args: [orderNumber]),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E73BA),
                    ),
                  ),
                ),
                SizedBox(height: 26.h),
                if (remainingServices > 0) ...[
                  Text(
                    'cart.services_still_in_cart'.tr(
                      args: ['$remainingServices'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'cart.continue_remaining_services'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3872B1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'cart.view_invoices'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
