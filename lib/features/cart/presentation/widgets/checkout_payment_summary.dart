import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/models/provider_covered_service.dart';
import '../cubit/cart_state.dart';
import 'checkout_pricing.dart';
import 'checkout_summary_row.dart';

class CheckoutPaymentSummary extends StatelessWidget {
  final CartState state;

  const CheckoutPaymentSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final provider = state.checkoutProvider;
    final isPackageCheckout = state.checkoutPackageId != null;
    final pricing = CheckoutPricing.fromState(state);
    final services = !isPackageCheckout && provider != null
        ? provider.coveredServices
        : const <ProviderCoveredService>[];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderHeader(
            providerName: provider?.providerName ?? '-',
            providerImageUrl: provider?.providerImageUrl,
            isPackage: isPackageCheckout,
          ),
          const _SummaryDivider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: isPackageCheckout
                ? _PackageOrderDetails(
                    packageName: state.checkoutPackageName ?? '-',
                    serviceNames: state.checkoutPackageServiceNames,
                    pricing: pricing,
                  )
                : _ServicesOrderDetails(services: services),
          ),
          const _SummaryDivider(),
          _PriceBreakdown(pricing: pricing),
          _TotalPanel(total: pricing.total),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final String providerName;
  final String? providerImageUrl;
  final bool isPackage;

  const _OrderHeader({
    required this.providerName,
    required this.providerImageUrl,
    required this.isPackage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: providerImageUrl == null || providerImageUrl!.trim().isEmpty
                ? Icon(
                    Icons.local_hospital_outlined,
                    color: const Color(0xFF3872B1),
                    size: 24.sp,
                  )
                : CachedNetworkImage(
                    imageUrl: providerImageUrl!,
                    fit: BoxFit.fill,
                    errorWidget: (_, _, _) => Icon(
                      Icons.local_hospital_outlined,
                      color: const Color(0xFF3872B1),
                      size: 24.sp,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cart.provider'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  providerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              isPackage ? 'cart.package'.tr() : 'cart.services'.tr(),
              style: AppTextStyles.of(
                fontSize: 11.5.sp,
                color: const Color(0xFF2563A9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageOrderDetails extends StatelessWidget {
  final String packageName;
  final List<String> serviceNames;
  final CheckoutPricing pricing;

  const _PackageOrderDetails({
    required this.packageName,
    required this.serviceNames,
    required this.pricing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: const Color(0xFF16A34A),
                size: 19.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                packageName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.of(
                  fontSize: 14.5.sp,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            _ItemPrice(
              priceBefore: pricing.subtotal,
              priceAfter: pricing.total,
            ),
          ],
        ),
        if (serviceNames.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _ExpandableNameList(
            title: 'cart.included_services'.tr(
              args: ['${serviceNames.length}'],
            ),
            names: serviceNames,
          ),
        ],
      ],
    );
  }
}

class _ServicesOrderDetails extends StatelessWidget {
  final List<ProviderCoveredService> services;

  const _ServicesOrderDetails({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        'cart.no_services_in_summary'.tr(),
        style: AppTextStyles.of(
          fontSize: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
      );
    }
    return _ExpandableServicesList(services: services);
  }
}

class _ExpandableServicesList extends StatefulWidget {
  final List<ProviderCoveredService> services;

  const _ExpandableServicesList({required this.services});

  @override
  State<_ExpandableServicesList> createState() =>
      _ExpandableServicesListState();
}

class _ExpandableServicesListState extends State<_ExpandableServicesList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const collapsedCount = 3;
    final canExpand = widget.services.length > collapsedCount;
    final visible = _expanded
        ? widget.services
        : widget.services.take(collapsedCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ListHeader(
          title: 'cart.covered_services'.tr(),
          count: widget.services.length,
        ),
        SizedBox(height: 6.h),
        ...visible.map((service) => _CoveredServiceRow(service: service)),
        if (canExpand)
          _ExpandButton(
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
      ],
    );
  }
}

class _ExpandableNameList extends StatefulWidget {
  final String title;
  final List<String> names;

  const _ExpandableNameList({required this.title, required this.names});

  @override
  State<_ExpandableNameList> createState() => _ExpandableNameListState();
}

class _ExpandableNameListState extends State<_ExpandableNameList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const collapsedCount = 3;
    final canExpand = widget.names.length > collapsedCount;
    final visible = _expanded
        ? widget.names
        : widget.names.take(collapsedCount);
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5.h),
          ...visible.map((name) => _IncludedServiceName(name: name)),
          if (canExpand)
            _ExpandButton(
              expanded: _expanded,
              onTap: () => setState(() => _expanded = !_expanded),
            ),
        ],
      ),
    );
  }
}

class _IncludedServiceName extends StatelessWidget {
  final String name;

  const _IncludedServiceName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF16A34A),
            size: 15.sp,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.of(
                fontSize: 12.5.sp,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;

  const _ListHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.of(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.of(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3872B1),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoveredServiceRow extends StatelessWidget {
  final ProviderCoveredService service;

  const _CoveredServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              color: const Color(0xFF3872B1),
              size: 15.sp,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              service.serviceName,
              style: AppTextStyles.of(
                fontSize: 13.sp,
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12.w),
          _ItemPrice(
            priceBefore: service.priceBefore,
            priceAfter: service.priceAfter,
          ),
        ],
      ),
    );
  }
}

class _ItemPrice extends StatelessWidget {
  final double? priceBefore;
  final double? priceAfter;

  const _ItemPrice({required this.priceBefore, required this.priceAfter});

  @override
  Widget build(BuildContext context) {
    final effectivePrice = priceAfter ?? priceBefore;
    if (effectivePrice == null) {
      return Text(
        'cart.price_unavailable'.tr(),
        style: AppTextStyles.of(
          fontSize: 11.sp,
          color: const Color(0xFF94A3B8),
        ),
      );
    }
    final hasDiscount =
        priceBefore != null && priceAfter != null && priceBefore! > priceAfter!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount && (priceBefore ?? 0) > 0)
          Text(
            formatPrice(priceBefore, showFreeWhenZero: false),
            style: AppTextStyles.of(
              fontSize: 10.5.sp,
              color: const Color(0xFF94A3B8),
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          formatPrice(effectivePrice),
          style: AppTextStyles.of(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandButton({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3872B1),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        iconAlignment: IconAlignment.end,
        icon: Icon(
          expanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 18.sp,
        ),
        label: Text(
          expanded ? 'cart.show_less'.tr() : 'cart.show_all_services'.tr(),
          style: AppTextStyles.of(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final CheckoutPricing pricing;

  const _PriceBreakdown({required this.pricing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Column(
        children: [
          CheckoutSummaryRow(
            label: 'cart.subtotal'.tr(),
            value: formatPrice(pricing.subtotal),
          ),
          if (pricing.discount > 0)
            CheckoutSummaryRow(
              label: 'cart.you_save'.tr(
                args: ['${pricing.discountPercentage}'],
              ),
              value: 'cart.negative_egp_amount'.tr(
                args: [checkoutMoney(pricing.discount)],
              ),
              valueColor: const Color(0xFF059669),
            ),
        ],
      ),
    );
  }
}

class _TotalPanel extends StatelessWidget {
  final double total;

  const _TotalPanel({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F6FD),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: CheckoutSummaryRow(
        label: 'cart.total_to_pay'.tr(),
        value: formatPrice(total),
        valueColor: const Color(0xFF2563A9),
        isBold: true,
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEEF2F6));
  }
}
