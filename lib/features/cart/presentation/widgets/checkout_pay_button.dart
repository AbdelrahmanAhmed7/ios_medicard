import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CheckoutPayButton extends StatelessWidget {
  final CartState state;

  const CheckoutPayButton({super.key, required this.state});

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
                style: AppTextStyles.of(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
