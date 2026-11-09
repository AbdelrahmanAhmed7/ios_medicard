import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_spacing.dart';
import '../../../../../core/utils/shimmer_card.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Shimmer skeleton that mimics the InvoiceCard list on the Invoices (Activity) tab.
class InvoicesShimmer extends StatelessWidget {
  final int itemCount;

  const InvoicesShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: 16.h,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (_, _) => const _InvoiceCardShimmer(),
    );
  }
}

typedef InvoiceShimmer = InvoicesShimmer;

class _InvoiceCardShimmer extends StatelessWidget {
  const _InvoiceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteClr,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.exactFFE5E9F0, width: 1),
        ),
        child: SmoothShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Info + Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circle Avatar
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: const BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Middle Column: Provider Name, Branch, Beneficiary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: AppColors.exactFFE8E8E8,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 85.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppColors.exactFFE8E8E8,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 105.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppColors.exactFFE8E8E8,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Right Column: Price After
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 50.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppColors.exactFFE8E8E8,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        width: 70.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.exactFFE8E8E8,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Middle Row: Fact Pills
              Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 65.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 75.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              const Divider(height: 1, color: AppColors.exactFFEEF1F5),
              SizedBox(height: 10.h),
              // Bottom Row: Invoice ID, Date, Action Button
              Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Container(
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.exactFFE8E8E8,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 65.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFE8E8E8,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


