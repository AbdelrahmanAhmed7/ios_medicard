import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/profile_cubit.dart';

class ProfileErrorView extends StatelessWidget {
  const ProfileErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: const Color(0xFF9CA3AF), size: 48.sp),
          SizedBox(height: 12.h),
          Text('Failed to load profile',
            style: TextStyle(color: const Color(0xFF6B7280))),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
