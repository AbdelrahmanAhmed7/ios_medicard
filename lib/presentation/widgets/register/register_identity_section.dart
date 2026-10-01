import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/auth_shared_widgets.dart';
import 'register_required_hint.dart';
import 'register_text_field.dart';

/// National ID + passport (at least one required). Controllers and
/// validation come from the screen.
class RegisterIdentitySection extends StatelessWidget {
  final Key? nationalIdFieldKey;
  final TextEditingController nationalIdController;
  final FocusNode? nationalIdFocusNode;
  final AutovalidateMode nationalIdAutovalidate;
  final String? Function(String?) nationalIdValidator;
  final TextEditingController passportNumberController;
  final FocusNode? passportNumberFocusNode;
  final AutovalidateMode passportNumberAutovalidate;
  final String? Function(String?) passportNumberValidator;
  final ValueChanged<String>? onPassportChanged;

  const RegisterIdentitySection({
    super.key,
    required this.nationalIdFieldKey,
    required this.nationalIdController,
    required this.nationalIdFocusNode,
    required this.nationalIdAutovalidate,
    required this.nationalIdValidator,
    required this.passportNumberController,
    required this.passportNumberFocusNode,
    required this.passportNumberAutovalidate,
    required this.passportNumberValidator,
    required this.onPassportChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterRequiredHint(
          'auth.register.nationalIdOrPassportRequired'.tr(),
        ),
        SizedBox(height: 10.h),
        AuthFieldLabel('auth.register.nationalId'.tr()),
        SizedBox(height: 6.h),
        RegisterTextField(
          fieldKey: nationalIdFieldKey,
          controller: nationalIdController,
          hintText: 'auth.register.nationalIdHint'.tr(),
          keyboardType: TextInputType.number,
          focusNode: nationalIdFocusNode,
          autovalidateMode: nationalIdAutovalidate,
          required: false,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ],
          validator: nationalIdValidator,
        ),
        SizedBox(height: 16.h),

        AuthFieldLabel('auth.register.passportNumber'.tr()),
        SizedBox(height: 6.h),
        RegisterTextField(
          controller: passportNumberController,
          hintText: 'auth.register.passportNumberHint'.tr(),
          required: false,
          focusNode: passportNumberFocusNode,
          autovalidateMode: passportNumberAutovalidate,
          validator: passportNumberValidator,
          onChanged: onPassportChanged,
        ),
        SizedBox(height: 28.h),
      ],
    );
  }
}
