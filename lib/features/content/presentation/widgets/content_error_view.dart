import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';

class ContentErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ContentErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            height: 80.h + statusBarHeight,
            color: const Color(0xFF2D5FA6),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 64.sp,
                      color: const Color(0xFF2D5FA6),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'home.something_went_wrong'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: AuthPrimaryButton(
                        onPressed: onRetry,
                        label: 'common.try_again'.tr(),
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
