import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/widgets/app_simple_header.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';
import '../../data/models/profile_summary_response_model.dart';
import '../cubit/profile_cubit.dart';
import 'activate_card_banner.dart';
import 'profile_card.dart';
import 'profile_item.dart';
import 'profile_language_item.dart';
import 'profile_section_title.dart';
import 'profile_user_info_card.dart';

class ProfileContent extends StatelessWidget {
  final ProfileData data;

  final ProfileSummaryData? summary;

  const ProfileContent({super.key, required this.data, this.summary});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSimpleHeader(title: 'profile.my_profile'.tr(), showBack: false),

          SizedBox(height: 10.h),

          ProfileUserInfoCard(data: data),

          if (data.cardNumber == null || data.cardNumber!.trim().isEmpty) ...[
            SizedBox(height: 20.h),
            ActivateCardBanner(data: data),
          ],

          SizedBox(height: 20.h),

          ProfileSectionTitle(title: 'profile.settings'.tr()),
          ProfileCard(
            children: [
              ProfileItem(
                icon: Icons.point_of_sale,
                label: 'profile.rewards'.tr(),
                trailing: Text(
                  'profile.points_count'.tr(
                    args: ['${summary?.rewardPoints ?? 0}'],
                  ),
                  style: AppTextStyles.of(
                    color: kAuthGreyText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                icon: Icons.people_outline_rounded,
                label: 'profile.family_members'.tr(),
                route: '/family-members',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary?.familyMembersCount ?? 0}',
                      style: AppTextStyles.of(
                        color: kAuthGreyText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black54,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                icon: Icons.location_on_outlined,
                label: 'profile.my_addresses'.tr(),
                route: '/addresses',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                icon: Icons.badge_outlined,
                label: 'profile.digital_membership'.tr(),
                route: '/digital-membership',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileLanguageItem(data: data),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                icon: Icons.lock_outline_rounded,
                label: 'profile.change_password'.tr(),
                route: '/change-password',
              ),
            ],
          ),

          ProfileSectionTitle(title: 'profile.links'.tr()),
          ProfileCard(
            children: [
              ProfileItem(
                label: 'profile.help_center'.tr(),
                route: '/help-center',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                label: 'profile.terms_of_service'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                route: '/terms-and-conditions',
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                label: 'profile.privacy_policy'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                route: '/privacy-policy',
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              ProfileItem(
                label: 'profile.refund_policy'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                route: '/refund-policy',
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Padding(
            padding: AppSpacing.pageHorizontalInsets,
            child: OutlinedButton(
              onPressed: () {
                // Logic حذف الحساب
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'common.delete_account'.tr(),
                style: AppTextStyles.of(
                  color: const Color(0xFFDC2626),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: AppSpacing.pageHorizontalInsets,
            child: OutlinedButton(
              onPressed: () => showLogoutConfirmation(context),
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
                    style: AppTextStyles.of(
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

/// Shows a confirmation bottom sheet before logging out.
/// Extracted as a top-level function so it can be reused from
/// [ProfileContent] and [ProfileErrorView].
Future<void> showLogoutConfirmation(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 18.h),
              // Icon
              Container(
                width: 54.r,
                height: 54.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'common.logout_confirm_title'.tr(),
                style: AppTextStyles.of(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'common.logout_confirm_message'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  height: 1.35,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: Text('common.cancel'.tr()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: Text('common.logout'.tr()),
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

  if (confirmed == true && context.mounted) {
    await context.read<ProfileCubit>().logout();
    if (context.mounted) context.go('/medicard-login');
  }
}
