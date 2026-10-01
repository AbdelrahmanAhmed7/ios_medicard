import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/auth_shared_widgets.dart';
import 'register_text_field.dart';

/// First + last name row. Controllers and focus wiring come from the screen.
class RegisterNameRow extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final FocusNode? firstNameFocusNode;
  final FocusNode? lastNameFocusNode;
  final AutovalidateMode firstNameAutovalidate;
  final AutovalidateMode lastNameAutovalidate;
  final String? Function(String?) firstNameValidator;
  final String? Function(String?) lastNameValidator;

  const RegisterNameRow({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.firstNameAutovalidate,
    required this.lastNameAutovalidate,
    required this.firstNameValidator,
    required this.lastNameValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthFieldLabel(
                'auth.register.firstName'.tr(),
                isRequired: true,
              ),
              SizedBox(height: 6.h),
              RegisterTextField(
                controller: firstNameController,
                hintText: 'auth.register.firstNameHint'.tr(),
                focusNode: firstNameFocusNode,
                autovalidateMode: firstNameAutovalidate,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r"[\p{L} .'\-]",
                      unicode: true,
                    ),
                  ),
                ],
                validator: firstNameValidator,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthFieldLabel(
                'auth.register.lastName'.tr(),
                isRequired: true,
              ),
              SizedBox(height: 6.h),
              RegisterTextField(
                controller: lastNameController,
                hintText: 'auth.register.lastNameHint'.tr(),
                focusNode: lastNameFocusNode,
                autovalidateMode: lastNameAutovalidate,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r"[\p{L} .'\-]",
                      unicode: true,
                    ),
                  ),
                ],
                validator: lastNameValidator,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
