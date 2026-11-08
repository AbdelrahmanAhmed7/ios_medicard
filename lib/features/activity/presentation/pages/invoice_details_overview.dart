part of 'invoice_details_screen.dart';

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
