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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
                      title: 'auth.forgot.title'.tr(),
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
                            'auth.forgot.subtitle'.tr(),
                            style: TextStyle(
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
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            validator: _validatePhone,
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
