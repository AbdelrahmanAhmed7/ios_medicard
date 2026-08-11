import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
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
  final _loginIdentifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final identifier = LanguageHelper.convertArabicToEnglishNumerals(
        _loginIdentifierController.text.trim(),
      );
      final password = LanguageHelper.convertArabicToEnglishNumerals(
        _passwordController.text.trim(),
      );
      final loginIdentifier = _parseLoginIdentifier(identifier);
      context.read<MedicardLoginCubit>().login(
        cardNumber: loginIdentifier.cardNumber,
        phoneNumber: loginIdentifier.phoneNumber,
        password: password,
      );
    } else {
      showErrorToast('auth.login.fillAllFields'.tr());
    }
  }

  String? _validateLoginIdentifier(String? value) {
    final identifier = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );

    if (identifier.isEmpty) {
      return 'auth.login.phoneNumberRequired'.tr();
    }

    if (_isEgyptianMobile(identifier)) {
      return null;
    }

    if (_isPotentialCardNumber(identifier)) {
      return null;
    }

    return 'auth.login.identifierInvalid'.tr();
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
              if (!mounted) return;
              context.go('/medicard-home');
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Blue Header ──────────────────────────────────────
                    AuthBlueHeader(title: 'auth.welcomeTitle'.tr()),

                    // ── Form Section ─────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28.h),

                          // Sign In title
                          Text(
                            'auth.login.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Mobile/Medicard Number field
                          AuthFieldLabel('auth.login.mobileOrCardNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildPhoneField(),
                          SizedBox(height: 16.h),

                          // Password row label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AuthFieldLabel('auth.login.password'.tr()),
                              GestureDetector(
                                onTap: () {
                                  context.push('/forgot-password');
                                },
                                child: Text(
                                  'auth.login.forgotPassword'.tr(),
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
                                'auth.login.dontHaveAccount'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () => context.push('/medicard-register'),
                                child: Text(
                                  'auth.login.registerNow'.tr(),
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
                            label: 'auth.login.loginButton'.tr(),
                            isLoading: isLoading,
                            onPressed: () => _onLoginPressed(context),
                          ),
                          SizedBox(height: 20.h),

                          // Or divider
                          _OrDivider(),
                          SizedBox(height: 20.h),

                          // Activate Card Button
                          _ActivateCardButton(
                            onPressed: () =>
                                context.push('/medicard-activation'),
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
      controller: _loginIdentifierController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      maxLength: 12,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
        LengthLimitingTextInputFormatter(12),
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(
        hintText: 'auth.login.identifierHint'.tr(),
      ).copyWith(counterText: ''),
      validator: _validateLoginIdentifier,
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

class _LoginIdentifier {
  final String? cardNumber;
  final String? phoneNumber;

  const _LoginIdentifier({this.cardNumber, this.phoneNumber});
}

_LoginIdentifier _parseLoginIdentifier(String raw) {
  final identifier = raw.trim();
  if (_isEgyptianMobile(identifier)) {
    return _LoginIdentifier(phoneNumber: identifier);
  }
  return _LoginIdentifier(cardNumber: identifier);
}

bool _isEgyptianMobile(String value) {
  final cleanPhoneNumber = value.startsWith('0') ? value.substring(1) : value;
  return RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanPhoneNumber);
}

bool _isPotentialCardNumber(String value) {
  return RegExp(r'^[A-Za-z0-9][A-Za-z0-9\-]{3,11}$').hasMatch(value);
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
            'auth.login.or'.tr(),
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
          'auth.login.activateCard'.tr(),
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
          'auth.login.continueAsGuest'.tr(),
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
