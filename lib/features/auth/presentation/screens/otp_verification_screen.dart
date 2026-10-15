import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/language_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

import '../../../../core/theming/app_text_styles.dart';


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
  static const _displaySeconds = 5;
  static const _resendCooldownSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();
  bool _otpTouched = false;
  Timer? _timer;
  bool _showOtp = true;
  int _secondsLeft = _displaySeconds;
  int _resendSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[OTP] preview OTP: ${widget.otp}');
    _startCountdown();
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

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _showOtp = false;
        }
        if (_resendSecondsLeft > 0) {
          _resendSecondsLeft--;
          if (_resendSecondsLeft <= 0) timer.cancel();
        }
      });
    });
  }

  void _startResendCooldown() {
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
  }

  void _restartCountdown(String otp) {
    _timer?.cancel();
    setState(() {
      _showOtp = true;
      _secondsLeft = _displaySeconds;
      _resendSecondsLeft = _resendCooldownSeconds;
    });
    _startCountdown();
  }

  void _onVerifyPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final otp = LanguageHelper.convertArabicToEnglishNumerals(
      _otpController.text.trim(),
    );
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
                    AuthBlueHeader(
                      title: 'auth.forgot.otp_title'.tr(),
                      showBackButton: true,
                      onBack: () => context.pop(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28.h),
                          Text(
                            'auth.forgot.otp_subtitle'.tr(
                              args: [widget.phoneNumber],
                            ),
                            style: AppTextStyles.of(
                              fontSize: 15.sp,
                              color: kAuthGreyText,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          if (_showOtp && widget.otp.isNotEmpty) ...[
                            _OtpPreviewCard(
                              otp: widget.otp,
                              secondsLeft: _secondsLeft,
                            ),
                            SizedBox(height: 16.h),
                          ],

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
                              onPressed:
                                  isLoading || _resendSecondsLeft > 0
                                      ? null
                                      : () {
                                          context
                                              .read<ForgotPasswordCubit>()
                                              .sendOtp(widget.phoneNumber);
                                        },
                              child: Text(
                                _resendSecondsLeft > 0
                                    ? 'auth.forgot.resend_in'.tr(
                                        args: [
                                          '$_resendSecondsLeft',
                                        ],
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

class _OtpPreviewCard extends StatelessWidget {
  final String otp;
  final int secondsLeft;

  const _OtpPreviewCard({required this.otp, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1FB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kAuthBlue, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.sms_outlined, color: kAuthBlue, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'auth.forgot.otp_preview'.tr(args: [otp, '$secondsLeft']),
              style: AppTextStyles.of(
                fontSize: 13.5.sp,
                color: const Color(0xFF111827),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
