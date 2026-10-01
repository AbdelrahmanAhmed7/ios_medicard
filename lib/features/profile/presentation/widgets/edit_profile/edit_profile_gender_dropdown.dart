import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

/// Gender dropdown. Pure given [isMale]; the screen owns the state.
class EditProfileGenderDropdown extends StatelessWidget {
  final bool? isMale;
  final ValueChanged<bool?> onChanged;

  const EditProfileGenderDropdown({
    super.key,
    required this.isMale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<bool>(
      initialValue: isMale,
      hint: Text(
        'edit_profile.select_an_option'.tr(),
        style: AppTextStyles.of(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
      ),
      style: AppTextStyles.of(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade500,
        size: 20.sp,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: kAuthBlue, width: 1.2),
        ),
      ),
      items: [
        DropdownMenuItem(value: true, child: Text('edit_profile.male'.tr())),
        DropdownMenuItem(
          value: false,
          child: Text('edit_profile.female'.tr()),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
