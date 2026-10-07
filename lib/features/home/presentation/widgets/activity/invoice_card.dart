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
    final formattedDate = DateFormat('dd MMM yyyy').format(item.date);
    final imageUrl = resolveImageUrl(item.providerImageUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () async {
        final tab = TabScope.of(context);
        final result = await context.push('/invoice-details', extra: {'invoice': item, 'tab': tab});
        if (result == true && context.mounted) {
          context.read<ActivityCubit>().loadInvoices(tab: tab, forceRefresh: true);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56.r,
              height: 56.r,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
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
                              fit: BoxFit.cover,
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
                        child: Container(
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
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.providerName,
                          style: AppTextStyles.of(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _StatusPill(item: item),
                    ],
                  ),
                  SizedBox(height: 2.h),
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
                  if (item.beneficiaryName != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14.r,
                          color: const Color(0xFF6B7280),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            item.beneficiaryName!,
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formattedDate,
                        style: AppTextStyles.of(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      if (_amount(item) != null)
                        Text(
                          'cart.egp_amount'.tr(
                            args: ['${_amount(item)!.toInt()}'],
                          ),
                          style: AppTextStyles.of(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [InvoiceActionButton(item: item)],
                  ),
                ],
              ),
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

double? _amount(InvoiceItem item) => item.priceAfter ?? item.packagePrice;

/// Small colored status chip (pending / paid / used / cancelled).
class _StatusPill extends StatelessWidget {
  final InvoiceItem item;

  const _StatusPill({required this.item});

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;
    late final String labelKey;

    if (item.isPending) {
      background = const Color(0xFFFEF3C7);
      foreground = const Color(0xFFB45309);
      labelKey = 'activity.pending';
    } else if (item.isPaid) {
      background = const Color(0xFFDBEAFE);
      foreground = const Color(0xFF1D4ED8);
      labelKey = 'activity.paid';
    } else if (item.isUsed) {
      background = const Color(0xFFD1FAE5);
      foreground = const Color(0xFF047857);
      labelKey = 'activity.used';
    } else {
      background = const Color(0xFFFEE2E2);
      foreground = const Color(0xFFB91C1C);
      labelKey = 'activity.cancelled';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        labelKey.tr(),
        style: AppTextStyles.of(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
