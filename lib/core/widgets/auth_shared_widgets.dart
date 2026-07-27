import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_assets.dart';

// ── Design tokens ────────────────────────────────────────────────────────────

const kAuthBlue = Color(0xFF3872B1);
const kAuthBorderColor = Color(0xFFE5E7EB);
const kAuthGreyText = Color(0xFF6B7280);
const kAuthBackground = Color(0xFFF5F7FA);

// ── AuthFieldLabel ────────────────────────────────────────────────────────────

class AuthFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const AuthFieldLabel(this.text, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 13.sp,
      color: kAuthGreyText,
      fontWeight: FontWeight.w500,
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
                color: Colors.red,
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
                color: selected ? kAuthBlue : const Color(0xFF9CA3AF),
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
            style: TextStyle(
              fontSize: 14.sp,
              color: selected ? Colors.black : kAuthGreyText,
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
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFFB0B8C1)),
    filled: true,
    fillColor: Colors.white,
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: kAuthBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: kAuthBorderColor),
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
  );
}

// ── AuthBlueHeader ────────────────────────────────────────────────────────────

class AuthBlueHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  final String logoAsset;
  final String title;

  const AuthBlueHeader({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.logoAsset = AppAssets.mediLogo,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kAuthBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(28.w, statusBarHeight + 32.h, 28.w, 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
          Image.asset(
            logoAsset,
            width: 72.w,
            height: 72.w,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
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
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAuthBlue,
          disabledBackgroundColor: kAuthBlue.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
