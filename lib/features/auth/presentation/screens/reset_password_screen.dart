import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

import '../../../../core/theming/app_text_styles.dart';


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
  static const int _passwordMinLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);

    for (final name in ['password', 'confirmPassword']) {
      _focusNodes[name] = FocusNode();
    }
  }

  void _onPasswordChanged() {
    if (_confirmController.text.isNotEmpty) {
      _confirmFieldKey.currentState?.validate();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
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

  bool _hasMinimumLength(String password) =>
      password.length >= _passwordMinLength;

  bool _hasLetter(String password) => RegExp(r'[A-Za-z]').hasMatch(password);

  bool _hasNumber(String password) => RegExp(r'[0-9]').hasMatch(password);

  bool _hasSpecialCharacter(String password) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password);

  bool _isPasswordValid(String password) {
    return _hasMinimumLength(password) &&
        _hasLetter(password) &&
        _hasNumber(password) &&
        _hasSpecialCharacter(password);
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'auth.forgot.password_required'.tr();
    if (!_isPasswordValid(password)) {
      return 'auth.register.passwordPolicyInvalid'.tr();
    }
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
                            style: AppTextStyles.of(
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
                            focusNode: _focusNodes['password'],
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                          SizedBox(height: 10.h),
                          _buildPasswordRequirements(),
                          SizedBox(height: 16.h),
                          AuthFieldLabel('auth.forgot.confirm_password'.tr()),
                          SizedBox(height: 6.h),
                          TextFormField(
                            key: _confirmFieldKey,
                            controller: _confirmController,
                            focusNode: _focusNodes['confirmPassword'],
                            obscureText: _obscureConfirm,
                            validator: _validateConfirm,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text.trim();
    final showInvalidRequirements = password.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.register.passwordRequirementsTitle'.tr(),
          style: AppTextStyles.of(
            fontSize: 12.sp,
            color: kAuthGreyText,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        _buildPasswordRequirement(
          label: 'auth.register.passwordMinLength'.tr(
            namedArgs: {'count': _passwordMinLength.toString()},
          ),
          isMet: _hasMinimumLength(password),
          showInvalid: showInvalidRequirements,
        ),
        _buildPasswordRequirement(
          label: 'auth.register.passwordLetter'.tr(),
          isMet: _hasLetter(password),
          showInvalid: showInvalidRequirements,
        ),
        _buildPasswordRequirement(
          label: 'auth.register.passwordNumber'.tr(),
          isMet: _hasNumber(password),
          showInvalid: showInvalidRequirements,
        ),
        _buildPasswordRequirement(
          label: 'auth.register.passwordSpecialCharacter'.tr(),
          isMet: _hasSpecialCharacter(password),
          showInvalid: showInvalidRequirements,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement({
    required String label,
    required bool isMet,
    required bool showInvalid,
  }) {
    final color = isMet
        ? Colors.green
        : showInvalid
        ? Colors.red
        : kAuthGreyText;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(
                fontSize: 12.sp,
                color: color,
                fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
