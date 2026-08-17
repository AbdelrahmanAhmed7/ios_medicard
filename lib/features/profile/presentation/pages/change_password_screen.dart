import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/utils/language_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../cubit/change_password_cubit.dart';
import '../cubit/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const int _passwordMinLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onNewPasswordChanged);
    _newPasswordFocus.addListener(_onNewPasswordFocusChanged);
    _confirmPasswordFocus.addListener(_onConfirmPasswordFocusChanged);
  }

  void _onNewPasswordFocusChanged() {
    if (_newPasswordFocus.hasFocus && !_newPasswordTouched) {
      setState(() => _newPasswordTouched = true);
    }
  }

  void _onConfirmPasswordFocusChanged() {
    if (_confirmPasswordFocus.hasFocus && !_confirmPasswordTouched) {
      setState(() => _confirmPasswordTouched = true);
    }
  }

  void _onNewPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _confirmPasswordFieldKey.currentState?.validate();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onNewPasswordChanged);
    _newPasswordFocus.removeListener(_onNewPasswordFocusChanged);
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.removeListener(_onConfirmPasswordFocusChanged);
    _confirmPasswordFocus.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChangePasswordCubit>().changePassword(
      currentPassword: LanguageHelper.convertArabicToEnglishNumerals(
        _currentPasswordController.text.trim(),
      ),
      newPassword: LanguageHelper.convertArabicToEnglishNumerals(
        _newPasswordController.text.trim(),
      ),
      confirmNewPassword: LanguageHelper.convertArabicToEnglishNumerals(
        _confirmPasswordController.text.trim(),
      ),
    );
  }

  String? _validateNewPassword(String? value) {
    final password = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );
    if (password.isEmpty) return 'change_password.new_password_required'.tr();
    if (!_isPasswordValid(password)) {
      return 'change_password.password_policy_invalid'.tr();
    }
    return null;
  }

  bool _isPasswordValid(String password) {
    return password.length >= _passwordMinLength &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('change_password.success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          },
          failure: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
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
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kAuthBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      statusBarHeight + 12.h,
                      16.w,
                      24.h,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'profile.change_password'.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('change_password.current_password'.tr()),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hintText: 'change_password.current_password_hint'
                              .tr(),
                          showPassword: _showCurrentPassword,
                          onToggle: () => setState(
                            () => _showCurrentPassword = !_showCurrentPassword,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'change_password.current_password_required'
                                  .tr();
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        _FieldLabel('change_password.new_password'.tr()),
                        _buildPasswordField(
                          focusNode: _newPasswordFocus,
                          autovalidateMode: _newPasswordTouched
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          controller: _newPasswordController,
                          hintText: 'change_password.new_password_hint'.tr(),
                          showPassword: _showNewPassword,
                          onToggle: () => setState(
                            () => _showNewPassword = !_showNewPassword,
                          ),
                          validator: _validateNewPassword,
                        ),

                        SizedBox(height: 16.h),

                        _FieldLabel(
                          'change_password.confirm_new_password'.tr(),
                        ),
                        _buildPasswordField(
                          fieldKey: _confirmPasswordFieldKey,
                          focusNode: _confirmPasswordFocus,
                          autovalidateMode: _confirmPasswordTouched
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          controller: _confirmPasswordController,
                          hintText: 'change_password.confirm_new_password_hint'
                              .tr(),
                          showPassword: _showConfirmPassword,
                          onToggle: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          ),
                          validator: (v) {
                            final confirmPassword =
                                LanguageHelper.convertArabicToEnglishNumerals(
                                  v?.trim() ?? '',
                                );
                            final newPassword =
                                LanguageHelper.convertArabicToEnglishNumerals(
                                  _newPasswordController.text.trim(),
                                );
                            if (confirmPassword.isEmpty) {
                              return 'change_password.confirm_new_password_required'
                                  .tr();
                            }
                            if (confirmPassword != newPassword) {
                              return 'auth.register.passwordsNotMatch'.tr();
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 36.h),

                        BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                          builder: (context, state) {
                            final isLoading = state.maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            );
                            return AuthPrimaryButton(
                              label: 'common.save'.tr(),
                              isLoading: isLoading,
                              onPressed: isLoading ? () {} : _submit,
                            );
                          },
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
      ),
    );
  }

  Widget _buildPasswordField({
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    FocusNode? focusNode,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      obscureText: !showPassword,
      autovalidateMode: autovalidateMode,
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
        suffixIcon: IconButton(
          icon: Icon(
            showPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade500,
            size: 20.sp,
          ),
          onPressed: onToggle,
        ),
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
      validator: validator,
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
