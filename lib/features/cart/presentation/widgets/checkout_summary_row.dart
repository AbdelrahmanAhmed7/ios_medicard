import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

class CheckoutSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const CheckoutSummaryRow({super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.of(
                fontSize: isBold ? 16.sp : 14.sp,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String checkoutMoney(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
