import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/utils/language_helper.dart';
import '../../../core/widgets/auth_shared_widgets.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Live password-requirements checklist. Pure given the current [password].
class RegisterPasswordRequirements extends StatelessWidget {
  final String password;
  final int minLength;

  const RegisterPasswordRequirements({
    super.key,
    required this.password,
    required this.minLength,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = LanguageHelper.convertArabicToEnglishNumerals(
      password.trim(),
    );
    final showInvalid = normalized.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.register.passwordRequirementsTitle'.tr(),
          style: AppTextStyles.of(
            fontSize: 12.sp,
            color: kAuthGreyText,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        RegisterPasswordRequirement(
          label: 'auth.register.passwordMinLength'.tr(
            namedArgs: {'count': minLength.toString()},
          ),
          isMet: normalized.length >= minLength,
          showInvalid: showInvalid,
        ),
        RegisterPasswordRequirement(
          label: 'auth.register.passwordLetter'.tr(),
          isMet: RegExp(r'[A-Za-z]').hasMatch(normalized),
          showInvalid: showInvalid,
        ),
        RegisterPasswordRequirement(
          label: 'auth.register.passwordNumber'.tr(),
          isMet: RegExp(r'[0-9]').hasMatch(normalized),
          showInvalid: showInvalid,
        ),
        RegisterPasswordRequirement(
          label: 'auth.register.passwordSpecialCharacter'.tr(),
          isMet: RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]')
              .hasMatch(normalized),
          showInvalid: showInvalid,
        ),
      ],
    );
  }
}

class RegisterPasswordRequirement extends StatelessWidget {
  final String label;
  final bool isMet;
  final bool showInvalid;

  const RegisterPasswordRequirement({
    super.key,
    required this.label,
    required this.isMet,
    required this.showInvalid,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMet
        ? AppColors.materialGreen
        : showInvalid
        ? AppColors.materialRed
        : kAuthGreyText;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(
                fontSize: 12.sp,
                color: color,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

