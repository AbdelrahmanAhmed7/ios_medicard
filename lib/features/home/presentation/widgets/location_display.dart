import 'package:flutter/material.dart';

import '../../../../core/theming/app_text_styles.dart';


class LocationDisplay extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const LocationDisplay({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.of(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}
