import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/language_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';
import '../widgets/edit_profile/edit_profile_avatar.dart';
import '../widgets/edit_profile/edit_profile_labels.dart';
import '../widgets/edit_profile/edit_identity_section.dart';
import '../widgets/edit_profile/edit_name_row.dart';
import '../cubit/profile_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';

import 'package:medicard/core/theming/app_colors.dart';
class EditProfileScreen extends StatefulWidget {
  final ProfileData profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportNumberController = TextEditingController();
  // cardNumber is read-only — the backend does not allow updating it.
  final _cardNumberController = TextEditingController();
  final _birthDateController = TextEditingController();

  final Set<String> _touchedFields = {};
  final Map<String, FocusNode> _focusNodes = {};

  String _birthDate = '';
  bool? _isMale;
  File? _pickedImage;
  bool _removeImage = false;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null && mounted) {
        setState(() {
          _pickedImage = File(image.path);
          _removeImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(
          '${"edit_profile.could_not_pick_image".tr()}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  bool get _hasCurrentPhoto =>
      _pickedImage != null ||
      (!_removeImage && hasValidProfileImageUrl(widget.profileData.imageUrl));

  Future<void> _showImageOptions() async {
    if (_isSaving || _isPickingImage) return;
    final showRemove = _hasCurrentPhoto;
    try {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: AppColors.whiteClr,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.lineClr,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _SheetAction(
                    icon: Icons.photo_library_outlined,
                    label: 'edit_profile.change_photo'.tr(),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage();
                    },
                  ),
                  if (showRemove) ...[
                    SizedBox(height: 8.h),
                    _SheetAction(
                      icon: Icons.delete_outline_rounded,
                      label: 'edit_profile.remove_photo'.tr(),
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _removeCurrentImage();
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[EditProfile] showImageOptions error: $error');
      }
      if (mounted) {
        showErrorToast('${"edit_profile.could_not_pick_image".tr()}: $error');
      }
    }
  }

  Future<void> _removeCurrentImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('profile.remove_image'.tr()),
        content: Text('profile.remove_image_confirm'.tr()),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kAuthGreyText),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.exactFFDC2626,
              foregroundColor: AppColors.whiteClr,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('profile.remove_image'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final didDelete = await context.read<ProfileCubit>().deleteProfileImage(
      widget.profileData,
    );
    if (!mounted) return;

    if (didDelete) {
      setState(() {
        _pickedImage = null;
        _removeImage = true;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final initialDate = _birthDate.isNotEmpty
        ? DateTime.tryParse(_birthDate) ?? DateTime(1990)
        : DateTime(1990);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: kAuthBlue)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _birthDateController.text = _birthDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.profileData.firstName ?? '';
    _lastNameController.text = widget.profileData.lastName ?? '';
    _phoneNumberController.text = widget.profileData.phoneNumber ?? '';
    _nationalIdController.text = widget.profileData.nationalId ?? '';
    _passportNumberController.text = widget.profileData.passportNumber ?? '';
    _cardNumberController.text = widget.profileData.cardNumber ?? '';
    _birthDate = widget.profileData.birthDate ?? '';
    _birthDateController.text = _birthDate;
    _isMale = widget.profileData.isMale;

    for (final name in [
      'firstName',
      'lastName',
      'phoneNumber',
      'nationalId',
      'passportNumber',
    ]) {
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
    _phoneNumberController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    _cardNumberController.dispose();
    _birthDateController.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
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

  String? _validatePhoneNumber(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'common.required'.tr();
    var phone = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (phone.startsWith('+')) phone = phone.substring(1);
    if (phone.startsWith('20') && phone.length > 11) {
      phone = phone.substring(2);
    }
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (!RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(phone)) {
      return 'auth.register.phoneNumberInvalid'.tr();
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    final nationalId = LanguageHelper.convertArabicToEnglishNumerals(
      (value ?? '').trim(),
    );
    if (nationalId.isEmpty) return null;
    if (!RegExp(r'^[23][0-9]{13}$').hasMatch(nationalId)) {
      return 'auth.register.nationalIdInvalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.only(bottom: 24.h + bottomPadding),
              children: [
                const _EditProfileHeader(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPhotoCard(),
                      SizedBox(height: 14.h),
                      _buildFormCard(),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: AuthPrimaryButton(
                          label: 'common.update'.tr(),
                          isLoading: _isSaving,
                          onPressed: _isSaving ? () {} : _saveProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lineClr),
      ),
      child: Column(
        children: [
          EditProfileAvatar(
            imageFile: _pickedImage,
            isPickingImage: _isPickingImage,
            isUploading: _isSaving && _pickedImage != null,
            removeImage: _removeImage,
            imageUrl: widget.profileData.imageUrl,
            onPreviewTap: () => showProfileImagePreview(
              context,
              imageFile: _pickedImage,
              imageUrl: widget.profileData.imageUrl,
              removeImage: _removeImage,
            ),
            onEditTap: _showImageOptions,
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'edit_profile.change_photo'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 12.5.sp,
                color: kAuthGreyText,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lineClr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditProfileSectionTitle('edit_profile.personal_info'.tr()),
          SizedBox(height: 10.h),
          EditNameRow(
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            firstNameFocusNode: _focusNodes['firstName'],
            firstNameAutovalidate: _touchedFields.contains('firstName')
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            lastNameFocusNode: _focusNodes['lastName'],
            lastNameAutovalidate: _touchedFields.contains('lastName')
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            nameValidator: _validateName,
            lettersFormatters: [_lettersOnly()],
          ),
          SizedBox(height: 18.h),
          EditProfileSectionTitle('edit_profile.identity_info'.tr()),
          SizedBox(height: 10.h),
          EditIdentitySection(
            cardNumber: widget.profileData.cardNumber,
            cardNumberController: _cardNumberController,
            nationalIdController: _nationalIdController,
            nationalIdFocusNode: _focusNodes['nationalId'],
            nationalIdAutovalidate: _touchedFields.contains('nationalId')
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            digitsFormatters: [_digitsOnly(maxDigits: 14)],
            nationalIdValidator: _validateNationalId,
            passportNumberController: _passportNumberController,
            passportNumberFocusNode: _focusNodes['passportNumber'],
            passportNumberAutovalidate:
                _touchedFields.contains('passportNumber')
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            phoneNumberController: _phoneNumberController,
            phoneNumberFocusNode: _focusNodes['phoneNumber'],
            phoneNumberAutovalidate: _touchedFields.contains('phoneNumber')
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            phoneNumberValidator: _validatePhoneNumber,
            birthDateController: _birthDateController,
            birthDateIsEmpty: _birthDate.isEmpty,
            onSelectBirthDate: _selectBirthDate,
            isMale: _isMale,
            onGenderChanged: (val) {
              setState(() {
                _isMale = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      dismissActiveToast();
      return;
    }

    // If the user never changed the gender dropdown, use the value from the
    // original API data rather than defaulting to a hardcoded value.
    final isMaleToSend = _isMale ?? widget.profileData.isMale ?? true;
    setState(() => _isSaving = true);

    final cubit = context.read<ProfileCubit>();
    final didUpdate = await cubit.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      nationalId: LanguageHelper.convertArabicToEnglishNumerals(
        _nationalIdController.text.trim(),
      ),
      passportNumber: _passportNumberController.text.trim().isEmpty
          ? null
          : _passportNumberController.text.trim(),
      isMale: isMaleToSend,
      birthDate: _birthDate,
      imagePath: _pickedImage?.path,
      removeImage: _removeImage,
      currentData: widget.profileData,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Pop immediately on success so the edit screen is dismissed before
    // the cubit emits loading state (which would remove ProfileContent
    // from the IndexedStack while we're still navigating).
    if (didUpdate) context.pop();
  }

  TextInputFormatter _digitsOnly({required int maxDigits}) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final normalized = LanguageHelper.convertArabicToEnglishNumerals(
        newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (normalized.length > maxDigits) return oldValue;
      return newValue.copyWith(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    });
  }

  TextInputFormatter _lettersOnly() {
    return FilteringTextInputFormatter.allow(
      RegExp(r"[\p{L} .'\-]", unicode: true),
    );
  }
}

/// Full-width row in the photo action sheet, matching the app's sheet style
/// instead of a bare [ListTile].
class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? AppColors.exactFFDC2626
        : AppColors.inkClr;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.exactFFF8FAFC,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.lineClr),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: foreground),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                    height: 1.3,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.inkFaintClr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same header as the other account screens: back + bold title on the page
/// background (no full-bleed banner).
class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppHeaderSpacing.padding(top: 16.h, bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppHeaderBackButton(
            color: AppColors.inkClr,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Text(
              'edit_profile.title'.tr(),
              style: AppTextStyles.of(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.inkClr,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

