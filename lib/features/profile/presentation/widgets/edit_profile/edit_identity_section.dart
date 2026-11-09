import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';
import 'edit_profile_gender_dropdown.dart';
import 'edit_profile_labels.dart';
import 'edit_profile_text_field.dart';

/// Identity fields: card number, national ID, passport, phone, birth date,
/// gender. Controllers and validation come from the screen.
class EditIdentitySection extends StatelessWidget {
  final String? cardNumber;
  final TextEditingController cardNumberController;
  final TextEditingController nationalIdController;
  final FocusNode? nationalIdFocusNode;
  final AutovalidateMode nationalIdAutovalidate;
  final List<TextInputFormatter> digitsFormatters;
  final String? Function(String?) nationalIdValidator;
  final TextEditingController passportNumberController;
  final FocusNode? passportNumberFocusNode;
  final AutovalidateMode passportNumberAutovalidate;
  final TextEditingController phoneNumberController;
  final FocusNode? phoneNumberFocusNode;
  final AutovalidateMode phoneNumberAutovalidate;
  final String? Function(String?) phoneNumberValidator;
  final TextEditingController birthDateController;
  final bool birthDateIsEmpty;
  final VoidCallback onSelectBirthDate;
  final bool? isMale;
  final ValueChanged<bool?> onGenderChanged;

  const EditIdentitySection({
    super.key,
    required this.cardNumber,
    required this.cardNumberController,
    required this.nationalIdController,
    required this.nationalIdFocusNode,
    required this.nationalIdAutovalidate,
    required this.digitsFormatters,
    required this.nationalIdValidator,
    required this.passportNumberController,
    required this.passportNumberFocusNode,
    required this.passportNumberAutovalidate,
    required this.phoneNumberController,
    required this.phoneNumberFocusNode,
    required this.phoneNumberAutovalidate,
    required this.phoneNumberValidator,
    required this.birthDateController,
    required this.birthDateIsEmpty,
    required this.onSelectBirthDate,
    required this.isMale,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Number — read-only; shown only when returned by the backend
        if ((cardNumber ?? '').trim().isNotEmpty) ...[
          EditProfileFieldLabel('edit_profile.card_number'.tr()),
          EditProfileTextField(
            controller: cardNumberController,
            hintText: 'edit_profile.card_number'.tr(),
            required: false,
            readOnly: true,
          ),
          SizedBox(height: 14.h),
        ],

        EditProfileRequiredHint(
          'auth.register.nationalIdOrPassportRequired'.tr(),
        ),
        SizedBox(height: 10.h),

        EditProfileFieldLabel('edit_profile.national_id'.tr()),
        EditProfileTextField(
          controller: nationalIdController,
          hintText: 'edit_profile.national_id'.tr(),
          keyboardType: TextInputType.number,
          maxLength: 14,
          focusNode: nationalIdFocusNode,
          autovalidateMode: nationalIdAutovalidate,
          inputFormatters: digitsFormatters,
          validator: nationalIdValidator,
        ),
        SizedBox(height: 14.h),

        EditProfileFieldLabel('edit_profile.passport_number'.tr()),
        EditProfileTextField(
          controller: passportNumberController,
          hintText: 'edit_profile.passport_number'.tr(),
          required: false,
          focusNode: passportNumberFocusNode,
          autovalidateMode: passportNumberAutovalidate,
        ),
        SizedBox(height: 14.h),

        EditProfileFieldLabel('edit_profile.phone_number'.tr()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.exactFFF1F5F9,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: kAuthBorderColor),
              ),
              alignment: Alignment.center,
              child: Text(
                '+20',
                style: AppTextStyles.of(
                  fontSize: 15.sp,
                  color: AppColors.inkMutedClr,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: EditProfileTextField(
                controller: phoneNumberController,
                hintText: 'edit_profile.phone_number'.tr(),
                keyboardType: TextInputType.phone,
                maxLength: 11,
                focusNode: phoneNumberFocusNode,
                autovalidateMode: phoneNumberAutovalidate,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: phoneNumberValidator,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        EditProfileFieldLabel('edit_profile.date_of_birth'.tr()),
        EditBirthDateField(
          controller: birthDateController,
          isEmpty: birthDateIsEmpty,
          onTap: onSelectBirthDate,
        ),
        SizedBox(height: 14.h),

        EditProfileFieldLabel('edit_profile.gender'.tr()),
        EditProfileGenderDropdown(isMale: isMale, onChanged: onGenderChanged),

        SizedBox(height: 32.h),
      ],
    );
  }
}

/// Read-only birth-date picker field.
class EditBirthDateField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEmpty;
  final VoidCallback onTap;

  const EditBirthDateField({
    super.key,
    required this.controller,
    required this.isEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          style: AppTextStyles.of(
            fontSize: 15.sp,
            color: isEmpty ? AppColors.exactFFB0B8C1 : AppColors.inkClr,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          decoration: authInputDecoration(
            hintText: 'edit_profile.date_of_birth'.tr(),
          ).copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: kAuthGreyText,
              size: 18,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'common.required'.tr();
            }
            return null;
          },
        ),
      ),
    );
  }
}

