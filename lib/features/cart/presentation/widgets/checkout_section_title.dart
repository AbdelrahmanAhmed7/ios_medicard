import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

class CheckoutSectionTitle extends StatelessWidget {
  final String text;

  const CheckoutSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.of(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2E2E2E),
      ),
    );
  }
}
