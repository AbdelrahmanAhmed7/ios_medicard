import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'edit_profile_labels.dart';
import 'edit_profile_text_field.dart';

/// First + last name row. Controllers and focus wiring come from the screen.
class EditNameRow extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final FocusNode? firstNameFocusNode;
  final FocusNode? lastNameFocusNode;
  final AutovalidateMode firstNameAutovalidate;
  final AutovalidateMode lastNameAutovalidate;
  final String? Function(String?) nameValidator;
  final List<TextInputFormatter> lettersFormatters;

  const EditNameRow({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.firstNameAutovalidate,
    required this.lastNameAutovalidate,
    required this.nameValidator,
    required this.lettersFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditProfileFieldLabel('edit_profile.name'.tr()),
              EditProfileTextField(
                controller: firstNameController,
                hintText: 'edit_profile.first_name'.tr(),
                validator: nameValidator,
                focusNode: firstNameFocusNode,
                autovalidateMode: firstNameAutovalidate,
                inputFormatters: lettersFormatters,
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditProfileFieldLabel('edit_profile.last_name'.tr()),
              EditProfileTextField(
                controller: lastNameController,
                hintText: 'edit_profile.last_name'.tr(),
                validator: nameValidator,
                focusNode: lastNameFocusNode,
                autovalidateMode: lastNameAutovalidate,
                inputFormatters: lettersFormatters,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
