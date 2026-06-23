import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/theming/app_toast.dart';
import '../core/utils/language_helper.dart';
import '../core/widgets/auth_shared_widgets.dart';
import 'logic/register_cubit.dart';
import 'logic/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportNumberController = TextEditingController();

  String _birthDate = '2000-01-01';
  bool _isMale = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_birthDate),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: kAuthBlue)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onRegisterPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    
    // Validate that at least one of nationalId or passportNumber is provided
    final nationalId = _nationalIdController.text.trim();
    final passportNumber = _passportNumberController.text.trim();
    
    if (nationalId.isEmpty && passportNumber.isEmpty) {
      showErrorToast('Please provide either National ID or Passport Number');
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      context.read<RegisterCubit>().register(
        firstName: LanguageHelper.convertArabicToEnglishNumerals(
          _firstNameController.text.trim(),
        ),
        lastName: LanguageHelper.convertArabicToEnglishNumerals(
          _lastNameController.text.trim(),
        ),
        phoneNumber: LanguageHelper.convertArabicToEnglishNumerals(
          _phoneNumberController.text.trim(),
        ),
        isMale: _isMale,
        birthDate: _birthDate,
        password: LanguageHelper.convertArabicToEnglishNumerals(
          _passwordController.text.trim(),
        ),
        confirmPassword: LanguageHelper.convertArabicToEnglishNumerals(
          _confirmPasswordController.text.trim(),
        ),
        nationalId: nationalId.isEmpty
            ? null
            : LanguageHelper.convertArabicToEnglishNumerals(nationalId),
        passportNumber: passportNumber.isEmpty
            ? null
            : LanguageHelper.convertArabicToEnglishNumerals(passportNumber),
      );
    } else {
      showErrorToast('auth.register.fillAllFields'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Blue Header ─────────────────────────────────────
                    AuthBlueHeader(
                      showBackButton: true,
                      onBack: () => context.go('/medicard-login'),
                      title: 'Welcome to Medicard',
                    ),

                    // ── Form Section ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 28.h),

                          Text(
                            'auth.register.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'auth.register.subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: kAuthGreyText,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // First & Last Name row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AuthFieldLabel(
                                      'auth.register.firstName'.tr(),
                                    ),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _firstNameController,
                                      hintText: 'auth.register.firstNameHint'
                                          .tr(),
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'auth.register.firstNameRequired'
                                                .tr()
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AuthFieldLabel(
                                      'auth.register.lastName'.tr(),
                                    ),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _lastNameController,
                                      hintText: 'auth.register.lastNameHint'
                                          .tr(),
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'auth.register.lastNameRequired'
                                                .tr()
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Phone Number
                          AuthFieldLabel('auth.register.phoneNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _phoneNumberController,
                            hintText: 'auth.register.phoneNumberHint'.tr(),
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'auth.register.phoneNumberRequired'.tr()
                                : null,
                          ),
                          SizedBox(height: 16.h),

                          // Gender
                          AuthFieldLabel('auth.register.gender'.tr()),
                          SizedBox(height: 6.h),
                          _buildGenderSelector(),
                          SizedBox(height: 16.h),

                          // Birth Date
                          AuthFieldLabel('auth.register.birthDate'.tr()),
                          SizedBox(height: 6.h),
                          _buildBirthDateField(),
                          SizedBox(height: 16.h),

                          // Password
                          AuthFieldLabel('auth.register.password'.tr()),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: 'auth.register.passwordHint'.tr(),
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'auth.register.passwordRequired'.tr()
                                : null,
                          ),
                          SizedBox(height: 16.h),

                          // Confirm Password
                          AuthFieldLabel('auth.register.confirmPassword'.tr()),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: 'auth.register.confirmPasswordHint'.tr(),
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'auth.register.confirmPasswordRequired'
                                    .tr();
                              }
                              if (v != _passwordController.text) {
                                return 'auth.register.passwordsNotMatch'.tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),

                          // National ID
                          AuthFieldLabel('auth.register.nationalId'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _nationalIdController,
                            hintText: 'auth.register.nationalIdHint'.tr(),
                            keyboardType: TextInputType.number,
                            required: false,
                          ),
                          SizedBox(height: 16.h),

                          // Passport Number (optional)
                          AuthFieldLabel('auth.register.passportNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _passportNumberController,
                            hintText: 'auth.register.passportNumberHint'.tr(),
                            required: false,
                          ),
                          SizedBox(height: 28.h),

                          // Register Button
                          AuthPrimaryButton(
                            label: 'auth.register.registerButton'.tr(),
                            isLoading: isLoading,
                            onPressed: () => _onRegisterPressed(context),
                          ),
                          SizedBox(height: 20.h),

                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'auth.register.alreadyHaveAccount'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/medicard-login'),
                                child: Text(
                                  'auth.register.loginNow'.tr(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: kAuthBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

  // ── Text Field ──────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(hintText: hintText),
      validator:
          validator ??
          (required
              ? (v) =>
                    (v == null || v.isEmpty) ? 'This field is required' : null
              : null),
    );
  }

  // ── Password Field ──────────────────────────────────────────────────────────

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(
        hintText: hintText,
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: kAuthGreyText,
            size: 20.sp,
          ),
        ),
      ),
      validator: validator,
    );
  }

  // ── Birth Date Field ────────────────────────────────────────────────────────

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: kAuthBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _birthDate,
              style: TextStyle(fontSize: 15.sp, color: Colors.black),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: kAuthGreyText,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ── Gender Selector ─────────────────────────────────────────────────────────

  Widget _buildGenderSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kAuthBorderColor),
      ),
      child: Row(
        children: [
          AuthGenderOption(
            label: 'auth.register.male'.tr(),
            selected: _isMale,
            onTap: () => setState(() => _isMale = true),
          ),
          SizedBox(width: 32.w),
          AuthGenderOption(
            label: 'auth.register.female'.tr(),
            selected: !_isMale,
            onTap: () => setState(() => _isMale = false),
          ),
        ],
      ),
    );
  }
}
