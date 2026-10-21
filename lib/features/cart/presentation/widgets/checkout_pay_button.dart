import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CheckoutPayButton extends StatelessWidget {
  final CartState state;

  const CheckoutPayButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isBusy = state.isCreatingInvoice;
    if (state.isInvoiceOutcomeUnknown && !isBusy) {
      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton(
          onPressed: () => _reconcile(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3872B1),
            side: const BorderSide(color: Color(0xFF3872B1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'cart.verify_invoice_status'.tr(),
            style: AppTextStyles.of(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    final paymentLink = state.createdInvoicePaymentLink;
    final hasPaymentLink = paymentLink != null && paymentLink.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed:
            isBusy ||
                (!hasPaymentLink &&
                    (state.isCheckoutLoading ||
                        state.isFamilyMembersLoading ||
                        state.checkoutError != null ||
                        state.selectedBranch == null))
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
            borderRadius: BorderRadius.circular(16.r),
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
                style: AppTextStyles.of(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Reconciles an ambiguous invoice outcome, then routes:
  /// created → activity (the charge exists), notCreated → safe to retry,
  /// stillUnknown → latch stays and the error message remains.
  Future<void> _reconcile(BuildContext context) async {
    final resolution = await context
        .read<CartCubit>()
        .reconcileUnknownInvoiceOutcome();
    if (!context.mounted) return;
    switch (resolution) {
      case UnknownInvoiceResolution.created:
        context.go('/medicard-home?tab=activity');
      case UnknownInvoiceResolution.notCreated:
        showSuccessToast('cart.invoice_not_created'.tr());
      case UnknownInvoiceResolution.stillUnknown:
        break;
    }
  }
}
