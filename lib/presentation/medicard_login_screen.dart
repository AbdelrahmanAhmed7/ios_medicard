import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/theming/app_toast.dart';
import '../core/utils/language_helper.dart';
import '../core/widgets/auth_shared_widgets.dart';
import 'logic/medicard_login_cubit.dart';
import 'logic/medicard_login_state.dart';

class MediCardLoginScreen extends StatefulWidget {
  const MediCardLoginScreen({super.key});

  @override
  State<MediCardLoginScreen> createState() => _MediCardLoginScreenState();
}

class _MediCardLoginScreenState extends State<MediCardLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final phoneNumber = LanguageHelper.convertArabicToEnglishNumerals(
        _phoneNumberController.text.trim(),
      );
      final password = LanguageHelper.convertArabicToEnglishNumerals(
        _passwordController.text.trim(),
      );
      context.read<MedicardLoginCubit>().login(
        phoneNumber: phoneNumber,
        password: password,
      );
    } else {
      showErrorToast('auth.login.fillAllFields'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardLoginCubit, MedicardLoginState>(
      listenWhen: (_, _) => true,
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (response) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/medicard-home');
            });
          },
          failed: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) showErrorToast(error);
            });
          },
        );
      },
      buildWhen: (_, _) => true,
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
                    // ── Blue Header ──────────────────────────────────────
                    const AuthBlueHeader(title: 'Welcome to Medicard'),

                    // ── Form Section ─────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28.h),

                          // Sign In title
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Mobile/Medicard Number field
                          const AuthFieldLabel('Mobile/Medicard Number'),
                          SizedBox(height: 6.h),
                          _buildPhoneField(),
                          SizedBox(height: 16.h),

                          // Password row label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AuthFieldLabel('Password'),
                              GestureDetector(
                                onTap: () {
                                  // TODO: forgot password
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: kAuthBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          _buildPasswordField(),
                          SizedBox(height: 16.h),

                          // Don't have an account
                          Row(
                            children: [
                              Text(
                                "Don't have an account ",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/medicard-register'),
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: kAuthBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Next Button
                          AuthPrimaryButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: () => _onLoginPressed(context),
                          ),
                          SizedBox(height: 20.h),

                          // Or divider
                          _OrDivider(),
                          SizedBox(height: 20.h),

                          // Activate Card Button
                          _ActivateCardButton(
                            onPressed: () => context.push('/medicard-activation'),
                          ),
                          SizedBox(height: 20.h),

                          // Continue as Guest Button
                          _ContinueAsGuestButton(
                            onPressed: () => context.go('/guest-home'),
                          ),
                          SizedBox(height: 32.h),
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

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneNumberController,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(hintText: '1920237338637'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'auth.login.phoneNumberRequired'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(
        hintText: '••••••••',
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kAuthGreyText,
            size: 20.sp,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'auth.login.passwordRequired'.tr();
        }
        return null;
      },
    );
  }
}

// ── Or Divider ──────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Or',
            style: TextStyle(fontSize: 13.sp, color: kAuthGreyText),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
      ],
    );
  }
}

// ── Activate Card Button ─────────────────────────────────────────────────────

class _ActivateCardButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ActivateCardButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kAuthBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: Colors.white,
        ),
        child: Text(
          'Activate Card',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: kAuthBlue,
          ),
        ),
      ),
    );
  }
}

// ── Continue as Guest Button ─────────────────────────────────────────────────

class _ContinueAsGuestButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ContinueAsGuestButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Continue as Guest',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
