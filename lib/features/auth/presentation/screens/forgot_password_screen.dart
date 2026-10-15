import 'package:easy_localization/easy_localization.dart';
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _phoneTouched = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(() {
      if (!_phoneFocus.hasFocus && !_phoneTouched) {
        setState(() => _phoneTouched = true);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _onSendOtpPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final phoneNumber = LanguageHelper.convertArabicToEnglishNumerals(
      _phoneController.text.trim(),
    );
    context.read<ForgotPasswordCubit>().sendOtp(phoneNumber);
  }

  bool _isAccountExistsInfoMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('account exists')) return true;
    if (lower.contains('if the account')) return true;
    if (message.contains('الحساب موجود')) return true;
    if (message.contains('في حالة وجود الحساب')) return true;
    if (message.contains('إذا كان الحساب موجود')) return true;
    return false;
  }

  String? _validatePhone(String? value) {
    final phone = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );
    if (phone.isEmpty) return 'auth.forgot.phone_required'.tr();
    if (!RegExp(r'^01[0-9]{9}$').hasMatch(phone)) {
      return 'auth.forgot.phone_invalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        state.whenOrNull(
          otpSent: (phoneNumber, otp) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.push('/forgot-password/verify', extra: {
                'phoneNumber': phoneNumber,
                'otp': otp,
              });
            });
          },
          failed: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              // Enumeration-protection: backend confirms "If the account
              // exists, an OTP will be sent" without revealing whether the
              // number is registered. Show it as info and continue to the
              // OTP screen instead of staying put.
              if (_isAccountExistsInfoMessage(error)) {
                showInfoToast(error);
                final phoneNumber =
                    LanguageHelper.convertArabicToEnglishNumerals(
                      _phoneController.text.trim(),
                    );
                context.push('/forgot-password/verify', extra: {
                  'phoneNumber': phoneNumber,
                  'otp': '',
                });
                return;
              }
              showErrorToast(error);
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
                      title: 'auth.forgot.title'.tr(),
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
                            'auth.forgot.subtitle'.tr(),
                            style: AppTextStyles.of(
                              fontSize: 15.sp,
                              color: kAuthGreyText,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          AuthFieldLabel('auth.forgot.phone_label'.tr()),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            validator: _validatePhone,
                            autovalidateMode: _phoneTouched
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: authInputDecoration(
                              hintText: 'auth.forgot.phone_hint'.tr(),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AuthPrimaryButton(
                            label: 'auth.forgot.send_otp'.tr(),
                            isLoading: isLoading,
                            onPressed: () => _onSendOtpPressed(context),
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
