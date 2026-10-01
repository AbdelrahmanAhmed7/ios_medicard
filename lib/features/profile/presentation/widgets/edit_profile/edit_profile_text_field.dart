import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

/// Shared text field for the edit-profile form. Focus wiring stays on the
/// screen (it owns the focus nodes); everything visual lives here.
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
        color: readOnly ? Colors.grey.shade500 : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.of(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
        counterText: '',
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: readOnly ? Colors.grey.shade300 : kAuthBlue,
            width: readOnly ? 1.0 : 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      ),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.isEmpty) ? 'common.required'.tr() : null
              : null),
    );
  }
}
