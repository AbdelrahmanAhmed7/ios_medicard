part of 'invoice_details_screen.dart';

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
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lineClr),
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
              color: AppColors.inkClr,
            ),
          ),
          SizedBox(height: 10.h),
          const _TableHeaderRow(),
          const Divider(height: 16, color: AppColors.exactFFEEF1F5),
          if (services.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                '-',
                style: AppTextStyles.of(
                  fontSize: 13.sp,
                  color: AppColors.exactFF6B7280,
                ),
              ),
            ),
          for (var i = 0; i < services.length; i++) ...[
            _ServiceTableRow(service: services[i]),
            if (i < services.length - 1)
              const Divider(height: 16, color: AppColors.exactFFEEF1F5),
          ],
          const Divider(height: 24, color: AppColors.exactFFEEF1F5),
          _TotalRow(
            label: 'cart.subtotal'.tr(),
            value: formatPrice(totalBefore),
          ),
          SizedBox(height: 8.h),
          _TotalRow(
            label: 'activity.discount_percentage'.tr(),
            value: '${_apiValue(discountPct)}%',
            valueColor: AppColors.brandBlueClr,
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
              color: AppColors.exactFF6B7280,
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
              color: AppColors.exactFF6B7280,
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
              color: AppColors.exactFF6B7280,
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
                  color: AppColors.inkClr,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.h),
              Text(
                '${'activity.total_quantity'.tr()}: ${service.quantity ?? 1}',
                style: AppTextStyles.of(
                  fontSize: 10.5.sp,
                  color: AppColors.exactFF6B7280,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${'activity.discount_percentage'.tr()}: '
                '${_apiValue(service.displayedDiscountPercentage)}%',
                style: AppTextStyles.of(
                  fontSize: 10.5.sp,
                  color: AppColors.exactFF6B7280,
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
              color: AppColors.exactFF6B7280,
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
              color: AppColors.brandBlueClr,
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
                  ? AppColors.inkClr
                  : AppColors.exactFF6B7280,
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
                (isTotal ? AppColors.brandBlueClr : AppColors.inkClr),
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
        ? AppColors.exactFFDC2626
        : isCompleted
        ? AppColors.exactFF0F8A5F
        : AppColors.exactFF9A6A00;
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

