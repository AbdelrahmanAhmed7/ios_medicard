import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medicard/core/widgets/app_blue_header.dart';
import '../cubit/profile_cubit.dart';
import 'profile_content.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ProfileErrorView extends StatelessWidget {
  final String error;

  const ProfileErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBlueHeader(
            title: 'profile.my_profile'.tr(),
            showBack: false,
            contentHeight: kMainTabHeaderContentHeight,
          ),
          SizedBox(height: 40.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.exactFF9CA3AF,
                  size: 48.sp,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    error.isEmpty ? 'errors.something_went_wrong'.tr() : error,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(color: AppColors.exactFF6B7280),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => context.read<ProfileCubit>().loadProfile(
                    forceRefresh: true,
                  ),
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: OutlinedButton(
              onPressed: () => showLogoutConfirmation(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.materialRed, width: 1.2),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.materialRed, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'common.logout'.tr(),
                    style: AppTextStyles.of(
                      color: AppColors.materialRed,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h + bottomPadding),
        ],
      ),
    );
  }
}

