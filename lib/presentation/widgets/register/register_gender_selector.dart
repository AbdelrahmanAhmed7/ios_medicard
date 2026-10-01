import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/auth_shared_widgets.dart';

/// Male/female selector. Pure given [isMale]; taps come in as callbacks.
class RegisterGenderSelector extends StatelessWidget {
  final bool isMale;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;

  const RegisterGenderSelector({
    super.key,
    required this.isMale,
    required this.onMaleTap,
    required this.onFemaleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kAuthBorderColor),
      ),
      child: Row(
        children: [
          AuthGenderOption(
            label: 'auth.register.male'.tr(),
            selected: isMale,
            onTap: onMaleTap,
          ),
          SizedBox(width: 32.w),
          AuthGenderOption(
            label: 'auth.register.female'.tr(),
            selected: !isMale,
            onTap: onFemaleTap,
          ),
        ],
      ),
    );
  }
}
