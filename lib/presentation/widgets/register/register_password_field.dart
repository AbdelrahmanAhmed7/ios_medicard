import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/auth_shared_widgets.dart';

/// Password field with visibility toggle for the register form.
class RegisterPasswordField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;

  const RegisterPasswordField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscure,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      style: AppTextStyles.of(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(
        hintText: hintText,
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: kAuthGreyText,
            size: 20.sp,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
