import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../activity/domain/models/invoice_item.dart';
import '../../domain/models/appointment_model.dart';

import '../../../../core/theming/app_text_styles.dart';

class PendingAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const PendingAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Full invoice details by id when available; otherwise the static
        // appointment page.
        final invoiceId = appointment.invoiceId;
        if (invoiceId != null) {
          context.push(
            '/invoice-details',
            extra: {
              'invoice': InvoiceItem(
                invoiceId: invoiceId,
                providerName: appointment.providerName,
                branchName: appointment.branch,
                status: appointment.status,
                date: DateTime.tryParse(appointment.date) ?? DateTime.now(),
                providerImageUrl: appointment.providerLogoUrl.isEmpty
                    ? null
                    : appointment.providerLogoUrl,
              ),
              'tab': 1,
            },
          );
          return;
        }
        context.push('/pending-appointment-details', extra: appointment);
      },
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15), // حل مشكلة الحواف البيضاء
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFFFFF),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: appointment.providerLogoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: const Color(0xFFEEF3FB)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // فاصل رأسي أنيق يفصل بين لوجو العيادة وبين البيانات
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appointment.providerName,
                      style: AppTextStyles.of(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (appointment.service.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        appointment.service,
                        style: AppTextStyles.of(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (appointment.branch.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        appointment.branch,
                        style: AppTextStyles.of(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (appointment.status.isNotEmpty || appointment.date.isNotEmpty)
                const SizedBox(width: 8),
              if (appointment.status.isNotEmpty || appointment.date.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 115),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (appointment.status.isNotEmpty)
                        _StatusBadge(status: appointment.status),
                      if (appointment.status.isNotEmpty &&
                          appointment.date.isNotEmpty)
                        const SizedBox(height: 4),
                      _buildDateSection(context),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    if (appointment.date.isEmpty) return const SizedBox.shrink();

    final parsed = AppDateFormatter.tryParse(appointment.date);
    final locale = context.locale.languageCode;
    final String dateText;
    final String? timeText;

    if (parsed != null) {
      dateText = AppDateFormatter.formatDate(appointment.date, locale);
      final hasTime = appointment.date.contains(':') ||
          parsed.hour != 0 ||
          parsed.minute != 0;
      timeText =
          hasTime ? AppDateFormatter.formatTime(appointment.date, locale) : null;
    } else {
      dateText = appointment.date;
      timeText = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dateText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.of(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (timeText != null && timeText.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            timeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.of(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final isCancelled = _isCancelled(status);
    final isCompleted = _isCompleted(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withAlpha(0x22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(0x77), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCancelled
                ? Icons.cancel_outlined
                : isCompleted
                    ? Icons.check_circle_outline
                    : Icons.access_time,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _localizedStatus(status),
            maxLines: 1,
            style: AppTextStyles.of(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCancelled(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'canceled' ||
        normalized == 'cancelled' ||
        normalized == 'ملغاة';
  }

  bool _isCompleted(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'completed' ||
        normalized == 'used' ||
        normalized == 'مكتملة' ||
        normalized == 'مستخدمة' ||
        normalized == 'paid' ||
        normalized == 'مدفوعة';
  }

  Color _statusColor(String status) {
    if (_isCancelled(status)) return const Color(0xFFDC2626);
    if (_isCompleted(status)) return const Color(0xFF0F8A5F);
    return const Color(0xFFB45309);
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
