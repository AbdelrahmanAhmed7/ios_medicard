import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/language_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../utils/otp_attempt_guard.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _resendCooldownSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();
  final _attemptGuard = OtpAttemptGuard();
  bool _otpTouched = false;
  Timer? _timer;
  int _resendSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _otpFocus.addListener(() {
      if (!_otpFocus.hasFocus && !_otpTouched) {
        setState(() => _otpTouched = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _timer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft--);
      }
    });
  }

  void _restartCountdown([String? otp]) {
    _attemptGuard.reset();
    _startResendCooldown();
  }

  void _onVerifyPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      dismissActiveToast();
      return;
    }
    final otp = LanguageHelper.convertArabicToEnglishNumerals(
      _otpController.text.trim(),
    );
    if (!_attemptGuard.tryRegister(otp)) {
      showWarningToast('auth.forgot.otp_repeated_too_many_times'.tr());
      _otpController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _otpController.text.length,
      );
      _otpFocus.requestFocus();
      return;
    }
    context.read<ForgotPasswordCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      otp: otp,
    );
  }

  String? _validateOtp(String? value) {
    final otp = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );
    if (otp.isEmpty) return 'auth.forgot.otp_required'.tr();
    if (otp.length < 4) return 'auth.forgot.otp_invalid'.tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        state.whenOrNull(
          otpSent: (phoneNumber, otp) {
            _restartCountdown(otp);
          },
          otpVerified: (phoneNumber, token) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.pushReplacement(
                '/forgot-password/reset',
                extra: {'phoneNumber': phoneNumber, 'token': token},
              );
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
                    AuthHeader(
                      title: 'auth.welcomeTitle'.tr(),
                      showBackButton: true,
                      onBack: () => context.pop(),
                    ),
                    AuthContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthSectionIntro(
                            title: 'auth.forgot.otp_title'.tr(),
                            subtitle: 'auth.forgot.otp_subtitle'.tr(
                              args: [widget.phoneNumber],
                            ),
                          ),
                          SizedBox(height: 22.h),

                          AuthFieldLabel('auth.forgot.otp_label'.tr()),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _otpController,
                            focusNode: _otpFocus,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: _validateOtp,
                            autovalidateMode: _otpTouched
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: authInputDecoration(
                              hintText: 'auth.forgot.otp_hint'.tr(),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AuthPrimaryButton(
                            label: 'auth.forgot.verify'.tr(),
                            isLoading: isLoading,
                            onPressed: () => _onVerifyPressed(context),
                          ),
                          SizedBox(height: 12.h),
                          Center(
                            child: TextButton(
                              onPressed: isLoading || _resendSecondsLeft > 0
                                  ? null
                                  : () {
                                      context
                                          .read<ForgotPasswordCubit>()
                                          .sendOtp(widget.phoneNumber);
                                    },
                              child: Text(
                                _resendSecondsLeft > 0
                                    ? 'auth.forgot.resend_in'.tr(
                                        args: ['$_resendSecondsLeft'],
                                      )
                                    : 'auth.forgot.resend'.tr(),
                                style: AppTextStyles.of(
                                  fontSize: 14.sp,
                                  color: kAuthBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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
}
