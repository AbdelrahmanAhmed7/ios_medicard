import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onResetPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().resetPassword(
      phoneNumber: widget.phoneNumber,
      password: _passwordController.text.trim(),
      confirmPassword: _confirmController.text.trim(),
    );
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'auth.forgot.password_required'.tr();
    return null;
  }

  String? _validateConfirm(String? value) {
    final confirm = value?.trim() ?? '';
    if (confirm.isEmpty) return 'auth.forgot.confirm_required'.tr();
    if (confirm != _passwordController.text.trim()) {
      return 'auth.forgot.password_mismatch'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        state.whenOrNull(
          resetSuccess: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showSuccessToast('auth.forgot.reset_success'.tr());
              context.go('/medicard-login');
            });
          },
          failed: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) showErrorToast(error);
            });
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: kAuthBackground,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthBlueHeader(
                      title: 'auth.forgot.reset_title'.tr(),
                      showBackButton: true,
                      onBack: () => context.pop(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28.h),
                          Text(
                            'auth.forgot.reset_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: kAuthGreyText,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          AuthFieldLabel('auth.forgot.new_password'.tr()),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            decoration: authInputDecoration(
                              hintText: 'auth.forgot.new_password_hint'.tr(),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: kAuthGreyText,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AuthFieldLabel('auth.forgot.confirm_password'.tr()),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscureConfirm,
                            validator: _validateConfirm,
                            decoration: authInputDecoration(
                              hintText: 'auth.forgot.confirm_hint'.tr(),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                }),
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: kAuthGreyText,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AuthPrimaryButton(
                            label: 'auth.forgot.reset_button'.tr(),
                            isLoading: isLoading,
                            onPressed: () => _onResetPressed(context),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
