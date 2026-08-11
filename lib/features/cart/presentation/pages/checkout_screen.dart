import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../../../features/family_members/data/models/family_member_model.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'order_confirmed_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int? initialProviderId;
  final ProviderBranch? initialBranch;
  final int? packageId;
  final String? packageName;
  final double? packagePriceBefore;
  final double? packagePriceAfter;

  const CheckoutScreen({
    super.key,
    this.initialProviderId,
    this.initialBranch,
    this.packageId,
    this.packageName,
    this.packagePriceBefore,
    this.packagePriceAfter,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCheckout(
      initialProviderId: widget.initialProviderId,
      initialBranch: widget.initialBranch,
      packageId: widget.packageId,
      packageName: widget.packageName,
      packagePriceBefore: widget.packagePriceBefore,
      packagePriceAfter: widget.packagePriceAfter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            previous.createInvoiceError != current.createInvoiceError ||
            previous.createdInvoiceId != current.createdInvoiceId ||
            previous.createdInvoicePaymentLink !=
                current.createdInvoicePaymentLink,
        listener: (context, state) async {
          if (state.createInvoiceError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.createInvoiceError!)));
          }
          if (state.createdInvoiceId != null) {
            final paymentLink = state.createdInvoicePaymentLink;
            if (paymentLink != null && paymentLink.isNotEmpty) {
              final opened = await UrlLauncherService().launchURL(paymentLink);
              if (!context.mounted) return;
              if (opened) {
                context.go('/medicard-home?tab=activity');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('cart.could_not_open_payment_link'.tr()),
                  ),
                );
              }
              return;
            }
            if (!context.mounted) return;
            context.go(
              '/order-confirmed',
              extra: _confirmedArgsFromState(state),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              AppBlueHeader(
                title: 'cart.checkout'.tr(),
                bottomRadius: 18,
                onBack: () => context.pop(),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state.isCheckoutLoading && state.checkoutProvider == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      );
    }

    if (state.checkoutError != null && state.checkoutProvider == null) {
      return _ErrorView(
        message: state.checkoutError!,
        onRetry: () => context.read<CartCubit>().loadCheckout(
          initialProviderId: widget.initialProviderId,
          initialBranch: widget.initialBranch,
          packageId: widget.packageId,
          packageName: widget.packageName,
          packagePriceBefore: widget.packagePriceBefore,
          packagePriceAfter: widget.packagePriceAfter,
        ),
      );
    }

    final bottomSafePadding = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        14.w,
        18.h,
        14.w,
        24.h + bottomSafePadding + 8.h,
      ),
      children: [
        _SectionTitle(text: 'cart.order_for'.tr()),
        SizedBox(height: 8.h),
        _PatientDropdown(state: state),
        SizedBox(height: 22.h),
        _SectionTitle(text: 'cart.branch_location'.tr()),
        SizedBox(height: 8.h),
        _BranchSelector(state: state),
        SizedBox(height: 22.h),
        _SectionTitle(text: 'cart.payment_method'.tr()),
        SizedBox(height: 8.h),
        _PaymentDropdown(state: state),
        SizedBox(height: 24.h),
        _SectionTitle(text: 'cart.payment_summary'.tr()),
        SizedBox(height: 12.h),
        _PaymentSummary(state: state),
        SizedBox(height: 22.h),
        _PayButton(state: state),
      ],
    );
  }
}

OrderConfirmedArgs _confirmedArgsFromState(CartState state) {
  return OrderConfirmedArgs(orderNumber: state.createdInvoiceId ?? '-');
}

class _PatientDropdown extends StatelessWidget {
  final CartState state;

  const _PatientDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[
      DropdownMenuItem(value: 0, child: Text('cart.card_owner'.tr())),
      ...state.familyMembers.map(
        (member) => DropdownMenuItem(
          value: member.id ?? -1,
          child: Text(_memberName(member)),
        ),
      ),
    ];

    return _DropdownFrame(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: state.selectedFamilyMember?.id ?? 0,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items,
          hint: state.isFamilyMembersLoading
              ? Text('cart.loading_patients'.tr())
              : Text('cart.select_patient'.tr()),
          onChanged: state.isFamilyMembersLoading
              ? null
              : (id) {
                  if (id == null || id == 0) {
                    context.read<CartCubit>().selectFamilyMember(null);
                    return;
                  }
                  FamilyMemberModel? selected;
                  for (final member in state.familyMembers) {
                    if (member.id == id) {
                      selected = member;
                      break;
                    }
                  }
                  context.read<CartCubit>().selectFamilyMember(selected);
                },
        ),
      ),
    );
  }

  String _memberName(FamilyMemberModel member) {
    if (member.fullName?.isNotEmpty == true) return member.fullName!;
    return '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
  }
}

class _BranchSelector extends StatelessWidget {
  final CartState state;

