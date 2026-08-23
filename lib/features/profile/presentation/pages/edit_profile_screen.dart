import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../cubit/profile_cubit.dart';

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
      (!_removeImage && _hasValidImageUrl(widget.profileData.imageUrl));

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
                      style: TextStyle(
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
                        style: TextStyle(
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

  Widget _currentPhotoWidget({bool cover = true}) {
    if (_pickedImage != null) {
      return Image.file(
        _pickedImage!,
        fit: cover ? BoxFit.cover : BoxFit.contain,
      );
    }
    if (_hasValidImageUrl(widget.profileData.imageUrl)) {
      return CachedNetworkImage(
        imageUrl: widget.profileData.imageUrl!,
        fit: cover ? BoxFit.cover : BoxFit.contain,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) =>
            const Icon(Icons.person, size: 55),
      );
    }
    return _buildPlaceholderAvatar();
  }

  void _showImagePreview() {
    if (!_hasCurrentPhoto || _removeImage) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          behavior: HitTestBehavior.opaque,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.all(16.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 280.r,
                    height: 280.r,
                    child: _currentPhotoWidget(cover: true),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      child: _buildOverlappingProfileImage(),
                    ),
                  ],
                ),

                SizedBox(height: 70.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('edit_profile.name'.tr()),
                                _buildTextField(
                                  controller: _firstNameController,
                                  hintText: 'edit_profile.first_name'.tr(),
                                  validator: _validateName,
                                  focusKey: 'firstName',
                                  inputFormatters: [_lettersOnly()],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('edit_profile.last_name'.tr()),
                                _buildTextField(
                                  controller: _lastNameController,
                                  hintText: 'edit_profile.last_name'.tr(),
                                  validator: _validateName,
                                  focusKey: 'lastName',
                                  inputFormatters: [_lettersOnly()],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Card Number — read-only; shown only when returned by the backend
                      if ((widget.profileData.cardNumber ?? '')
                          .trim()
                          .isNotEmpty) ...[
                        _FieldLabel('edit_profile.card_number'.tr()),
                        _buildTextField(
                          controller: _cardNumberController,
                          hintText: 'edit_profile.card_number'.tr(),
                          required: false,
                          readOnly: true,
                        ),
                        SizedBox(height: 14.h),
                      ],

                      _buildRequiredHint(
                        'auth.register.nationalIdOrPassportRequired'.tr(),
                      ),
                      SizedBox(height: 10.h),

                      // الرقم القومي
                      _FieldLabel('edit_profile.national_id'.tr()),
                      _buildTextField(
                        controller: _nationalIdController,
                        hintText: 'edit_profile.national_id'.tr(),
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                        focusKey: 'nationalId',
                        inputFormatters: [_digitsOnly(maxDigits: 14)],
                        validator: _validateNationalId,
                      ),
                      SizedBox(height: 14.h),

                      // Passport Number
                      _FieldLabel('edit_profile.passport_number'.tr()),
                      _buildTextField(
                        controller: _passportNumberController,
                        hintText: 'edit_profile.passport_number'.tr(),
                        required: false,
                        focusKey: 'passportNumber',
                      ),
                      SizedBox(height: 14.h),

                      _FieldLabel('edit_profile.phone_number'.tr()),
                      Row(
                        children: [
                          Container(
                            width: 65.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '+20',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneNumberController,
                              hintText: 'edit_profile.phone_number'.tr(),
                              keyboardType: TextInputType.phone,
                              maxLength: 11,
                              focusKey: 'phoneNumber',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: _validatePhoneNumber,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      _FieldLabel('edit_profile.date_of_birth'.tr()),
                      GestureDetector(
                        onTap: _selectBirthDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _birthDateController,
                            readOnly: true,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: _birthDate.isEmpty
                                  ? Colors.grey.shade400
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'edit_profile.date_of_birth'.tr(),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: kAuthBlue,
                                  width: 1.2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.2,
                                ),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                color: kAuthGreyText,
                                size: 18.sp,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'common.required'.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      _FieldLabel('edit_profile.gender'.tr()),
                      _buildGenderDropdown(),

                      SizedBox(height: 32.h),

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

  // Returns true only when the URL points to an actual resource, not just a bare domain.
  bool _hasValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    // Reject bare-domain URLs like "https://domain.com/" (path is "/" or empty, no meaningful segments)
    final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return pathSegments.isNotEmpty;
  }

  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, size: 55, color: Colors.white),
    );
  }

  Widget _buildRemoteProfileImage() {
    if (_hasValidImageUrl(widget.profileData.imageUrl)) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.profileData.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[200]),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 55),
        ),
      );
    }
    return _buildPlaceholderAvatar();
  }

  // بناء الصورة الشخصية المتداخلة مع زر تعديل يطابق الصورة تماماً
  Widget _buildOverlappingProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showImagePreview,
          child: Container(
            width: 110.r,
            height: 110.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _pickedImage != null
                ? ClipOval(child: Image.file(_pickedImage!, fit: BoxFit.cover))
                : _isPickingImage
                ? Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: kAuthBlue,
                          ),
                        ),
                      ),
                    ),
                  )
                : _removeImage
                ? _buildPlaceholderAvatar()
                : _buildRemoteProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 2.h,
          end: 2.w,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showImageOptions,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: kAuthBlue, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.edit_outlined, size: 18.sp, color: kAuthBlue),
            ),
          ),
        ),
      ],
    );
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool required = true,
    bool readOnly = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? focusKey,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusKey != null ? _focusNodes[focusKey] : null,
      autovalidateMode: focusKey != null && _touchedFields.contains(focusKey)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: TextStyle(
        fontSize: 15.sp,
        color: readOnly ? Colors.grey.shade500 : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
        counterText: '',
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: readOnly ? Colors.grey.shade300 : kAuthBlue,
            width: readOnly ? 1.0 : 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      ),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.isEmpty) ? 'common.required'.tr() : null
              : null),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<bool>(
      initialValue: _isMale,
      hint: Text(
        'edit_profile.select_an_option'.tr(),
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
      ),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: kAuthBlue, width: 1.2),
        ),
      ),
      items: [
        DropdownMenuItem(value: true, child: Text('edit_profile.male'.tr())),
        DropdownMenuItem(value: false, child: Text('edit_profile.female'.tr())),
      ],
      onChanged: (val) {
        setState(() {
          _isMale = val;
        });
      },
    );
  }

  Widget _buildRequiredHint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '*',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
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
