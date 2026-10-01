import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_dropdown_frame.dart';

class CheckoutPaymentDropdown extends StatelessWidget {
  final CartState state;

  const CheckoutPaymentDropdown({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return CheckoutDropdownFrame(
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
