import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

/// Red-asterisk hint row used under form sections.
class EditProfileRequiredHint extends StatelessWidget {
  final String text;

  const EditProfileRequiredHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '*',
          style: AppTextStyles.of(
            fontSize: 13.sp,
            color: const Color(0xFFDC2626),
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: kAuthGreyText,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// Field label used above every form input.
class EditProfileFieldLabel extends StatelessWidget {
  final String label;

  const EditProfileFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 6.h, start: 2.w, top: 4.h),
      child: Text(
        label,
        style: AppTextStyles.of(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.inkClr,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Section heading inside the form card.
class EditProfileSectionTitle extends StatelessWidget {
  final String title;

  const EditProfileSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 2.w),
      child: Text(
        title,
        style: AppTextStyles.of(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: kAuthInk,
          height: 1.3,
        ),
      ),
    );
  }
}