import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_dropdown_menu_item.dart';
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E9F0)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: AppDropdownTheme(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selected?.branchId,
                    isExpanded: true,
                    style: AppTextStyles.of(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                    dropdownColor: AppDropdownTheme.menuColor,
                    elevation: AppDropdownTheme.menuElevation.toInt(),
                    borderRadius: AppDropdownTheme.dropdownBorderRadius,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280),
                    ),
                    hint: Text(
                      state.isCheckoutLoading
                          ? 'cart.loading_branches'.tr()
                          : 'provider_page.select_branch'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    items: state.checkoutBranches
                        .map(
                          (branch) => AppDropdownMenuItem(
                            value: branch.branchId,
                            label: branch.fullAddress ?? branch.branchName,
                            fontSize: 14,
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
                            context.read<CartCubit>().selectCheckoutBranch(
                              branch,
                            );
                          },
                  ),
                ),
              ),
            ),
          ),
          if (selected != null) CheckoutMapPreview(branch: selected),
        ],
      ),
    );
  }
}
