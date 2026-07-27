import 'dart:math' as math;

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

  const InvoiceDetailsScreen({super.key, required this.invoice});

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
            title: 'Appointment Details',
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
                        _error ?? 'Failed to load invoice details.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return _DetailsBody(invoice: widget.invoice, details: details);
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

  const _DetailsBody({required this.invoice, required this.details});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(details.date);
    final servicesText = _servicesText(details.services);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Order Number #MC-${details.invoiceId}',
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
            _InfoRow(label: 'Date', value: formattedDate),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(label: 'Service', value: servicesText),
          ],
        ),
        SizedBox(height: 28.h),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'Subtotal',
              value: 'EGP ${_money(details.totalBefore)}',
            ),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(
              label: 'Discount',
              value: '- EGP ${_money(math.max(0, details.discount))}',
              valueColor: const Color(0xFF10A75A),
            ),
            const Divider(height: 1, color: Color(0xFFD5D5D5)),
            _InfoRow(
              label: 'Total amount',
              value: 'EGP ${_money(details.totalAfter)}',
              isBold: true,
            ),
          ],
        ),
        SizedBox(height: 68.h),
        _DetailsActions(invoice: invoice),
      ],
    );
  }

  String _servicesText(List<InvoiceServiceItem> services) {
    if (services.isEmpty) return '-';
    if (services.length <= 2) {
      return services.map((service) => service.serviceName).join(', ');
    }
    final firstTwo = services.take(2).map((service) => service.serviceName);
    return '${firstTwo.join(', ')} +${services.length - 2} more';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isCompleted = normalized == 'used' || normalized == 'completed';
    final color = isCompleted
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
        isCompleted ? 'Completed' : status,
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

class _DetailsActions extends StatelessWidget {
  final InvoiceItem invoice;

  const _DetailsActions({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download Results'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3872B1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
              textStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton(
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) => _ReviewDialog(invoiceId: invoice.invoiceId),
            ),
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
            child: const Text('Leave Review'),
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
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final result = await sl<InvoiceRepository>().createReview(
      invoiceId: widget.invoiceId,
      rating: _rating,
      ratingText: _controller.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) {
        context.pop();
        showSuccessToast('Review submitted successfully.');
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
              'Share Your Review',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = value),
                  icon: Icon(
                    value <= _rating ? Icons.star : Icons.star_border,
                    color: value <= _rating
                        ? const Color(0xFFFFBE2E)
                        : const Color(0xFFE5E7EB),
                    size: 36.sp,
                  ),
                );
              }),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Input text',
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
                    : const Text('Submit'),
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
