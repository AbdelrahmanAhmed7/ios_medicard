import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/appointment_model.dart';
import 'home_section_header.dart';
import 'pending_appointment_card.dart';

class PendingAppointmentsSection extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final VoidCallback? onViewAll;

  const PendingAppointmentsSection({
    super.key,
    required this.appointments,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'home.pending_appointments'.tr(), onViewAll: onViewAll),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                PendingAppointmentCard(appointment: appointments[i]),
          ),
        ),
      ],
    );
  }
}
