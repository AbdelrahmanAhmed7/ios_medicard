import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/app_header_back_button.dart';
import '../../../../domain/medicard_repository.dart';

import 'package:medicard/core/theming/app_colors.dart';

class ManualPrescriptionScreen extends StatefulWidget {
  const ManualPrescriptionScreen({super.key});

  @override
  State<ManualPrescriptionScreen> createState() =>
      _ManualPrescriptionScreenState();
}

class _ManualPrescriptionScreenState extends State<ManualPrescriptionScreen> {
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  File? _image;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    final image = _image;
    final text = _textController.text.trim();
    if (image == null) return;
    setState(() => _isSubmitting = true);
    final result = await sl<MedicardRepository>().createManualPrescription(
      imagePath: image.path,
      text: text.isEmpty ? null : text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) {
        showSuccessToast('manual_prescription.upload_success'.tr());
        context.pop(true);
      },
      failure: (message) => showErrorToast(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteClr,
      body: SafeArea(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: AppHeaderSpacing.padding(top: 10.h, bottom: 6.h),
                child: Row(
                  children: [
                    AppHeaderBackButton(
                      color: AppColors.inkClr,
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'manual_prescription.title'.tr(),
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
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 230.h,
                      decoration: BoxDecoration(
                        color: AppColors.exactFFF1F5F9,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.lineClr),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48.sp,
                                  color: AppColors.brandBlueClr,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  'manual_prescription.choose_image'.tr(),
                                  style: AppTextStyles.of(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandBlueClr,
                                  ),
                                ),
                              ],
                            )
                          : Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text('manual_prescription.take_photo'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandBlueClr,
                      side: const BorderSide(color: AppColors.brandBlueClr),
                      minimumSize: Size.fromHeight(48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      textStyle: AppTextStyles.of(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'manual_prescription.text_label'.tr(),
                    style: AppTextStyles.of(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.exactFF334155,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'manual_prescription.text_hint'.tr(),
                      hintStyle: AppTextStyles.of(
                        fontSize: 13.sp,
                        color: AppColors.exactFF9CA3AF,
                      ),
                      filled: true,
                      fillColor: AppColors.exactFFF1F5F9,
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: AppColors.brandBlueClr,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _image == null
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlueClr,
                        foregroundColor: AppColors.whiteClr,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.whiteClr,
                              ),
                            )
                          : Text('manual_prescription.submit'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
