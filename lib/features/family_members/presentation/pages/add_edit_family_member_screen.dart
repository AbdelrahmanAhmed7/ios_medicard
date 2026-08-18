import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/utils/relation_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/family_member_model.dart';
import '../cubit/family_members_cubit.dart';
import '../cubit/family_members_state.dart';

class AddEditFamilyMemberScreen extends StatefulWidget {
  final FamilyMemberModel? member;

  const AddEditFamilyMemberScreen({super.key, this.member});

  @override
  State<AddEditFamilyMemberScreen> createState() =>
      _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends State<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  int? _selectedRelation;

  final Set<String> _touchedFields = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _firstNameController.text = widget.member!.firstName ?? '';
      _lastNameController.text = widget.member!.lastName ?? '';
      _selectedRelation = widget.member!.relation;
    }

    for (final name in ['firstName', 'lastName']) {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          setState(() => _touchedFields.add(name));
        }
      });
      _focusNodes[name] = node;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<FamilyMembersCubit>();
      if (widget.member == null) {
        cubit.createFamilyMember(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          relation: _selectedRelation!,
        );
      } else {
        cubit.updateFamilyMember(
          id: widget.member!.id!,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          relation: _selectedRelation!,
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('family_members.delete_member'.tr()),
          content: Text('family_members.delete_member_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                context.read<FamilyMembersCubit>().deleteFamilyMember(
                  id: widget.member!.id!,
                );
              },
              child: Text('common.delete'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: BlocConsumer<FamilyMembersCubit, FamilyMembersState>(
          listener: (context, state) {
            state.maybeWhen(
              created: () {
                if (context.mounted) {
                  context.pop();
                }
              },
              updated: () {
                if (context.mounted) {
                  context.pop();
                }
              },
              deleted: () {
                if (context.mounted) {
                  context.pop();
                }
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              creating: () => true,
              updating: () => true,
              deleting: () => true,
              orElse: () => false,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D5FA6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      statusBarHeight + 12.h,
                      16.w,
                      20.h,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.member == null
                                ? 'family_members.add_member'.tr()
                                : 'family_members.edit_member'.tr(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        widget.member != null
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white),
                                onPressed: _showDeleteDialog,
                              )
                            : SizedBox(width: 40.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('edit_profile.first_name'.tr()),
                          _buildTextField(
                            controller: _firstNameController,
                            hint: 'edit_profile.first_name'.tr(),
                            focusKey: 'firstName',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[\p{L} .'\-]", unicode: true),
                              ),
                            ],
                            validator: _validateName,
                          ),
                          SizedBox(height: 14.h),
                          _FieldLabel('edit_profile.last_name'.tr()),
                          _buildTextField(
                            controller: _lastNameController,
                            hint: 'edit_profile.last_name'.tr(),
                            focusKey: 'lastName',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[\p{L} .'\-]", unicode: true),
                              ),
                            ],
                            validator: _validateName,
                          ),
                          SizedBox(height: 14.h),
                          _FieldLabel('family_members.relation'.tr()),
                          _buildRelationDropdown(),
                          SizedBox(height: 32.h),
                          AuthPrimaryButton(
                            label: widget.member == null
                                ? 'common.save'.tr()
                                : 'common.update'.tr(),
                            isLoading: isLoading,
                            onPressed: isLoading ? () {} : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? focusKey,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusKey != null ? _focusNodes[focusKey] : null,
      autovalidateMode: focusKey != null && _touchedFields.contains(focusKey)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: authInputDecoration(hintText: hint),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'common.required'.tr();
    if (name.length < 2) return 'edit_profile.invalid_name'.tr();
    final validNamePattern = RegExp(r"^[\p{L}][\p{L} .'\-]*$", unicode: true);
    if (!validNamePattern.hasMatch(name)) return 'edit_profile.invalid_name'.tr();
    return null;
  }

  Widget _buildRelationDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedRelation,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null) {
          return 'common.required'.tr();
        }
        return null;
      },
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade500,
        size: 20.sp,
      ),
      decoration: authInputDecoration(hintText: 'family_members.select_relation'.tr()),
      items: RelationHelper.getRelationsList().map((relation) {
        return DropdownMenuItem<int>(
          value: relation['id'] as int,
          child: Text(relation['name'] as String),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRelation = value;
        });
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
