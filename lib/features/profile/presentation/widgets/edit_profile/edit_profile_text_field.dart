import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

/// Shared text field for the edit-profile form. Focus wiring stays on the
/// screen (it owns the focus nodes); everything visual lives here.
///
/// Uses the shared [authInputDecoration] so the form reads the same as the
/// address, family-member and checkout screens.
class EditProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool required;
  final bool readOnly;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const EditProfileTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.required = true,
    this.readOnly = false,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = authInputDecoration(hintText: hintText);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      style: AppTextStyles.of(
        fontSize: 15.sp,
        color: readOnly ? AppColors.inkMutedClr : AppColors.inkClr,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      decoration: readOnly
          ? decoration.copyWith(
              filled: true,
              fillColor: AppColors.exactFFF1F5F9,
              enabledBorder: decoration.enabledBorder?.copyWith(
                borderSide: const BorderSide(color: AppColors.lineClr),
              ),
              focusedBorder: decoration.focusedBorder?.copyWith(
                borderSide: const BorderSide(color: AppColors.lineClr),
              ),
            )
          : decoration,
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.isEmpty) ? 'common.required'.tr() : null
              : null),
    );
  }
}
