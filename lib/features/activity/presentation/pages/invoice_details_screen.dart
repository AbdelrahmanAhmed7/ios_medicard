import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../cubit/invoice_details_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/image_url_resolver.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceItem invoice;
  final int tab;

  const InvoiceDetailsScreen({super.key, required this.invoice, this.tab = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvoiceDetailsCubit>()..loadDetails(invoice.invoiceId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
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
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      context.locale.toString(),
    ).format(details.date);
    final discountPct = _discountPercent(details);
    final saved = (details.totalBefore - details.totalAfter).clamp(
      0,
      double.infinity,
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
                'activity.invoice_number'.tr(args: ['${details.invoiceId}']),
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
          'cart.egp_amount'.tr(args: [_money(details.totalAfter)]),
          style: AppTextStyles.of(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            height: 1.1,
          ),
        ),
        SizedBox(height: 14.h),
        // ── Date + branch ────────────────────────────────────────────
        _MetaRow(date: formattedDate, branch: invoice.branchName),
        SizedBox(height: 12.h),
        // ── Provider ─────────────────────────────────────────────────
        _ProviderCard(
          invoice: invoice,
          beneficiaryName: details.beneficiaryName,
        ),
        SizedBox(height: 12.h),
        // ── Services table ───────────────────────────────────────────
        _ServicesCard(
          services: details.services,
          totalBefore: details.totalBefore,
          totalAfter: details.totalAfter,
          discountPct: discountPct,
          saved: saved.toDouble(),
        ),
        SizedBox(height: 20.h),
        _DetailsActions(invoice: invoice, details: details, tab: tab),
      ],
    );
  }
}

/// Compact date + branch row.
class _MetaRow extends StatelessWidget {
  final String date;
  final String branch;

  const _MetaRow({required this.date, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaItem(
            icon: Icons.calendar_month_outlined,
            label: 'activity.date'.tr(),
            value: date,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _MetaItem(
            icon: Icons.location_on_outlined,
            label: 'activity.branch'.tr(),
            value: branch,
          ),
        ),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF3872B1)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.of(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider (image, name, branch) + optional beneficiary, in one card.
class _ProviderCard extends StatelessWidget {
  final InvoiceItem invoice;
  final String? beneficiaryName;

  const _ProviderCard({required this.invoice, this.beneficiaryName});

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveImageUrl(invoice.providerImageUrl);

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
                          fit: BoxFit.cover,
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
                      invoice.providerName,
                      style: AppTextStyles.of(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      invoice.branchName,
                      style: AppTextStyles.of(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (beneficiaryName != null &&
              beneficiaryName!.trim().isNotEmpty) ...[
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
                Flexible(
                  child: Text(
                    beneficiaryName!,
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
        ],
      ),
    );
  }
}

/// Services table: header + per-service prices + totals footer.
/// Row order mirrors automatically in RTL.
class _ServicesCard extends StatelessWidget {
  final List<InvoiceServiceItem> services;
  final double totalBefore;
  final double totalAfter;
  final double discountPct;
  final double saved;

  const _ServicesCard({
    required this.services,
    required this.totalBefore,
    required this.totalAfter,
    required this.discountPct,
    required this.saved,
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
          _TableHeaderRow(),
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
            value: 'cart.egp_amount'.tr(args: [_money(totalBefore)]),
          ),
          SizedBox(height: 8.h),
          if (saved > 0)
            _TotalRow(
              label: 'cart.discount'.tr(),
              value:
                  '-${'cart.egp_amount'.tr(args: [_money(saved)])} (${discountPct.toStringAsFixed(0)}%)',
              valueColor: const Color(0xFF10A75A),
            ),
          if (saved > 0) SizedBox(height: 8.h),
          _TotalRow(
            label: 'cart.total_amount'.tr(),
            value: 'cart.egp_amount'.tr(args: [_money(totalAfter)]),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
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
            textAlign: TextAlign.end,
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
    final hasDiscount = service.priceBefore > service.priceAfter;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Text(
            service.serviceName,
            style: AppTextStyles.of(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            hasDiscount ? _money(service.priceBefore) : '',
            textAlign: TextAlign.end,
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: const Color(0xFF94A3B8),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'cart.egp_amount'.tr(args: [_money(service.priceAfter)]),
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
            color: valueColor ?? const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
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
        isCancelled
            ? 'activity.status_cancelled'.tr()
            : isCompleted
            ? 'home.completed'.tr()
            : _localizedStatus(status),
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

  bool get _canCancel => widget.tab == 1;

  // Reflects backend status: hide the button once the invoice is reviewed
  // (list flag or an in-app submit), and rely on the invoice status itself
  // in addition to the entry tab so stale tab indexes can't show/hide it
  // incorrectly.
  bool get _canReview =>
      (widget.tab == 3 || widget.invoice.isUsed) &&
      !widget.invoice.isReviewed &&
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
                    color: Colors.red,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          minimumSize: Size.fromHeight(48.h),
                        ),
                        child: Text('common.cancel'.tr()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          minimumSize: Size.fromHeight(48.h),
                        ),
                        child: Text('activity.cancel_invoice'.tr()),
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
            height: 50.h,
            child: OutlinedButton(
              onPressed: _isCanceling ? null : _onCancelTapped,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _isCanceling
                  ? const CircularProgressIndicator(color: Colors.red)
                  : Text('activity.cancel_invoice'.tr()),
            ),
          ),
        if (_canCancel) SizedBox(height: 12.h),
        if (_canReview)
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: AppTextStyles.of(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text('activity.leave_review'.tr()),
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

String _money(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}

/// Backend quirk: the invoice-level discount often comes back as 0 while the
/// items carry the real one — derive it from the totals as a fallback.
double _discountPercent(InvoiceDetails details) {
  if (details.discountPercentage > 0) return details.discountPercentage;
  if (details.totalBefore <= 0) return 0;
  final derived =
      (details.totalBefore - details.totalAfter) / details.totalBefore * 100;
  return derived.clamp(0, 100).toDouble();
}

String _localizedStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return switch (normalized) {
    'pending' => 'activity.status_pending'.tr(),
    'used' => 'activity.status_used'.tr(),
    'completed' => 'home.completed'.tr(),
    'canceled' || 'cancelled' => 'activity.status_cancelled'.tr(),
    _ => status,
  };
}
