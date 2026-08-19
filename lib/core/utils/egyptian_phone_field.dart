import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/app_colors.dart';

/// Reusable Egyptian phone number field with flag and +20 prefix
class EgyptianPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final String phoneRequiredKey;
  final String phoneInvalidKey;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  const EgyptianPhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText,
    required this.phoneRequiredKey,
    required this.phoneInvalidKey,
    this.onChanged,
    this.maxLength,
  });

  @override
  State<EgyptianPhoneField> createState() => _EgyptianPhoneFieldState();
}

class _EgyptianPhoneFieldState extends State<EgyptianPhoneField> {
  final _focusNode = FocusNode();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_touched) {
        setState(() => _touched = true);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Default validator for Egyptian phone numbers
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return widget.phoneRequiredKey.tr();
    }
    String cleanValue = value.startsWith('0') ? value.substring(1) : value;

    if (cleanValue.isEmpty) {
      return widget.phoneRequiredKey.tr();
    }

    if (!RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanValue)) {
      return widget.phoneInvalidKey.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final effectiveValidator = widget.validator ?? _defaultValidator;

    return FormField<String>(
      autovalidateMode: _touched
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: effectiveValidator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: isRTL
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.whiteClr,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: isRTL
                          ? BorderRadius.only(
                              topRight: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r),
                            )
                          : BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              bottomLeft: Radius.circular(8.r),
                            ),
                    ),
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🇪🇬', style: TextStyle(fontSize: 20.sp)),
                          SizedBox(width: 4.w),
                          Text(
                            '+20',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        border: Border(
                          top: BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          ),
                          left: isRTL
                              ? BorderSide.none
                              : BorderSide(
                                  color: fieldState.hasError
                                      ? AppColors.errorClr
                                      : Colors.grey.shade300,
                                ),
                          right: isRTL
                              ? BorderSide(
                                  color: fieldState.hasError
                                      ? AppColors.errorClr
                                      : Colors.grey.shade300,
                                )
                              : BorderSide.none,
                          bottom: BorderSide(
                            color: fieldState.hasError
                                ? AppColors.errorClr
                                : Colors.grey.shade300,
                          ),
                        ),
                        borderRadius: isRTL
                            ? BorderRadius.only(
                                topLeft: Radius.circular(8.r),
                                bottomLeft: Radius.circular(8.r),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(8.r),
                                bottomRight: Radius.circular(8.r),
                              ),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        maxLength: widget.maxLength,
                        keyboardType: TextInputType.phone,
                        textDirection: ui.TextDirection.ltr,
                        style: TextStyle(fontSize: 14.sp),
                        onChanged: (value) {
                          fieldState.didChange(value);
                          if (_touched) fieldState.validate();
                          widget.onChanged?.call(value);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          hintText: widget.hintText ?? 'auth.signup.validation.phone_hint'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: AppColors.whiteClr,
                          isDense: true,
                          counterText: "",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 8.w),
                child: Text(
                  fieldState.errorText ?? '',
                  style: TextStyle(
                    color: AppColors.errorClr,
                    fontSize: 12.sp,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
