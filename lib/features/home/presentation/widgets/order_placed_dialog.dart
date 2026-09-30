import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

/// Popup shown once after a cash order is successfully created,
/// carrying the order number. Visa (online) payments don't use it because the
/// payment status can't be verified from the backend on browser return.
class OrderPlacedDialog {
  static Future<void> maybeShow(
    BuildContext context, {
    required String? orderNumber,
  }) async {
    if (orderNumber == null || orderNumber.isEmpty) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      barrierDismissible: false,
      builder: (_) => _OrderPlacedDialog(orderNumber: orderNumber),
    );
  }
}

class _OrderPlacedDialog extends StatelessWidget {
  final String orderNumber;

  const _OrderPlacedDialog({required this.orderNumber});

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 56,
                color: Color(0xFF159447),
              ),
              SizedBox(height: 18.h),
              Text(
                'cart.order_placed_successfully'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: AppFontSizes.s20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7FF),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFBFD9F7)),
                ),
                child: Text(
                  'activity.order_number'.tr(args: [orderNumber]),
                  style: AppTextStyles.of(
                    fontSize: AppFontSizes.s12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E73BA),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3872B1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'common.ok'.tr(),
                    style: AppTextStyles.of(
                      fontSize: AppFontSizes.s20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}