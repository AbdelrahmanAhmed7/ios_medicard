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
      onTap: () => _showLanguageSheet(context, currentLocale),
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
                  style: AppTextStyles.of(
                    color: kAuthGreyText,
                    fontSize: 14.sp,
                  ),
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

  /// Language picker bottom sheet — the change applies only after Apply.
  Future<void> _showLanguageSheet(BuildContext context, String current) async {
    var selected = current;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Widget option(String code, String name) {
              final isSelected = selected == code;
              return GestureDetector(
                onTap: () => setSheetState(() => selected = code),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 13.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3872B1)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.of(
                            fontSize: 15.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20.sp,
                          color: const Color(0xFF3872B1),
                        ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'profile.language'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    option('ar', 'profile.arabic'.tr()),
                    SizedBox(height: 10.h),
                    option('en', 'profile.english'.tr()),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              minimumSize: Size.fromHeight(48.h),
                            ),
                            child: Text('common.cancel'.tr()),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(selected),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3872B1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              minimumSize: Size.fromHeight(48.h),
                            ),
                            child: Text('common.apply'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null && picked != current && context.mounted) {
      await context.read<LocalizationCubit>().changeLanguage(context, picked);
    }
  }
}
