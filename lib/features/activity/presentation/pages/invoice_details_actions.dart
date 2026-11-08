part of 'invoice_details_screen.dart';

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
