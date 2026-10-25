import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:medicard/core/widgets/app_simple_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicard/core/utils/image_url_resolver.dart';
import 'package:medicard/core/utils/relation_helper.dart';
import '../../../../core/widgets/app_dropdown_menu_item.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/family_member_model.dart';
import '../cubit/family_members_cubit.dart';
import '../cubit/family_members_state.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';

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

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null && mounted) {
        setState(() => _pickedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        showErrorToast('${"edit_profile.could_not_pick_image".tr()}: $e');
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

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
    if (!_formKey.currentState!.validate()) {
      dismissActiveToast();
      return;
    }
    final cubit = context.read<FamilyMembersCubit>();
    if (widget.member == null) {
      cubit.createFamilyMember(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        relation: _selectedRelation!,
        imagePath: _pickedImage?.path,
      );
    } else {
      cubit.updateFamilyMember(
        id: widget.member!.id!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        relation: _selectedRelation!,
        imagePath: _pickedImage?.path,
      );
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
              ),
              onPressed: () {
                context.pop();
              },
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
              ),
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
                  AppSimpleHeader(
                    title: widget.member == null
                        ? 'family_members.add_member'.tr()
                        : 'family_members.edit_member'.tr(),
                    actions: [
                      if (widget.member != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: const Color(0xFFDC2626),
                            size: 22.sp,
                          ),
                          onPressed: _showDeleteDialog,
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildAvatarPicker()),
                          SizedBox(height: 8.h),
                          Center(
                            child: Text(
                              'family_members.photo_hint'.tr(),
                              style: AppTextStyles.of(
                                fontSize: 12.5.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
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

  Widget _buildAvatarPicker() {
    final imageUrl = resolveImageUrl(widget.member?.imageUrl);
    final size = 96.r;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isPickingImage ? null : _pickImage,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F7FF),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _pickedImage != null
                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                  : imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _buildAvatarFallback(),
                      errorWidget: (_, _, _) => _buildAvatarFallback(),
                    )
                  : _buildAvatarFallback(),
            ),
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF3872B1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _isPickingImage
                    ? Padding(
                        padding: EdgeInsets.all(7.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_outlined,
                        size: 16.sp,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 46.sp,
        color: const Color(0xFF3872B1),
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
      style: AppTextStyles.of(
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
    if (!validNamePattern.hasMatch(name)) {
      return 'edit_profile.invalid_name'.tr();
    }
    return null;
  }

  Widget _buildRelationDropdown() {
    return AppDropdownTheme(
      child: DropdownButtonFormField<int>(
        initialValue: _selectedRelation,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null) {
            return 'common.required'.tr();
          }
          return null;
        },
        style: AppTextStyles.of(
          fontSize: 15.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade500,
          size: 20.sp,
        ),
        decoration: authInputDecoration(
          hintText: 'family_members.select_relation'.tr(),
        ),
        items: RelationHelper.getRelationsList().map((relation) {
          return AppDropdownMenuItem<int>(
            value: relation['id'] as int,
            label: relation['name'] as String,
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRelation = value;
          });
        },
      ),
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
        style: AppTextStyles.of(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
