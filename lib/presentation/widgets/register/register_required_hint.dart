import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/auth_shared_widgets.dart';

/// Red-asterisk hint row used under form sections.
class RegisterRequiredHint extends StatelessWidget {
  final String text;

  const RegisterRequiredHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '*',
          style: AppTextStyles.of(
            fontSize: 13.sp,
            color: Colors.red,
            fontWeight: FontWeight.w700,
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
            ),
          ),
        ),
      ],
    );
  }
}
