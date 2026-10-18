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

import '../core/theming/app_text_styles.dart';

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

    // An 11-digit value starting with '01' (or 10 digits starting with '1')
    // is clearly a phone-number attempt. If it failed the strict prefix
    // check above (valid prefixes are 010/011/012/015), surface a
    // phone-format error instead of treating it as a card number — e.g.
    // '01912345678' must not fall through to card-number handling.
    if (_looksLikePhoneAttempt(identifier)) {
      return 'auth.login.phoneNumberInvalid'.tr();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Blue Header ──────────────────────────────────────
                    AuthHeader(title: 'auth.welcomeTitle'.tr()),

                    // ── Form Section ─────────────────────────────────────
                    AuthContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthSectionIntro(title: 'auth.login.title'.tr()),
                          SizedBox(height: 22.h),

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
                                  style: AppTextStyles.of(
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
                                style: AppTextStyles.of(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () => context.push('/medicard-register'),
                                child: Text(
                                  'auth.login.registerNow'.tr(),
                                  style: AppTextStyles.of(
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
                          AuthDivider(label: 'auth.login.or'.tr()),
                          SizedBox(height: 20.h),

                          // Activate Card Button
                          AuthSecondaryButton(
                            label: 'auth.login.activateCard'.tr(),
                            icon: Icons.credit_card_rounded,
                            onPressed: () =>
                                context.push('/medicard-activation'),
                          ),
                          SizedBox(height: 12.h),

                          // Continue as Guest Button
                          AuthSecondaryButton(
                            label: 'auth.login.continueAsGuest'.tr(),
                            icon: Icons.person_outline_rounded,
                            tonal: true,
                            onPressed: () => context.go('/guest-home'),
                          ),
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
      keyboardType: TextInputType.number,
      maxLength: 12,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      style: AppTextStyles.of(fontSize: 15.sp, color: Colors.black),
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
      style: AppTextStyles.of(fontSize: 15.sp, color: Colors.black),
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

bool _looksLikePhoneAttempt(String value) {
  // 11 digits with a leading zero (01xxxxxxxxx) or 10 digits without it
  // (1xxxxxxxxx) — the shapes of an Egyptian mobile attempt.
  if (RegExp(r'^01[0-9]{9}$').hasMatch(value)) return true;
  if (RegExp(r'^1[0-9]{9}$').hasMatch(value)) return true;
  return false;
}

bool _isPotentialCardNumber(String value) {
  return RegExp(r'^[0-9]{4,12}$').hasMatch(value);
}
