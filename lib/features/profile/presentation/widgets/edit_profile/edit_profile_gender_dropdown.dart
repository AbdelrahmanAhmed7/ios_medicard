import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/app_dropdown_menu_item.dart';
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
    return AppDropdownTheme(
      child: DropdownButtonFormField<bool>(
        initialValue: isMale,
        isExpanded: true,
        hint: Text(
          'edit_profile.select_an_option'.tr(),
          style: AppTextStyles.of(
            fontSize: 14.sp,
            color: AppColors.exactFFB0B8C1,
            fontWeight: FontWeight.w400,
          ),
        ),
        style: AppTextStyles.of(
          fontSize: 15.sp,
          color: AppColors.inkClr,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        dropdownColor: AppDropdownTheme.menuColor,
        elevation: AppDropdownTheme.menuElevation.toInt(),
        borderRadius: AppDropdownTheme.dropdownBorderRadius,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.inkMutedClr,
          size: 20,
        ),
        decoration: authInputDecoration(
          hintText: 'edit_profile.select_an_option'.tr(),
        ),
        items: [
          AppDropdownMenuItem<bool>(
            value: true,
            label: 'edit_profile.male'.tr(),
          ),
          AppDropdownMenuItem<bool>(
            value: false,
            label: 'edit_profile.female'.tr(),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

