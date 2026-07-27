import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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

  const CheckoutScreen({super.key, this.initialProviderId, this.initialBranch});

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
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open payment link.')),
                );
              }
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
                title: 'Checkout',
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
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 24.h),
      children: [
        _SectionTitle(text: 'Order For'),
        SizedBox(height: 8.h),
        _PatientDropdown(state: state),
        SizedBox(height: 22.h),
        _SectionTitle(text: 'Branch Location'),
        SizedBox(height: 8.h),
        _BranchSelector(state: state),
        SizedBox(height: 22.h),
        _SectionTitle(text: 'Payment Method'),
        SizedBox(height: 8.h),
        _PaymentDropdown(state: state),
        SizedBox(height: 24.h),
        const _SectionTitle(text: 'Payment Summary'),
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
      const DropdownMenuItem(value: 0, child: Text('Card owner')),
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
              ? const Text('Loading patients...')
              : const Text('Select The Patient'),
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
                      ? 'Loading branches...'
                      : 'Select branch',
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
    final imageUrl = hasLocation ? _staticMapUrl(latitude, longitude) : null;

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
          child: imageUrl == null
              ? const Center(child: Icon(Icons.map_outlined))
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Icon(Icons.map_outlined)),
                ),
        ),
      ),
    );
  }

  String _staticMapUrl(double latitude, double longitude) {
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$latitude,$longitude&zoom=14&size=600x220'
        '&markers=$latitude,$longitude,blue-pushpin';
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
          items: const [
            DropdownMenuItem(
              value: CartPaymentMethod.cash,
              child: Text('Cash'),
            ),
            DropdownMenuItem(
              value: CartPaymentMethod.visa,
              child: Text('Visa'),
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
    final subtotal = provider?.totalPriceBefore ?? 0.0;
    final total = provider?.totalPriceAfter ?? 0.0;
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
          _SummaryRow(label: 'Provider', value: provider?.providerName ?? '-'),
          _SummaryRow(label: 'Subtotal', value: 'EGP ${_money(subtotal)}'),
          _SummaryRow(
            label: 'Discount',
            value: '- EGP ${_money(discount)}',
            valueColor: const Color(0xFF10B981),
          ),
          Divider(height: 20.h, color: const Color(0xFFD7D7D7)),
          _SummaryRow(
            label: 'Total amount',
            value: 'EGP ${_money(total)}',
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
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isBusy
            ? null
            : () => context.read<CartCubit>().createCartInvoice(),
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
                state.paymentMethod == CartPaymentMethod.visa
                    ? 'Pay with Visa'
                    : 'Pay',
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
              child: const Text('Retry'),
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
