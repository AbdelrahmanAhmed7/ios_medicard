
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medicard/core/cubit/localization_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';

class ProfileLanguageItem extends StatelessWidget {
  final ProfileData data;

  const ProfileLanguageItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    final currentLanguage = currentLocale == 'ar'
        ? 'profile.arabic'.tr()
        : 'profile.english'.tr();
    final label = 'profile.language'.tr();

    return InkWell(
      onTap: () async {
        final newLanguage = currentLocale == 'ar' ? 'en' : 'ar';
        if (context.mounted) {
          await context.read<LocalizationCubit>().changeLanguage(
            context,
            newLanguage,
          );
        }
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.language_outlined, size: 22.sp, color: Colors.black87),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.of(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLanguage,
                  style: AppTextStyles.of(color: kAuthGreyText, fontSize: 14.sp),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kAuthGreyText,
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
