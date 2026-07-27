import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/appointment_model.dart';

class PendingAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const PendingAppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final providerId = appointment.providerId;
        if (providerId != null) {
          context.push('/provider-page', extra: providerId);
        }
      },
      child: Container(
        width: 303,
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
              const SizedBox(width: 12),
              // فاصل رأسي أنيق يفصل بين لوجو العيادة وبين البيانات
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appointment.providerName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
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
                        style: const TextStyle(
                          fontFamily: 'Inter',
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
                        style: const TextStyle(
                          fontFamily: 'Inter',
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
                  constraints: const BoxConstraints(maxWidth: 76),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (appointment.status.isNotEmpty)
                        _StatusBadge(status: appointment.status),
                      if (appointment.status.isNotEmpty &&
                          appointment.date.isNotEmpty)
                        const SizedBox(height: 6),
                      if (appointment.date.isNotEmpty)
                        Text(
                          appointment.date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x26F5A623),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5A623), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 12, color: Color(0xFFF5A623)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFFF5A623),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
