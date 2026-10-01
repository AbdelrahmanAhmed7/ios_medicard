
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import 'card_number_input_sheet.dart';
import '../../data/models/profile_response_model.dart';

class ActivateCardBanner extends StatelessWidget {
  final ProfileData data;

  const ActivateCardBanner({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: InkWell(
        onTap: () => showActivateCardDialog(context, data),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF1FB),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: kAuthBlue, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: const BoxDecoration(
                  color: kAuthBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.activate_card'.tr(),
                      style: AppTextStyles.of(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'profile.activate_card_subtitle'.tr(),
                      style: AppTextStyles.of(
                        color: kAuthGreyText,
                        fontSize: 12.5.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: kAuthBlue, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
