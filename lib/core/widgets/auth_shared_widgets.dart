import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';

import '../theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
// ── Design tokens ────────────────────────────────────────────────────────────

const kAuthBlue = AppColors.brandBlueClr;
const kAuthInk = AppColors.exactFF0F172A;
const kAuthBorderColor = AppColors.exactFFE5E7EB;
const kAuthGreyText = AppColors.exactFF6B7280;
const kAuthBackground = AppColors.whiteClr;
const kAuthFieldBackground = AppColors.exactFFF8FAFC;

// ── AuthFieldLabel ────────────────────────────────────────────────────────────

class AuthFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const AuthFieldLabel(this.text, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.of(
      fontSize: 13.sp,
      color: AppColors.exactFF334155,
      fontWeight: FontWeight.w600,
    );

    return RichText(
      text: TextSpan(
        text: text,
        style: labelStyle,
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: labelStyle.copyWith(
                color: AppColors.materialRed,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ── AuthGenderOption ──────────────────────────────────────────────────────────

class AuthGenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AuthGenderOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? kAuthBlue : AppColors.exactFF9CA3AF,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: const BoxDecoration(
                        color: kAuthBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyles.of(
              fontSize: 14.sp,
              color: selected ? AppColors.materialBlack : kAuthGreyText,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── authInputDecoration ───────────────────────────────────────────────────────

InputDecoration authInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    counterText: '',
    hintStyle: AppTextStyles.of(
      fontSize: 14.sp,
      color: AppColors.exactFFB0B8C1,
    ),
    filled: true,
    fillColor: kAuthFieldBackground,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    errorMaxLines: 2,
    errorStyle: AppTextStyles.of(
      fontSize: 11.5.sp,
      color: AppColors.exactFFDC2626,
      height: 1.25,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: kAuthBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: kAuthBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: kAuthBlue, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: AppColors.exactFFEF4444),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: AppColors.exactFFEF4444, width: 1.6),
    ),
  );
}

// ── AuthHeader ────────────────────────────────────────────────────────────────

class AuthHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  final String logoAsset;
  final String title;

  const AuthHeader({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.logoAsset = AppAssets.mediLogo,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.whiteClr,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: showBackButton
              ? AppHeaderSpacing.padding(top: 9.h, bottom: 9.h)
              : EdgeInsets.fromLTRB(8.w, 9.h, 8.w, 9.h),
          child: Row(
            children: [
              if (showBackButton)
                AppHeaderBackButton(onPressed: onBack, color: kAuthInk)
              else
                SizedBox(width: 42.r, height: 42.r),
              Expanded(
                child: Row(
                  mainAxisAlignment: showBackButton
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: AppColors.exactFFEFF6FF,
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Image.asset(logoAsset, fit: BoxFit.contain),
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.of(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: kAuthInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!showBackButton) SizedBox(width: 42.r, height: 42.r),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AuthContentCard ──────────────────────────────────────────────────────────

class AuthContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AuthContentCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 32.h),
      child: child,
    );
  }
}

class AuthSectionIntro extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthSectionIntro({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.of(
            fontSize: 23.sp,
            fontWeight: FontWeight.w700,
            color: kAuthInk,
            height: 1.25,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          SizedBox(height: 7.h),
          Text(
            subtitle!,
            style: AppTextStyles.of(
              fontSize: 13.5.sp,
              color: kAuthGreyText,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool tonal;

  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tonal = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tonal ? AppColors.inkSoftClr : kAuthBlue,
          backgroundColor: tonal ? AppColors.exactFFF1F5F9 : AppColors.whiteClr,
          side: BorderSide(
            color: tonal ? AppColors.lineClr : kAuthBlue,
            width: tonal ? 1 : 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19.sp),
        label: Text(
          label,
          style: AppTextStyles.of(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.lineClr)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: AppTextStyles.of(fontSize: 12.5.sp, color: kAuthGreyText),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.lineClr)),
      ],
    );
  }
}

// ── AuthPrimaryButton ─────────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAuthBlue,
          disabledBackgroundColor: AppColors.exactFF9DB7D4,
          foregroundColor: AppColors.whiteClr,
          disabledForegroundColor: AppColors.whiteClr,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 1,
          shadowColor: kAuthBlue.withValues(alpha: 0.28),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.whiteClr,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteClr,
                ),
              ),
      ),
    );
  }
}

