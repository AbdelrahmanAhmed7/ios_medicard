import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_spacing.dart';

class ProfileCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageHorizontalInsets,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
