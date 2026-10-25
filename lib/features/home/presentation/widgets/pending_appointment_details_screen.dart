import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_date_formatter.dart';
import '../../domain/models/appointment_model.dart';

import '../../../../core/theming/app_text_styles.dart';

class PendingAppointmentDetailsScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const PendingAppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final hasDate = appointment.date.isNotEmpty;
    final hasService = appointment.service.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppHeaderBackButton(
                    color: const Color(0xFF111827),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'activity.appointment_details'.tr(),
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
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE5E9F0)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            _buildProviderAvatar(),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.providerName,
                                    style: AppTextStyles.of(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (appointment.branch.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      appointment.branch,
                                      style: AppTextStyles.of(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _StatusBadge(status: appointment.status),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEF1F5)),
                      if (hasDate)
                        _InfoRow(
                          label: 'activity.date'.tr(),
                          value:
                              '${AppDateFormatter.formatDate(appointment.date, context.locale.languageCode)}\n'
                              '${AppDateFormatter.formatTime(appointment.date, context.locale.languageCode)}',
                        ),
                      if (hasDate && hasService)
                        const Divider(height: 1, color: Color(0xFFEEF1F5)),
                      if (hasService)
                        _InfoRow(
                          label: 'activity.service'.tr(),
                          value: appointment.service,
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

  Widget _buildProviderAvatar() {
    final logoUrl = appointment.providerLogoUrl;
    if (logoUrl.isEmpty) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: Color(0xFFEEF3FB),
        child: Icon(Icons.local_hospital, color: Color(0xFF3872B1)),
      );
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFFFFFFF),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: const Color(0xFFEEF3FB)),
          errorWidget: (context, url, error) =>
              const Icon(Icons.local_hospital, color: Color(0xFF3872B1)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isCancelled = normalized == 'canceled' ||
        normalized == 'cancelled' ||
        normalized == 'ملغاة';
    final isCompleted = normalized == 'completed' ||
        normalized == 'used' ||
        normalized == 'مكتملة' ||
        normalized == 'مستخدمة';
    final isPaid = normalized == 'paid' || normalized == 'مدفوعة';
    final color = isCancelled
        ? const Color(0xFFDC2626)
        : (isCompleted || isPaid)
            ? const Color(0xFF0F8A5F)
            : const Color(0xFF9A6A00);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        _localizedStatus(status),
        style: AppTextStyles.of(fontSize: 13.sp, color: color),
      ),
    );
  }

  String _localizedStatus(String status) {
    return switch (status.trim().toLowerCase()) {
      'pending' || '2' || 'قيد الانتظار' || 'في الانتظار' || 'معلق' =>
        'home.pending'.tr(),
      'completed' || 'مكتملة' => 'home.completed'.tr(),
      'used' || 'مستخدمة' => 'activity.status_used'.tr(),
      'paid' || 'مدفوعة' => 'activity.status_paid'.tr(),
      'canceled' || 'cancelled' || 'ملغاة' => 'activity.status_cancelled'.tr(),
      _ => status,
    };
  }
}