  const _BranchSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedBranch;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD7E5F5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selected?.branchId,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                hint: Text(
                  state.isCheckoutLoading
                      ? 'cart.loading_branches'.tr()
                      : 'provider_page.select_branch'.tr(),
                ),
                items: state.checkoutBranches
                    .map(
                      (branch) => DropdownMenuItem(
                        value: branch.branchId,
                        child: Text(branch.fullAddress ?? branch.branchName),
                      ),
                    )
                    .toList(),
                onChanged: state.isCheckoutLoading
                    ? null
                    : (branchId) {
                        if (branchId == null) return;
                        final branch = state.checkoutBranches.firstWhere(
                          (branch) => branch.branchId == branchId,
                        );
                        context.read<CartCubit>().selectCheckoutBranch(branch);
                      },
              ),
            ),
          ),
          if (selected != null) _MapPreview(branch: selected),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final ProviderBranch branch;

  const _MapPreview({required this.branch});

  @override
  Widget build(BuildContext context) {
    final latitude = branch.latitude;
    final longitude = branch.longitude;
    final hasLocation = latitude != null && longitude != null;
    final point = hasLocation ? LatLng(latitude, longitude) : null;

    return GestureDetector(
      onTap: () {
        final url = branch.mapUrl;
        if (url != null && url.isNotEmpty) {
          UrlLauncherService().launchURL(url);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
        child: Container(
          width: double.infinity,
          height: 146.h,
          color: const Color(0xFFE5E7EB),
          child: point == null
              ? const Center(child: Icon(Icons.map_outlined))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.medicard',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 42.r,
                          height: 42.r,
                          child: Icon(
                            Icons.location_on,
                            color: const Color(0xFF3872B1),
                            size: 38.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PaymentDropdown extends StatelessWidget {
  final CartState state;

  const _PaymentDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    return _DropdownFrame(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CartPaymentMethod>(
          value: state.paymentMethod,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            DropdownMenuItem(
              value: CartPaymentMethod.cash,
              child: Text('cart.cash'.tr()),
            ),
            DropdownMenuItem(
              value: CartPaymentMethod.visa,
              child: Text('cart.visa'.tr()),
            ),
          ],
          onChanged: (method) {
            if (method != null) {
              context.read<CartCubit>().selectPaymentMethod(method);
            }
          },
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final CartState state;

  const _PaymentSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final provider = state.checkoutProvider;
    final isPackageCheckout = state.checkoutPackageId != null;
    final subtotal = isPackageCheckout
        ? state.checkoutPackagePriceBefore ??
              state.checkoutPackagePriceAfter ??
              0
        : provider?.totalPriceBefore ?? 0.0;
    final total = isPackageCheckout
        ? state.checkoutPackagePriceAfter ??
              state.checkoutPackagePriceBefore ??
              0
        : provider?.totalPriceAfter ?? 0.0;
    final discount = math.max<double>(0.0, subtotal - total);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'cart.provider'.tr(),
            value: provider?.providerName ?? '-',
          ),
          if (isPackageCheckout)
            _SummaryRow(
              label: 'cart.package'.tr(),
              value: state.checkoutPackageName ?? '-',
            ),
          _SummaryRow(
            label: 'cart.subtotal'.tr(),
            value: 'cart.egp_amount'.tr(args: [_money(subtotal)]),
          ),
          _SummaryRow(
            label: 'cart.discount'.tr(),
            value: 'cart.negative_egp_amount'.tr(args: [_money(discount)]),
            valueColor: const Color(0xFF10B981),
          ),
          Divider(height: 20.h, color: const Color(0xFFD7D7D7)),
          _SummaryRow(
            label: 'cart.total_amount'.tr(),
            value: 'cart.egp_amount'.tr(args: [_money(total)]),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final CartState state;

  const _PayButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isBusy = state.isCreatingInvoice;
    final paymentLink = state.createdInvoicePaymentLink;
    final hasPaymentLink = paymentLink != null && paymentLink.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isBusy
            ? null
            : hasPaymentLink
            ? () async {
                final opened = await UrlLauncherService().launchURL(
                  paymentLink,
                );
                if (opened && context.mounted) {
                  context.go('/medicard-home?tab=activity');
                }
              }
            : () {
                final cubit = context.read<CartCubit>();
                if (state.checkoutPackageId != null) {
                  cubit.createPackageInvoice();
                } else {
                  cubit.createCartInvoice();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3872B1),
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isBusy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                hasPaymentLink
                    ? 'cart.continue_payment'.tr()
                    : state.paymentMethod == CartPaymentMethod.visa
                    ? 'cart.pay_with_visa'.tr()
                    : 'cart.pay'.tr(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _DropdownFrame extends StatelessWidget {
  final Widget child;

  const _DropdownFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFAAB2C1)),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: valueColor ?? const Color(0xFF444D5D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2E2E2E),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: const Color(0xFF94A3B8),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3872B1),
                foregroundColor: Colors.white,
              ),
              child: Text('common.retry'.tr()),
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
