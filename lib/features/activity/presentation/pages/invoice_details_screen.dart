import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../cubit/invoice_details_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../core/utils/price_formatter.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceItem invoice;
  final int tab;
  final InvoiceDetails? initialDetails;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoice,
    this.tab = 0,
    this.initialDetails,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<InvoiceDetailsCubit>();
        if (initialDetails != null) {
          cubit.emitLoaded(initialDetails!);
        } else {
          cubit.loadDetails(invoice.invoiceId);
        }
        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppHeaderBackButton(
                      color: const Color(0xFF111827),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        'activity.invoice_details_title'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<InvoiceDetailsCubit, InvoiceDetailsState>(
                builder: (context, state) {
                  return switch (state) {
                    InvoiceDetailsLoaded(:final details) => _DetailsBody(
                      invoice: invoice,
                      details: details,
                      tab: tab,
                    ),
                    InvoiceDetailsLoadFailure(:final message) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          message.isEmpty
                              ? 'activity.invoice_details_load_failed'.tr()
                              : message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    _ => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3872B1),
                      ),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final InvoiceItem invoice;
  final InvoiceDetails details;
  final int tab;

  const _DetailsBody({
    required this.invoice,
    required this.details,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    final displayedDate = AppDateFormatter.formatDateTime(
      details.apiDate ?? details.date?.toIso8601String(),
      context.locale.languageCode,
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        14.h,
        AppSpacing.pageHorizontal,
        24.h,
      ),
      children: [
        // ── Number + status ──────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 20.sp,
              color: const Color(0xFF6B7280),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'activity.invoice_number'.tr(
                  args: [_apiValue(details.invoiceId)],
                ),
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _StatusBadge(status: details.status),
          ],
        ),
        SizedBox(height: 6.h),
        // ── Big total ────────────────────────────────────────────────
        Text(
          formatPrice(details.totalAfter),
          style: AppTextStyles.of(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            height: 1.1,
          ),
        ),
        SizedBox(height: 14.h),
        // ── Date + branch ────────────────────────────────────────────
        _MetaRow(
          date: displayedDate,
          branch: details.branchName?.trim().isNotEmpty == true
              ? details.branchName!
              : invoice.branchName,
        ),
        SizedBox(height: 12.h),
        // ── Provider ─────────────────────────────────────────────────
        _ProviderCard(
          invoice: invoice,
          beneficiaryName: details.beneficiaryName,
          providerName: details.providerName,
          branchName: details.branchName,
          providerImageUrl: details.providerImageUrl,
        ),
        if (_hasFamilyData(details)) ...[
          SizedBox(height: 12.h),
          _FamilyDataCard(details: details),
        ],
        SizedBox(height: 12.h),
        // ── Services table ───────────────────────────────────────────
        _ServicesCard(
          services: details.services,
          totalBefore: details.totalBefore,
          totalAfter: details.totalAfter,
          discountPct: details.discountPercentage,
        ),
        if (details.review != null) ...[
          SizedBox(height: 12.h),
          _InvoiceReviewCard(review: details.review!),
        ],
        SizedBox(height: 20.h),
        _DetailsActions(invoice: invoice, details: details, tab: tab),
        if (details.canContinuePayment) ...[
          SizedBox(height: 12.h),
          _ContinuePaymentButton(paymentLink: details.paymentLink!),
        ],
      ],
    );
  }
}

class _InvoiceReviewCard extends StatelessWidget {
  final InvoiceReview review;

