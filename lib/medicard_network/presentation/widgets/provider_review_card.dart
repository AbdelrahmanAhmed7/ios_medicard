import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../network/data/provider_page_response_model.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Pure review card: renders one [ProviderReview], no cubit interaction.
class ProviderReviewCard extends StatelessWidget {
  final ProviderReview review;

  const ProviderReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final ratingText = (review.ratingText ?? '').trim();
    final hasRatingText =
        ratingText.isNotEmpty && ratingText.toLowerCase() != 'null';
    final formattedDate = AppDateFormatter.formatDateTime(
      review.createdAt,
      context.locale.languageCode,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.exactFFD1D5DB),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: review.userImageUrl ?? '',
              width: 42.r,
              height: 42.r,
              fit: BoxFit.fill,
              errorWidget: (_, _, _) => Container(
                width: 42.r,
                height: 42.r,
                color: AppColors.lineClr,
                child: const Icon(Icons.person, color: AppColors.inkMutedClr),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.userName ?? '',
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.exactFF0F172A,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (review.rating ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 15.sp,
                      color: AppColors.exactFFF5A623,
                    );
                  }),
                ),
                if (formattedDate.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    formattedDate,
                    style: AppTextStyles.of(
                      fontSize: 12.sp,
                      color: AppColors.inkFaintClr,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (hasRatingText) ...[
                  SizedBox(height: 8.h),
                  Text(
                    ratingText,
                    style: AppTextStyles.of(
                      fontSize: 13.sp,
                      color: AppColors.inkSoftClr,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

