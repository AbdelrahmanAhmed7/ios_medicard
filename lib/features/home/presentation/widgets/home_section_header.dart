import 'package:flutter/material.dart';

/// Reusable section header: "Title  ›"
/// Used by Pending Appointments, Nearest Providers, Featured Services.
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const HomeSectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 22,
                  color: onViewAll != null
                      ? const Color(0xFF2D5FA6)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
