import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/theming/app_toast.dart';
import '../core/utils/language_helper.dart';
import '../core/widgets/auth_shared_widgets.dart';
import '../data/auth_response_model.dart';
import 'logic/register_cubit.dart';
import 'logic/register_state.dart';
import 'widgets/register/register_account_section.dart';
import 'widgets/register/register_identity_section.dart';
import 'widgets/register/register_name_row.dart';

import '../core/theming/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _passwordMinLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _nationalIdFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportNumberController = TextEditingController();

  final Set<String> _touchedFields = {};
  final Map<String, FocusNode> _focusNodes = {};

  String _birthDate = '2000-01-01';
  bool _isMale = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);

    for (final name in [
      'firstName',
      'lastName',
      'phoneNumber',
      'password',
      'confirmPassword',
      'nationalId',
      'passportNumber',
    ]) {
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          setState(() => _touchedFields.add(name));
        }
      });
      _focusNodes[name] = node;
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _confirmPasswordFieldKey.currentState?.validate();
    }
    setState(() {});
  }

  String? _validatePassword(String? value) {
    final password = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );

    if (password.isEmpty) {
      return 'auth.register.passwordRequired'.tr();
    }
    if (!_isPasswordValid(password)) {
      return 'auth.register.passwordPolicyInvalid'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );
    final password = LanguageHelper.convertArabicToEnglishNumerals(
      _passwordController.text.trim(),
    );

    if (confirmPassword.isEmpty) {
      return 'auth.register.confirmPasswordRequired'.tr();
    }
    if (confirmPassword != password) {
      return 'auth.register.passwordsNotMatch'.tr();
    }
    return null;
  }

  bool _hasUsableAuthSession(AuthResponseModel response) {
    final data = response.data;
    final token = data?.token;
    final refreshToken = data?.refreshToken;

    if (token == null || token.isEmpty) return false;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    return true;
  }

  bool _isPasswordValid(String password) {
    return _hasMinimumLength(password) &&
        _hasLetter(password) &&
        _hasNumber(password) &&
        _hasSpecialCharacter(password);
  }

  bool _hasMinimumLength(String password) =>
      password.length >= _passwordMinLength;

  bool _hasLetter(String password) => RegExp(r'[A-Za-z]').hasMatch(password);

  bool _hasNumber(String password) => RegExp(r'[0-9]').hasMatch(password);

  bool _hasSpecialCharacter(String password) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]').hasMatch(password);

  String? _validateName(String? value, {required String requiredKey}) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return requiredKey.tr();
    if (name.length < 2) return 'edit_profile.invalid_name'.tr();
    final validNamePattern = RegExp(r"^[\p{L}][\p{L} .'\-]*$", unicode: true);
    if (!validNamePattern.hasMatch(name)) {
      return 'edit_profile.invalid_name'.tr();
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneNumber = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );

    if (phoneNumber.isEmpty) {
      return 'auth.register.phoneNumberRequired'.tr();
    }

    final cleanPhoneNumber = phoneNumber.startsWith('0')
        ? phoneNumber.substring(1)
        : phoneNumber;

    if (!RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanPhoneNumber)) {
      return 'auth.register.phoneNumberInvalid'.tr();
    }

    return null;
  }

  String? _validateNationalId(String? value) {
    final nationalId = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );
    final passportNumber = LanguageHelper.convertArabicToEnglishNumerals(
      _passportNumberController.text.trim(),
    );

    if (nationalId.isEmpty) {
      return passportNumber.isEmpty
          ? 'auth.register.nationalIdOrPassportRequired'.tr()
          : null;
    }

    if (!RegExp(r'^[23][0-9]{13}$').hasMatch(nationalId)) {
      return 'auth.register.nationalIdInvalid'.tr();
    }

    return null;
  }

  String? _validatePassportNumber(String? value) {
    final passportNumber = LanguageHelper.convertArabicToEnglishNumerals(
      value?.trim() ?? '',
    );

    if (passportNumber.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[A-Za-z0-9]{6,20}$').hasMatch(passportNumber)) {
      return 'auth.register.passportNumberInvalid'.tr();
    }

    return null;
  }

  void _clearInputFocus() {
    FocusManager.instance.primaryFocus?.unfocus(
      disposition: UnfocusDisposition.scope,
    );
  }

  Future<void> _selectBirthDate() async {
    _clearInputFocus();

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
    _clearInputFocus();
  }

  void _onRegisterPressed(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final nationalId = _nationalIdController.text.trim();
      final passportNumber = _passportNumberController.text.trim();

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
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              showSuccessToast('auth.register.registrationSuccess'.tr());
              if (_hasUsableAuthSession(response)) {
                context.go('/medicard-home');
              } else {
                context.go('/medicard-login');
              }
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
        final bottomSafePadding = MediaQuery.viewPaddingOf(context).bottom;

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
                    AuthHeader(
                      showBackButton: true,
                      onBack: () => context.go('/medicard-login'),
                      title: 'auth.welcomeTitle'.tr(),
                    ),

                    // ── Form Section ────────────────────────────────────
                    AuthContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthSectionIntro(
                            title: 'auth.register.title'.tr(),
                            subtitle: 'auth.register.subtitle'.tr(),
                          ),
                          SizedBox(height: 22.h),

                          RegisterNameRow(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            firstNameFocusNode: _focusNodes['firstName'],
                            firstNameAutovalidate:
                                _touchedFields.contains('firstName')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            lastNameFocusNode: _focusNodes['lastName'],
                            lastNameAutovalidate:
                                _touchedFields.contains('lastName')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            firstNameValidator: (v) => _validateName(
                              v,
                              requiredKey: 'auth.register.firstNameRequired',
                            ),
                            lastNameValidator: (v) => _validateName(
                              v,
                              requiredKey: 'auth.register.lastNameRequired',
                            ),
                          ),
                          SizedBox(height: 16.h),
                          RegisterAccountSection(
                            phoneNumberController: _phoneNumberController,
                            phoneNumberFocusNode: _focusNodes['phoneNumber'],
                            phoneNumberAutovalidate:
                                _touchedFields.contains('phoneNumber')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            phoneNumberValidator: _validatePhoneNumber,
                            isMale: _isMale,
                            onMaleTap: () {
                              _clearInputFocus();
                              setState(() => _isMale = true);
                            },
                            onFemaleTap: () {
                              _clearInputFocus();
                              setState(() => _isMale = false);
                            },
                            birthDate: _birthDate,
                            onSelectBirthDate: _selectBirthDate,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onPasswordToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            passwordFocusNode: _focusNodes['password'],
                            passwordAutovalidate:
                                _touchedFields.contains('password')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            passwordValidator: _validatePassword,
                            passwordMinLength: _passwordMinLength,
                            confirmPasswordFieldKey: _confirmPasswordFieldKey,
                            confirmPasswordController:
                                _confirmPasswordController,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            onConfirmPasswordToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            confirmPasswordFocusNode:
                                _focusNodes['confirmPassword'],
                            confirmPasswordAutovalidate:
                                _touchedFields.contains('confirmPassword')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            confirmPasswordValidator: _validateConfirmPassword,
                          ),
                          SizedBox(height: 16.h),
                          RegisterIdentitySection(
                            nationalIdFieldKey: _nationalIdFieldKey,
                            nationalIdController: _nationalIdController,
                            nationalIdFocusNode: _focusNodes['nationalId'],
                            nationalIdAutovalidate:
                                _touchedFields.contains('nationalId')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            nationalIdValidator: _validateNationalId,
                            passportNumberController: _passportNumberController,
                            passportNumberFocusNode:
                                _focusNodes['passportNumber'],
                            passportNumberAutovalidate:
                                _touchedFields.contains('passportNumber')
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            passportNumberValidator: _validatePassportNumber,
                            onPassportChanged: (_) =>
                                _nationalIdFieldKey.currentState?.validate(),
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
                                style: AppTextStyles.of(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/medicard-login'),
                                child: Text(
                                  'auth.register.loginNow'.tr(),
                                  style: AppTextStyles.of(
                                    fontSize: 13.sp,
                                    color: kAuthBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: bottomSafePadding + 32.h),
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
