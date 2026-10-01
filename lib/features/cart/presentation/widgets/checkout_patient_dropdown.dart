import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/family_members/data/models/family_member_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_dropdown_frame.dart';

class CheckoutPatientDropdown extends StatelessWidget {
  final CartState state;

  const CheckoutPatientDropdown({super.key, required this.state});

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

    return CheckoutDropdownFrame(
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
