import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/auth_shared_widgets.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Shared text field for the register form. Focus wiring stays on the screen
/// (it owns the focus nodes); everything visual lives here.
class RegisterTextField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool required;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const RegisterTextField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.required = true,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: AppTextStyles.of(fontSize: 15.sp, color: AppColors.materialBlack),
      decoration: authInputDecoration(hintText: hintText),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.isEmpty) ? 'common.required'.tr() : null
              : null),
    );
  }
}

