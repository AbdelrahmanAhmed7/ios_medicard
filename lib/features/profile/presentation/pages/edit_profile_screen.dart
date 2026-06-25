import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  String _birthDate = '2000-01-01';
  bool? _isMale;
  File? _pickedImage;
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"edit_profile.could_not_pick_image".tr()}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_birthDate),
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
    _birthDate = widget.profileData.birthDate ?? '2000-01-01';
    _isMale = widget.profileData.isMale;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Map<String, String> _getBirthDateParts() {
    try {
      final dateTime = DateTime.parse(_birthDate);
      return {
        'day': dateTime.day.toString().padLeft(2, '0'),
        'month': dateTime.month.toString().padLeft(2, '0'),
        'year': dateTime.year.toString(),
      };
    } catch (_) {
      return {'day': 'DD', 'month': 'MM', 'year': 'YYYY'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final dateParts = _getBirthDateParts();

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
                  clipBehavior: Clip.none,
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
                    Positioned(
                      bottom: -50.h,
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
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'common.required'.tr()
                                      : null,
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
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'common.required'.tr()
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // رقم الكارت (Passport or Card Number)
                      _FieldLabel('edit_profile.card_number'.tr()),
                      _buildTextField(
                        controller: _passportNumberController,
                        hintText: '1020212*****',
                        required: false,
                      ),
                      SizedBox(height: 14.h),

                      // الرقم القومي
                      _FieldLabel('edit_profile.national_id'.tr()),
                      _buildTextField(
                        controller: _nationalIdController,
                        hintText: 'edit_profile.national_id'.tr(),
                        keyboardType: TextInputType.number,
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
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      _FieldLabel('edit_profile.date_of_birth'.tr()),
                      GestureDetector(
                        onTap: _selectBirthDate,
                        child: Row(
                          children: [
                            _buildDatePartBox(dateParts['month']!, 'MM'),
                            SizedBox(width: 10.w),
                            _buildDatePartBox(dateParts['day']!, 'DD'),
                            SizedBox(width: 10.w),
                            _buildDatePartBox(dateParts['year']!, 'YY'),
                          ],
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      context.read<ProfileCubit>().updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        passportNumber: _passportNumberController.text.trim().isEmpty
            ? null
            : _passportNumberController.text.trim(),
        isMale: _isMale ?? true,
        birthDate: _birthDate,
        imagePath: _pickedImage?.path,
        currentData: widget.profileData,
      );
      if (mounted) context.pop();
    }
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
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, size: 55, color: Colors.white),
    );
  }

  // بناء الصورة الشخصية المتداخلة مع زر تعديل يطابق الصورة تماماً
  Widget _buildOverlappingProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
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
                : _buildRemoteProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 2.h,
          end: 2.w,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: kAuthBlue, width: 1),
              ),
              child: Icon(Icons.edit_outlined, size: 14.sp, color: kAuthBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
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

  Widget _buildDatePartBox(String value, String placeholder) {
    return Expanded(
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                color: value == placeholder
                    ? Colors.grey.shade400
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500,
              size: 20.sp,
            ),
          ],
        ),
      ),
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
