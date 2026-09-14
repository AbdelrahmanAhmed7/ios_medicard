import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/constants/api_result.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final InvoiceItem invoice;
  final int tab;

  const InvoiceDetailsScreen({super.key, required this.invoice, this.tab = 0});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  late final Future<InvoiceDetails?> _detailsFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<InvoiceDetails?> _loadDetails() async {
    final result = await sl<InvoiceRepository>().getInvoiceDetails(
      widget.invoice.invoiceId,
    );
    return result.when(
      success: (details) => details,
      failure: (message) {
        _error = message;
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          AppBlueHeader(
            title: 'activity.appointment_details'.tr(),
            bottomRadius: 18,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: FutureBuilder<InvoiceDetails?>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                  );
                }
                final details = snapshot.data;
                if (details == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        _error ?? 'activity.invoice_details_load_failed'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return _DetailsBody(invoice: widget.invoice, details: details, tab: widget.tab);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final InvoiceItem invoice;
  final InvoiceDetails details;
  final int tab;

  const _DetailsBody({required this.invoice, required this.details, required this.tab});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      context.locale.toString(),
    ).format(details.date);
    final servicesText = _servicesText(details.services);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'activity.order_number'.tr(args: ['${details.invoiceId}']),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
            ),
            _StatusBadge(status: details.status),
          ],
        ),
        SizedBox(height: 22.h),
        _InfoCard(
          children: [
            _ProviderHeader(invoice: invoice),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            if (details.beneficiaryName != null) ...[
              _InfoRow(
                label: 'activity.beneficiary'.tr(),
                value: details.beneficiaryName!,
              ),
              const Divider(height: 1, color: Color(0xFFD5D5D5)),
            ],
            _InfoRow(label: 'activity.date'.tr(), value: formattedDate),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(label: 'activity.service'.tr(), value: servicesText),
          ],
        ),
        SizedBox(height: 28.h),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'cart.subtotal'.tr(),
              value: 'cart.egp_amount'.tr(args: [_money(details.totalBefore)]),
            ),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(
              label: 'cart.discount'.tr(),
              value: 'cart.negative_discount_percent'.tr(
                args: [details.discountPercentage.toStringAsFixed(0)],
              ),
              valueColor: const Color(0xFF10A75A),
            ),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(
              label: 'cart.total_amount'.tr(),
              value: 'cart.egp_amount'.tr(args: [_money(details.totalAfter)]),
              isBold: true,
            ),
          ],
        ),
        SizedBox(height: 68.h),
        _DetailsActions(invoice: invoice, details: details, tab: tab),
      ],
    );
  }

  String _servicesText(List<InvoiceServiceItem> services) {
    if (services.isEmpty) return '-';
    return services.map((service) => service.serviceName).join(', ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isCancelled =
        normalized == 'canceled' || normalized == 'cancelled';
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
        style: TextStyle(fontSize: 13.sp, color: color),
      ),
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  final InvoiceItem invoice;

  const _ProviderHeader({required this.invoice});

  @override
  Widget build(BuildContext context) {
    const baseImageUrl =
        'https://medicard-api-v2.medicardeg.com/uploads/providers/';
    final imageUrl =
        invoice.providerImageUrl != null && invoice.providerImageUrl!.isNotEmpty
        ? '$baseImageUrl${invoice.providerImageUrl}'
        : null;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 52.r,
              height: 52.r,
              child: imageUrl == null
                  ? const Icon(Icons.local_hospital, color: Color(0xFF3872B1))
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
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.providerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  invoice.branchName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: valueColor ?? const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsActions extends StatefulWidget {
  final InvoiceItem invoice;
  final InvoiceDetails details;
  final int tab;

  const _DetailsActions({required this.invoice, required this.details, required this.tab});

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
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'activity.cancel_invoice_confirm_message'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
    final result = await sl<InvoiceRepository>().cancelInvoice(
      widget.invoice.invoiceId,
    );
    if (!mounted) return;
    setState(() => _isCanceling = false);

    result.when(
      success: (_) {
        showSuccessToast('activity.cancel_invoice_success'.tr());
        context.pop(true);
      },
      failure: (message) => showErrorToast(message),
    );
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
                  borderRadius: BorderRadius.circular(9.r),
                ),
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
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
            height: 50.h,
            child: OutlinedButton(
              onPressed: () async {
                final reviewed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => _ReviewDialog(
                    invoiceId: widget.invoice.invoiceId,
                  ),
                );
                // Hide the button immediately after an in-app submit
                // instead of waiting for a list refresh.
                if (reviewed == true && mounted) {
                  setState(() => _hasReviewedLocally = true);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2D6FB7),
                side: const BorderSide(color: Color(0xFF2D6FB7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
                textStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
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
    final result = await sl<InvoiceRepository>().createReview(
      invoiceId: widget.invoiceId,
      rating: _rating,
      ratingText: text.isEmpty ? null : text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) {
        context.pop(true);
        showSuccessToast('activity.review_submitted_successfully'.tr());
      },
      failure: (message) => showErrorToast(message),
    );
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
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
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
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFFEF4444)),
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
