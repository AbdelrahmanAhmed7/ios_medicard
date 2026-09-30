import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/widgets/app_blue_header.dart';

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
          AppBlueHeader(title: 'profile.help_center'.tr()),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h + bottomPadding),
              children: [
                // Intro card
                _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'help_center.title'.tr(),
                                  style: AppTextStyles.of(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'help_center.subtitle'.tr(),
                                  style: AppTextStyles.of(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                SizedBox(height: 12.h),

                // Phone
                _ContactTile(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                  label: 'help_center.phone'.tr(),
                  value: _phone,
                  onTap: () => launcher.makePhoneCall(_phone),
                ),
                SizedBox(height: 10.h),

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
                SizedBox(height: 10.h),

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
                SizedBox(height: 10.h),

                // Website
                _ContactTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                  label: 'help_center.website'.tr(),
                  value: _website,
                  onTap: () => launcher.launchURL(_website),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

// ─── Contact Tile ─────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.sp),
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
      ),
    );
  }
}
