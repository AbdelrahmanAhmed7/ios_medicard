import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/utils/image_url_resolver.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../../features/activity/domain/models/invoice_item.dart';
import '../../../../../features/activity/presentation/cubit/activity_cubit.dart';
import 'invoice_list.dart';
import 'invoice_action_button.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceItem item;

  const InvoiceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm:ss').format(item.date);
    final imageUrl = resolveImageUrl(item.providerImageUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () async {
        final tab = TabScope.of(context);
        final result = await context.push(
          '/invoice-details',
          extra: {'invoice': item, 'tab': tab},
        );
        if (result == true && context.mounted) {
          context.read<ActivityCubit>().loadInvoices(
            tab: tab,
            forceRefresh: true,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 52.r,
                  height: 52.r,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  memCacheWidth: 150,
                                  memCacheHeight: 150,
                                  fit: BoxFit.fill,
                                  placeholder: (_, _) =>
                                      Container(color: Colors.grey[100]),
                                  errorWidget: (_, _, _) => _providerInitial(),
                                )
                              : _providerInitial(),
                        ),
                      ),
                      if (item.isUsed)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 11.r,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.providerName,
                        style: AppTextStyles.of(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.branchName,
                        style: AppTextStyles.of(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.beneficiaryName != null ||
                          item.familyId != null) ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 14.sp,
                              color: const Color(0xFF4B5563),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                [
                                  if (item.beneficiaryName != null)
                                    item.beneficiaryName!,
                                  if (item.familyId != null)
                                    'activity.family_id'.tr(
                                      args: ['${item.familyId}'],
                                    ),
                                ].join(' · '),
                                style: AppTextStyles.of(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4B5563),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.priceAfter != null) ...[
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'activity.price_after'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'cart.egp_amount'.tr(
                          args: [_apiNumber(item.priceAfter!)],
                        ),
                        style: AppTextStyles.of(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3872B1),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (item.priceBefore != null)
                  _InvoiceFact(
                    label: 'activity.price_before'.tr(),
                    value: 'cart.egp_amount'.tr(
                      args: [_apiNumber(item.priceBefore!)],
                    ),
                  ),
                if (item.discountPercentage != null)
                  _InvoiceFact(
                    label: 'activity.discount_percentage'.tr(),
                    value: '${_apiNumber(item.discountPercentage!)}%',
                  ),
                if (item.points != null)
                  _InvoiceFact(
                    label: 'activity.points'.tr(),
                    value: '${item.points}',
                  ),
                if (item.isFromPackage)
                  _InvoiceFact(
                    label: 'activity.from_package'.tr(),
                    value: 'activity.yes'.tr(),
                  ),
                _InvoiceFact(
                  label: 'activity.reviewed'.tr(),
                  value: item.isReviewed
                      ? 'activity.reviewed_done'.tr()
                      : 'activity.reviewed_pending'.tr(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFEEF1F5)),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  'activity.invoice_short'.tr(args: ['${item.invoiceId}']),
                  style: AppTextStyles.of(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTextStyles.of(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InvoiceActionButton(item: item),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerInitial() {
    return CircleAvatar(
      backgroundColor: Colors.grey[100],
      child: const Icon(Icons.local_hospital, color: kAuthBlue),
    );
  }
}

class _InvoiceFact extends StatelessWidget {
  final String label;
  final String value;

  const _InvoiceFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: AppTextStyles.of(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        style: AppTextStyles.of(
          fontSize: 11.5.sp,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

/// Keeps the numeric value returned by the API; it never rounds, truncates,
/// derives, or recalculates it for presentation.
String _apiNumber(num value) => value.toString();
