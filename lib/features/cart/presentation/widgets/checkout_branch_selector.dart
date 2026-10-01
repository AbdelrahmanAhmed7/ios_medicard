import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_map_preview.dart';

class CheckoutBranchSelector extends StatelessWidget {
  final CartState state;

  const CheckoutBranchSelector({super.key, required this.state});

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
          if (selected != null) CheckoutMapPreview(branch: selected),
        ],
      ),
    );
  }
}
