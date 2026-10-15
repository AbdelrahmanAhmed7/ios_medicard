import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/url_launcher_service.dart';

import '../../../../core/theming/app_text_styles.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _email = 'info@medicardeg.com';
  static const _phone = '01205893702';
  static const _whatsApp = '01205893702';
  static const _website = 'https://www.medicardeg.com';

  @override
  Widget build(BuildContext context) {
    final launcher = UrlLauncherService();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: const Color(0xFF111827),
                      size: 22.sp,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'profile.help_center'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                8.w,
                24.h,
                8.w,
                24.h + bottomPadding,
              ),
              children: [
                // Intro row (no card)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: const Color(0xFF3872B1),
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        'help_center.subtitle'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                Text(
                  'help_center.contact_us'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 4.h),

                // Contact tiles grouped in a card like the other pages.
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Phone
                      _ContactTile(
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                        label: 'help_center.phone'.tr(),
                        value: _phone,
                        onTap: () => launcher.makePhoneCall(_phone),
                      ),

                      // WhatsApp
                      _ContactTile(
                        icon: Icons.chat_rounded,
                        iconColor: const Color(0xFF25D366),
                        bgColor: const Color(0xFFF0FDF4),
                        label: 'help_center.whatsapp'.tr(),
                        value: _whatsApp,
                        onTap: () => launcher.launchWhatsApp(
                          _whatsApp,
                          message: 'help_center.whatsapp_message'.tr(),
                        ),
                      ),

                      // Email
                      _ContactTile(
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFF3872B1),
                        bgColor: const Color(0xFFEFF6FF),
                        label: 'help_center.email'.tr(),
                        value: _email,
                        onTap: () => launcher.launchEmail(
                          _email,
                          subject: 'help_center.email_subject'.tr(),
                        ),
                      ),

                      // Website
                      _ContactTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        bgColor: const Color(0xFFF5F3FF),
                        label: 'help_center.website'.tr(),
                        value: _website,
                        showDivider: false,
                        onTap: () => launcher.launchURL(_website),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final bool showDivider;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    this.showDivider = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 13.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(9.r),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.of(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        value,
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}
