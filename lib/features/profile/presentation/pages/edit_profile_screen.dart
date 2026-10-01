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
import '../widgets/edit_profile/edit_identity_section.dart';
import '../widgets/edit_profile/edit_name_row.dart';
import '../cubit/profile_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${"edit_profile.could_not_pick_image".tr()}: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  bool get _hasCurrentPhoto =>
      _pickedImage != null ||
      (!_removeImage &&
          hasValidProfileImageUrl(widget.profileData.imageUrl));

  Future<void> _showImageOptions() async {
    final showRemove = _hasCurrentPhoto;
    try {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library_outlined,
                      color: kAuthBlue,
                    ),
                    title: Text(
                      'edit_profile.change_photo'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage();
                    },
                  ),
                  if (showRemove) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      title: Text(
                        'edit_profile.remove_photo'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _removeCurrentImage();
                      },
                    ),
                  ],
                  SizedBox(height: 8.h),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${"edit_profile.could_not_pick_image".tr()}: $error',
            ),
          ),
        );
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
      'firstName', 'lastName', 'phoneNumber', 'nationalId', 'passportNumber',
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
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 140.h + statusBarHeight,
                      decoration: const BoxDecoration(
                        color: kAuthBlue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        statusBarHeight + 12.h,
                        16.w,
                        0,
                      ),
                      alignment: AlignmentDirectional.topStart,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    SizedBox(width: double.infinity, height: 50.h),
                    Positioned(
                      bottom: 0,
                      child: EditProfileAvatar(
                      imageFile: _pickedImage,
                      isPickingImage: _isPickingImage,
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
                    ),
                  ],
                ),

                SizedBox(height: 70.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 14.h),

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
                        passportNumberAutovalidate: _touchedFields.contains('passportNumber')
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

                      AuthPrimaryButton(
                        label: 'common.update'.tr(),
                        isLoading: _isSaving,
                        onPressed: _isSaving ? () {} : _saveProfile,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h + bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('errors.validation_failed'.tr())));
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
