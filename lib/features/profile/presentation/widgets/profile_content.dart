import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/cubit/localization_cubit.dart';
import 'package:medicard/core/helpers/shared_pref_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';

class ProfileContent extends StatelessWidget {
  final ProfileData data;

  const ProfileContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: kAuthBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(
              20.w,
              statusBarHeight + 40.h,
              20.w,
              24.h,
            ),
            child: Text(
              'profile.my_profile'.tr(),
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          _UserInfoCard(data: data),

          SizedBox(height: 20.h),

          _SectionTitle(title: 'profile.settings'.tr()),
          _Card(
            children: [
              _Item(
                icon: Icons.person_outline_rounded,
                label: 'profile.my_profile_link'.tr(),
                route: '/medicard-edit-profile-new',
                routeExtra: {'profileData': data},
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
                icon: Icons.badge_outlined,
                label: 'profile.rewards'.tr(),
                trailing: Text(
                  '100 points',
                  style: TextStyle(
                    color: kAuthGreyText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
                icon: Icons.people_outline_rounded,
                label: 'profile.family_members'.tr(),
                route: '/family-members',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _LanguageItem(data: data),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
                icon: Icons.lock_outline_rounded,
                label: 'profile.change_password'.tr(),
                route: '/change-password',
              ),
            ],
          ),

          _SectionTitle(title: 'profile.links'.tr()),
          _Card(
            children: [
              _Item(
                label: 'profile.help_center'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
                label: 'profile.terms_of_service'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                route: '/terms-and-conditions',
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
                label: 'profile.privacy_policy'.tr(),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 20.sp,
                ),
                route: '/privacy-policy',
              ),
              const Divider(color: kAuthBorderColor, height: 1),
              _Item(
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: OutlinedButton(
              onPressed: () {
                // Logic حذف الحساب
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kAuthBlue, width: 1.2),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'common.delete_account'.tr(),
                style: TextStyle(
                  color: kAuthBlue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: OutlinedButton(
              onPressed: () async {
                await SharedPrefHelper.clearAllSecuredData();
                await SharedPrefHelper.removeData(
                  SharedPrefKeys.medicardCardNo,
                );
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

class _UserInfoCard extends StatelessWidget {
  final ProfileData data;
  const _UserInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imageUrl;
    final hasImage =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        Uri.parse(imageUrl).pathSegments.where((s) => s.isNotEmpty).isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  hasImage
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 64.r,
                            height: 64.r,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 32.r,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 32.r,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.firstName ?? 'Ahmed'} ${data.lastName ?? 'Mohamed'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'profile.standard_plan'.tr(),
                          style: TextStyle(
                            color: kAuthGreyText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 12.h,
              end: 12.w,
              child: GestureDetector(
                onTap: () {
                  context.push(
                    '/medicard-edit-profile-new',
                    extra: {'profileData': data},
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.black54,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 20.w, top: 16.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget? trailing;
  final String? route;
  final Map<String, dynamic>? routeExtra;

  const _Item({
    this.icon,
    required this.label,
    this.trailing,
    this.route,
    this.routeExtra,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route != null
          ? () {
              if (routeExtra != null) {
                context.push(route!, extra: routeExtra);
              } else {
                context.push(route!);
              }
            }
          : () {},
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon!, size: 22.sp, color: Colors.black87),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  final ProfileData data;

  const _LanguageItem({required this.data});

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
                style: TextStyle(
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
                  style: TextStyle(color: kAuthGreyText, fontSize: 14.sp),
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
