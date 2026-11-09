import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_dropdown_menu_item.dart';
import '../../../../features/family_members/data/models/family_member_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_dropdown_frame.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CheckoutPatientDropdown extends StatelessWidget {
  final CartState state;

  const CheckoutPatientDropdown({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<int>>[
      AppDropdownMenuItem<int>(
        value: 0,
        label: 'cart.card_owner'.tr(),
        fontSize: 14,
      ),
      ...state.familyMembers.map(
        (member) => AppDropdownMenuItem<int>(
          value: member.id ?? -1,
          label: _memberName(member),
          fontSize: 14,
        ),
      ),
    ];

    return CheckoutDropdownFrame(
      child: AppDropdownTheme(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: state.selectedFamilyMember?.id ?? 0,
            isExpanded: true,
            style: AppTextStyles.of(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.inkClr,
            ),
            dropdownColor: AppDropdownTheme.menuColor,
            elevation: AppDropdownTheme.menuElevation.toInt(),
            borderRadius: AppDropdownTheme.dropdownBorderRadius,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.exactFF6B7280,
            ),
            items: items,
            hint: Text(
              state.isFamilyMembersLoading
                  ? 'cart.loading_patients'.tr()
                  : 'cart.select_patient'.tr(),
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: AppColors.exactFF9CA3AF,
              ),
            ),
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
      ),
    );
  }

  String _memberName(FamilyMemberModel member) {
    if (member.fullName?.isNotEmpty == true) return member.fullName!;
    return '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
  }
}

