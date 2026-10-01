import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/auth_shared_widgets.dart';

/// Read-only birth-date selector box.
class RegisterBirthDateField extends StatelessWidget {
  final String birthDate;
  final VoidCallback onTap;

  const RegisterBirthDateField({
    super.key,
    required this.birthDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: kAuthBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              birthDate,
              style: AppTextStyles.of(fontSize: 15.sp, color: Colors.black),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: kAuthGreyText,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
