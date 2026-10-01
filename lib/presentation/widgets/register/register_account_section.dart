import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/auth_shared_widgets.dart';
import 'register_birth_date_field.dart';
import 'register_gender_selector.dart';
import 'register_password_field.dart';
import 'register_password_requirements.dart';
import 'register_text_field.dart';

/// Phone, gender, birth date, password (+ live requirements), and confirm
/// password. Controllers, focus wiring, and validation come from the screen.
class RegisterAccountSection extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final FocusNode? phoneNumberFocusNode;
  final AutovalidateMode phoneNumberAutovalidate;
  final String? Function(String?) phoneNumberValidator;
  final bool isMale;
  final VoidCallback onMaleTap;
  final VoidCallback onFemaleTap;
  final String birthDate;
  final VoidCallback onSelectBirthDate;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onPasswordToggle;
  final FocusNode? passwordFocusNode;
  final AutovalidateMode passwordAutovalidate;
  final String? Function(String?) passwordValidator;
  final int passwordMinLength;
  final Key? confirmPasswordFieldKey;
  final TextEditingController confirmPasswordController;
  final bool obscureConfirmPassword;
  final VoidCallback onConfirmPasswordToggle;
  final FocusNode? confirmPasswordFocusNode;
  final AutovalidateMode confirmPasswordAutovalidate;
  final String? Function(String?) confirmPasswordValidator;

  const RegisterAccountSection({
    super.key,
    required this.phoneNumberController,
    required this.phoneNumberFocusNode,
    required this.phoneNumberAutovalidate,
    required this.phoneNumberValidator,
    required this.isMale,
    required this.onMaleTap,
    required this.onFemaleTap,
    required this.birthDate,
    required this.onSelectBirthDate,
    required this.passwordController,
    required this.obscurePassword,
    required this.onPasswordToggle,
    required this.passwordFocusNode,
    required this.passwordAutovalidate,
    required this.passwordValidator,
    required this.passwordMinLength,
    required this.confirmPasswordFieldKey,
    required this.confirmPasswordController,
    required this.obscureConfirmPassword,
    required this.onConfirmPasswordToggle,
    required this.confirmPasswordFocusNode,
    required this.confirmPasswordAutovalidate,
    required this.confirmPasswordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(
          'auth.register.phoneNumber'.tr(),
          isRequired: true,
        ),
        SizedBox(height: 6.h),
        RegisterTextField(
          controller: phoneNumberController,
          hintText: 'auth.register.phoneNumberHint'.tr(),
          keyboardType: TextInputType.phone,
          focusNode: phoneNumberFocusNode,
          autovalidateMode: phoneNumberAutovalidate,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: phoneNumberValidator,
        ),
        SizedBox(height: 16.h),

        AuthFieldLabel(
          'auth.register.gender'.tr(),
          isRequired: true,
        ),
        SizedBox(height: 6.h),
        RegisterGenderSelector(
          isMale: isMale,
          onMaleTap: onMaleTap,
          onFemaleTap: onFemaleTap,
        ),
        SizedBox(height: 16.h),

        AuthFieldLabel(
          'auth.register.birthDate'.tr(),
          isRequired: true,
        ),
        SizedBox(height: 6.h),
        RegisterBirthDateField(
          birthDate: birthDate,
          onTap: onSelectBirthDate,
        ),
        SizedBox(height: 16.h),

        AuthFieldLabel(
          'auth.register.password'.tr(),
          isRequired: true,
        ),
        SizedBox(height: 6.h),
        RegisterPasswordField(
          controller: passwordController,
          hintText: 'auth.register.passwordHint'.tr(),
          obscure: obscurePassword,
          onToggle: onPasswordToggle,
          focusNode: passwordFocusNode,
          autovalidateMode: passwordAutovalidate,
          validator: passwordValidator,
        ),
        SizedBox(height: 10.h),
        RegisterPasswordRequirements(
          password: passwordController.text,
          minLength: passwordMinLength,
        ),
        SizedBox(height: 16.h),

        AuthFieldLabel(
          'auth.register.confirmPassword'.tr(),
          isRequired: true,
        ),
        SizedBox(height: 6.h),
        RegisterPasswordField(
          fieldKey: confirmPasswordFieldKey,
          controller: confirmPasswordController,
          hintText: 'auth.register.confirmPasswordHint'.tr(),
          obscure: obscureConfirmPassword,
          onToggle: onConfirmPasswordToggle,
          focusNode: confirmPasswordFocusNode,
          autovalidateMode: confirmPasswordAutovalidate,
          validator: confirmPasswordValidator,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
