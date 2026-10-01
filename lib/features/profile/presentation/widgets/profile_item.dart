
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';

class ProfileItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget? trailing;
  final String? route;
  final Map<String, dynamic>? routeExtra;

  const ProfileItem({super.key,this.icon, required this.label, this.trailing, this.route})
    : routeExtra = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route != null
          ? () {
              if (routeExtra != null) {
                context.push(route!, extra: routeExtra);
              } else {
                context.push(route!);
              }
            }
          : () {},
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 54.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon!, size: 22.sp, color: Colors.black87),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.of(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