  const _InvoiceReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveImageUrl(review.userImageUrl);
    final userName = review.userName?.trim() ?? '';
    final ratingText = review.ratingText?.trim() ?? '';
    final hasRatingText =
        ratingText.isNotEmpty && ratingText.toLowerCase() != 'null';
    final rating = (review.rating ?? 0).clamp(0, 5);
    final formattedDate = AppDateFormatter.formatDateTime(
      review.apiCreatedAt ?? review.createdAt?.toIso8601String(),
      context.locale.languageCode,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'activity.your_review'.tr(),
            style: AppTextStyles.of(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 42.r,
                  height: 42.r,
                  child: imageUrl == null
                      ? const ColoredBox(
                          color: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person_rounded,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.fill,
                          errorWidget: (_, _, _) => const ColoredBox(
                            color: Color(0xFFE2E8F0),
                            child: Icon(
                              Icons.person_rounded,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userName.isNotEmpty)
                      Text(
                        userName,
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    SizedBox(height: userName.isEmpty ? 0 : 4.h),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 17.sp,
                          color: const Color(0xFFF5A623),
                        ),
                      ),
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      SizedBox(height: 5.h),
                      Text(
                        formattedDate,
                        style: AppTextStyles.of(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (hasRatingText) ...[
            SizedBox(height: 10.h),
            Text(
              ratingText,
              style: AppTextStyles.of(
                fontSize: 13.sp,
                height: 1.4,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContinuePaymentButton extends StatefulWidget {
  final String paymentLink;

  const _ContinuePaymentButton({required this.paymentLink});

  @override
  State<_ContinuePaymentButton> createState() => _ContinuePaymentButtonState();
}

class _ContinuePaymentButtonState extends State<_ContinuePaymentButton> {
  bool _isOpening = false;

  Future<void> _openPayment() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    final opened = await UrlLauncherService().launchURL(widget.paymentLink);
    if (!mounted) return;
    setState(() => _isOpening = false);
    if (!opened) showErrorToast('cart.could_not_open_payment_link'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: _isOpening ? null : _openPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3872B1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9DB7D3),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          textStyle: AppTextStyles.of(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isOpening
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text('cart.continue_payment'.tr()),
      ),
    );
  }
}

/// Date and branch metadata without surrounding cards.
class _MetaRow extends StatelessWidget {
  final String date;
  final String branch;

  const _MetaRow({required this.date, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetaItem(
          icon: Icons.calendar_month_outlined,
          label: 'activity.date'.tr(),
          value: date,
        ),
        if (branch.trim().isNotEmpty) ...[
          SizedBox(height: 10.h),
          _MetaItem(
            icon: Icons.location_on_outlined,
            label: 'activity.branch'.tr(),
            value: branch,
          ),
        ],
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Icon(icon, size: 19.sp, color: const Color(0xFF3872B1)),
        ),
        SizedBox(width: 9.w),
        Text(
          '$label: ',
          style: AppTextStyles.of(
            fontSize: 13.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.of(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Provider (image, name, branch) + optional beneficiary, in one card.
class _ProviderCard extends StatelessWidget {
  final InvoiceItem invoice;
  final String? beneficiaryName;
  final String? providerName;
  final String? branchName;
  final String? providerImageUrl;

  const _ProviderCard({
    required this.invoice,
    this.beneficiaryName,
    this.providerName,
    this.branchName,
    this.providerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveImageUrl = providerImageUrl?.trim().isNotEmpty == true
        ? providerImageUrl
        : invoice.providerImageUrl;
    final imageUrl = resolveImageUrl(effectiveImageUrl);
    final beneficiary = beneficiaryName?.trim();
    final displayBeneficiary = beneficiary != null && beneficiary.isNotEmpty
        ? beneficiary
        : 'cart.card_owner'.tr();

    final effectiveProviderName = providerName?.trim().isNotEmpty == true
        ? providerName!
        : (invoice.providerName.trim().isNotEmpty
            ? invoice.providerName
            : 'activity.invoice_details_title'.tr());
    final effectiveBranchName = branchName?.trim().isNotEmpty == true
        ? branchName!
        : invoice.branchName;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48.r,
                  height: 48.r,
                  child: imageUrl == null
                      ? const Icon(
                          Icons.local_hospital,
                          color: Color(0xFF3872B1),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.fill,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.local_hospital,
                            color: Color(0xFF3872B1),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effectiveProviderName,
                      style: AppTextStyles.of(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (effectiveBranchName.trim().isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        effectiveBranchName,
                        style: AppTextStyles.of(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEEF1F5)),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18.sp,
                color: const Color(0xFF3872B1),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'activity.beneficiary'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  displayBeneficiary,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.of(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FamilyDataCard extends StatelessWidget {
  final InvoiceDetails details;

  const _FamilyDataCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final rows = <_ApiDataEntry>[
      if (details.familyId != null)
        _ApiDataEntry(
          label: 'activity.family_id_label'.tr(),
          value: _apiValue(details.familyId),
        ),
      if (_hasText(details.familyFirstName))
        _ApiDataEntry(
          label: 'activity.family_first_name'.tr(),
          value: details.familyFirstName!,
        ),
      if (_hasText(details.familyLastName))
        _ApiDataEntry(
          label: 'activity.family_last_name'.tr(),
          value: details.familyLastName!,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return _ApiDataCard(title: 'activity.family_data'.tr(), rows: rows);
  }
}

class _ApiDataEntry {
  final String label;
  final String value;

  const _ApiDataEntry({required this.label, required this.value});
}

class _ApiDataCard extends StatelessWidget {
  final String title;
  final List<_ApiDataEntry> rows;

  const _ApiDataCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.of(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 10.h),
          for (var index = 0; index < rows.length; index++) ...[
            _ApiDataRow(entry: rows[index]),
            if (index < rows.length - 1)
              const Divider(height: 16, color: Color(0xFFEEF1F5)),
          ],
        ],
      ),
    );
  }
}

class _ApiDataRow extends StatelessWidget {
  final _ApiDataEntry entry;

  const _ApiDataRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            entry.label,
            style: AppTextStyles.of(
              fontSize: 12.5.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            entry.value,
            textAlign: TextAlign.end,
            style: AppTextStyles.of(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}

/// Services with clearly labelled backend values and a totals footer.
class _ServicesCard extends StatelessWidget {
  final List<InvoiceServiceItem> services;
  final double? totalBefore;
  final double? totalAfter;
  final double? discountPct;

  const _ServicesCard({
    required this.services,
    required this.totalBefore,
    required this.totalAfter,
    required this.discountPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'activity.services_title'.tr(),
            style: AppTextStyles.of(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 10.h),
          const _TableHeaderRow(),
          const Divider(height: 16, color: Color(0xFFEEF1F5)),
          if (services.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                '-',
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          for (var i = 0; i < services.length; i++) ...[
            _ServiceTableRow(service: services[i]),
            if (i < services.length - 1)
              const Divider(height: 16, color: Color(0xFFEEF1F5)),
          ],
          const Divider(height: 24, color: Color(0xFFEEF1F5)),
          _TotalRow(
            label: 'cart.subtotal'.tr(),
            value: formatPrice(totalBefore),
          ),
          SizedBox(height: 8.h),
          _TotalRow(
            label: 'activity.discount_percentage'.tr(),
            value: '${_apiValue(discountPct)}%',
            valueColor: const Color(0xFF3872B1),
          ),
          SizedBox(height: 8.h),
          _TotalRow(
            label: 'cart.total_amount'.tr(),
            value: formatPrice(totalAfter),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: Text(
            'activity.service'.tr(),
            style: AppTextStyles.of(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'activity.price_before'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'activity.price_after'.tr(),
            textAlign: TextAlign.end,
            style: AppTextStyles.of(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceTableRow extends StatelessWidget {
  final InvoiceServiceItem service;

  const _ServiceTableRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localizedServiceName(context, service),
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.h),
              Text(
                '${'activity.discount_percentage'.tr()}: '
                '${_apiValue(service.displayedDiscountPercentage)}%',
                style: AppTextStyles.of(
                  fontSize: 10.5.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            _money(service.priceBefore),
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            formatPrice(service.priceAfter),
            textAlign: TextAlign.end,
            style: AppTextStyles.of(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3872B1),
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _TotalRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.of(
              fontSize: isTotal ? 15.sp : 13.5.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyles.of(
            fontSize: isTotal ? 17.sp : 13.5.sp,
            fontWeight: FontWeight.w700,
            color:
                valueColor ??
                (isTotal ? const Color(0xFF3872B1) : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status?.toLowerCase() ?? '';
    final isCancelled = normalized == 'canceled' || normalized == 'cancelled';
    final isCompleted = normalized == 'used' || normalized == 'completed';
    final color = isCancelled
        ? const Color(0xFFDC2626)
        : isCompleted
        ? const Color(0xFF0F8A5F)
        : const Color(0xFF9A6A00);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        _apiValue(status),
        style: AppTextStyles.of(fontSize: 13.sp, color: color),
      ),
    );
  }
}

class _DetailsActions extends StatefulWidget {
  final InvoiceItem invoice;
  final InvoiceDetails details;
  final int tab;

  const _DetailsActions({
    required this.invoice,
    required this.details,
    required this.tab,
  });

  @override
  State<_DetailsActions> createState() => _DetailsActionsState();
}

class _DetailsActionsState extends State<_DetailsActions> {
  bool _isCanceling = false;
  bool _hasReviewedLocally = false;

  bool get _canCancel =>
      widget.tab == 1 ||
      widget.invoice.isPending ||
      widget.details.status?.toLowerCase() == 'pending';

  bool get _canReview =>
      (widget.tab == 3 ||
          widget.invoice.isUsed ||
          widget.details.status?.toLowerCase() == 'used' ||
          widget.details.status?.toLowerCase() == 'completed') &&
      !widget.invoice.isReviewed &&
      widget.details.review == null &&
      !_hasReviewedLocally;

  Future<void> _onCancelTapped() async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: const Color(0xFFDC2626),
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'activity.cancel_invoice_confirm_title'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'activity.cancel_invoice_confirm_message'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    height: 1.35,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          minimumSize: Size.fromHeight(48.h),
                          textStyle: AppTextStyles.of(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'common.cancel'.tr(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          minimumSize: Size.fromHeight(48.h),
                          textStyle: AppTextStyles.of(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'activity.cancel_invoice'.tr(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCanceling = true);
    final error = await context.read<InvoiceDetailsCubit>().cancelInvoice(
      widget.invoice.invoiceId,
    );
    if (!mounted) return;
    setState(() => _isCanceling = false);

    if (error == null) {
      showSuccessToast('activity.cancel_invoice_success'.tr());
      context.pop(true);
    } else {
      showErrorToast(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_canCancel)
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: OutlinedButton(
              onPressed: _isCanceling ? null : _onCancelTapped,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC83C3C),
                backgroundColor: const Color(0xFFFFF7F7),
                disabledForegroundColor: const Color(0xFFDC8A8A),
                disabledBackgroundColor: const Color(0xFFFFFAFA),
                side: const BorderSide(color: Color(0xFFF0B7B7)),
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                textStyle: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isCanceling
                  ? SizedBox(
                      width: 21.r,
                      height: 21.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFFC83C3C),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 21.sp),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            'activity.cancel_invoice'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        if (_canCancel) SizedBox(height: 12.h),
        if (_canReview)
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton.icon(
              onPressed: () async {
                // The dialog builds above this page's provider scope, so
                // hand the cubit over explicitly.
                final cubit = context.read<InvoiceDetailsCubit>();
                final reviewed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: _ReviewDialog(invoiceId: widget.invoice.invoiceId),
                  ),
                );
                // Hide the button immediately after an in-app submit
                // instead of waiting for a list refresh.
                if (reviewed == true && mounted) {
                  setState(() => _hasReviewedLocally = true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF9DB7D3),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                textStyle: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: Icon(Icons.star_outline_rounded, size: 22.sp),
              label: Text('activity.leave_review'.tr()),
            ),
          ),
      ],
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final int invoiceId;

  const _ReviewDialog({required this.invoiceId});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _controller = TextEditingController();
  int? _rating;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final text = _controller.text.trim();
    if (_rating == null && text.isEmpty) {
      setState(() => _errorText = 'activity.review_at_least_one_required'.tr());
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    final error = await context.read<InvoiceDetailsCubit>().submitReview(
      invoiceId: widget.invoiceId,
      rating: _rating,
      ratingText: text.isEmpty ? null : text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (error == null) {
      context.pop(true);
      showSuccessToast('activity.review_submitted_successfully'.tr());
    } else {
      showErrorToast(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Text(
              'activity.share_your_review'.tr(),
              style: AppTextStyles.of(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                return GestureDetector(
                  onTap: () => setState(() {
                    _rating = _rating == value ? null : value;
                    if (_rating != null) _errorText = null;
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      _rating != null && value <= _rating!
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFFBE2E),
                      size: 40.sp,
                    ),
                  ),
                );
              }),
            ),
            if (_errorText != null) ...[
              SizedBox(height: 6.h),
              Text(
                _errorText!,
                style: AppTextStyles.of(
                  fontSize: 12.sp,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
            SizedBox(height: 10.h),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'activity.review_input_hint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3872B1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('activity.submit'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _apiValue(Object? value) => value?.toString() ?? 'null';

String _money(Object? value) => _apiValue(value);

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

bool _hasFamilyData(InvoiceDetails details) {
  return details.familyId != null ||
      _hasText(details.familyFirstName) ||
      _hasText(details.familyLastName);
}

String _localizedServiceName(BuildContext context, InvoiceServiceItem service) {
  final isArabic = context.locale.languageCode.toLowerCase() == 'ar';
  final value = isArabic
      ? service.serviceNameAr ?? service.serviceName ?? service.serviceNameEn
      : service.serviceNameEn ?? service.serviceName ?? service.serviceNameAr;
  return _apiValue(value);
}
