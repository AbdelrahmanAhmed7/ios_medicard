import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';
import 'profile_avatar.dart';
import '../../data/models/profile_response_model.dart';
import '../cubit/profile_cubit.dart';

class ProfileUserInfoCard extends StatelessWidget {
  final ProfileData data;
  const ProfileUserInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data.imageUrl;

    return Padding(
      padding: AppSpacing.pageHorizontalInsets,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  ProfileAvatar(imageUrl: imageUrl),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            data.firstName?.trim(),
                            data.lastName?.trim(),
                          ].where((s) => s != null && s.isNotEmpty).join(' '),
                          style: AppTextStyles.of(
                            color: Colors.black,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 12.h,
              end: 12.w,
              child: GestureDetector(
                onTap: () {
                  context.push(
                    '/medicard-edit-profile-new',
                    extra: {
                      'profileData': data,
                      'profileCubit': context.read<ProfileCubit>(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.black54,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
