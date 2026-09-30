import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/auth/auth_session_storage.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/cubit/localization_cubit.dart';
import 'package:medicard/core/helpers/shared_pref_helper.dart';
import 'package:medicard/core/network/dio_factory.dart';
import 'package:medicard/core/widgets/app_blue_header.dart';

import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';
import '../cubit/profile_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';


class ProfileContent extends StatelessWidget {
  final ProfileData data;

  const ProfileContent({super.key, required this.data});

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

          SizedBox(height: 20.h),

          _UserInfoCard(data: data),

          if (data.cardNumber == null || data.cardNumber!.trim().isEmpty) ...[
            SizedBox(height: 20.h),
            _ActivateCardBanner(data: data),
          ],

          SizedBox(height: 20.h),

          _SectionTitle(title: 'profile.settings'.tr()),
          _Card(
            children: [
              _Item(
                icon: Icons.point_of_sale,
                label: 'profile.rewards'.tr(),
                trailing: Text(
                  'profile.points_count'.tr(args: ['100']),
                  style: AppTextStyles.of(
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
                route: '/help-center',
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
                style: AppTextStyles.of(
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

class _UserInfoCard extends StatelessWidget {
  final ProfileData data;
  const _UserInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imageUrl;

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
                  _ProfileAvatar(imageUrl: imageUrl),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            data.firstName?.trim(),
                            data.lastName?.trim(),
                          ].where((s) => s != null && s.isNotEmpty).join(' '),
                          style: AppTextStyles.of(
                            color: Colors.black,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'profile.standard_plan'.tr(),
                          style: AppTextStyles.of(
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
                    extra: {
                      'profileData': data,
                      'profileCubit': context.read<ProfileCubit>(),
                    },
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

class _ActivateCardBanner extends StatelessWidget {
  final ProfileData data;

  const _ActivateCardBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: InkWell(
        onTap: () => _showActivateCardDialog(context, data),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF1FB),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: kAuthBlue, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: const BoxDecoration(
                  color: kAuthBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.activate_card'.tr(),
                      style: AppTextStyles.of(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'profile.activate_card_subtitle'.tr(),
                      style: AppTextStyles.of(
                        color: kAuthGreyText,
                        fontSize: 12.5.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: kAuthBlue, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showActivateCardDialog(
  BuildContext context,
  ProfileData data,
) async {
  final cardNumber = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const _CardNumberInputSheet(),
  );

  if (cardNumber == null || !context.mounted) return;
  await context.read<ProfileCubit>().activateMemberCard(
    cardNumber: cardNumber,
    currentData: data,
  );
}

class _CardNumberInputSheet extends StatefulWidget {
  const _CardNumberInputSheet();

  @override
  State<_CardNumberInputSheet> createState() => _CardNumberInputSheetState();
}

class _CardNumberInputSheetState extends State<_CardNumberInputSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  String? _validateCardNumber(String? value) {
    final cardNumber = value?.trim() ?? '';
    if (cardNumber.isEmpty) return 'auth.login.cardNumberRequired'.tr();
    if (!RegExp(r'^[0-9]{12}$').hasMatch(cardNumber)) {
      return 'auth.login.cardNumberInvalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          18.h,
          20.w,
          20.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: 54.r,
              height: 54.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEBF1FB),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.credit_card, color: kAuthBlue, size: 26.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              'profile.activate_card'.tr(),
              style: AppTextStyles.of(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'profile.activate_card_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                height: 1.35,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 20.h),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                autovalidateMode: AutovalidateMode.disabled,
                decoration: InputDecoration(
                  labelText: 'profile.card_number'.tr(),
                  hintText: 'profile.card_number_hint'.tr(),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: kAuthBlue, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: _validateCardNumber,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAuthBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size.fromHeight(50.h),
                ),
                child: Text(
                  'profile.activate_card'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size.fromHeight(48.h),
                ),
                child: Text(
                  'common.cancel'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
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

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();
    if (image == null || image.isEmpty) return _fallbackAvatar();

    final file = File(image);
    if (!image.startsWith('http') && file.existsSync()) {
      return ClipOval(
        child: Image.file(file, width: 64.r, height: 64.r, fit: BoxFit.cover),
      );
    }

    final uri = Uri.tryParse(image);
    final hasRemoteImage =
        uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.pathSegments.where((s) => s.isNotEmpty).isNotEmpty;

    if (!hasRemoteImage) return _fallbackAvatar();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: 64.r,
        height: 64.r,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) => _fallbackAvatar(),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: 32.r,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, color: Colors.white, size: 32.sp),
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
        style: AppTextStyles.of(
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

  const _Item({this.icon, required this.label, this.trailing, this.route})
    : routeExtra = null;

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
                style: AppTextStyles.of(
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
    await const AuthSessionStorage().clearSession();
    await SharedPrefHelper.removeData(SharedPrefKeys.medicardCardNo);
    DioFactory.clearTokenFromHeader();
    if (context.mounted) context.go('/medicard-login');
  }
}
