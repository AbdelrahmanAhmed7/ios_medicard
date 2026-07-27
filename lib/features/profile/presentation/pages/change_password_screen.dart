import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
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
    if (password.isEmpty) return 'New password is required';
    if (!_isPasswordValid(password)) {
      return 'Password must contain at least 8 characters, one letter, one number, and one special character';
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
              const SnackBar(
                content: Text('Password changed successfully'),
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
                          'Change Password',
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
                        _FieldLabel('Current Password'),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hintText: 'Enter current password',
                          showPassword: _showCurrentPassword,
                          onToggle: () => setState(
                            () => _showCurrentPassword = !_showCurrentPassword,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        _FieldLabel('New Password'),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'Enter new password',
                          showPassword: _showNewPassword,
                          onToggle: () => setState(
                            () => _showNewPassword = !_showNewPassword,
                          ),
                          validator: _validateNewPassword,
                        ),

                        SizedBox(height: 16.h),

                        _FieldLabel('Confirm New Password'),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter new password',
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
                              return 'Please confirm your new password';
                            }
                            if (confirmPassword != newPassword) {
                              return 'Passwords do not match';
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
                              label: 'Save',
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
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
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
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
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
