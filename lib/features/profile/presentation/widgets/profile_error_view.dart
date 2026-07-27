import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/auth/auth_session_storage.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/helpers/shared_pref_helper.dart';
import 'package:medicard/core/network/dio_factory.dart';
import 'package:medicard/core/widgets/app_blue_header.dart';
import '../cubit/profile_cubit.dart';

class ProfileErrorView extends StatelessWidget {
  const ProfileErrorView({super.key});

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
                  color: const Color(0xFF9CA3AF),
                  size: 48.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  'errors.something_went_wrong'.tr(),
                  style: TextStyle(color: const Color(0xFF6B7280)),
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
              onPressed: () async {
                await const AuthSessionStorage().clearSession();
                await SharedPrefHelper.removeData(
                  SharedPrefKeys.medicardCardNo,
                );
                DioFactory.clearTokenFromHeader();
                if (context.mounted) context.go('/medicard-login');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.2),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'common.logout'.tr(),
                    style: TextStyle(
                      color: Colors.red,
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
