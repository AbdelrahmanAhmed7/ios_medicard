import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../core/theming/app_toast.dart';
import '../core/utils/language_helper.dart';
import '../core/widgets/auth_shared_widgets.dart';
import '../data/auth_response_model.dart';
import 'logic/register_cubit.dart';
import 'logic/register_state.dart';

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
                    AuthBlueHeader(
                      showBackButton: true,
                      onBack: () => context.go('/medicard-login'),
                      title: 'auth.welcomeTitle'.tr(),
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
                                      isRequired: true,
                                    ),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _firstNameController,
                                      hintText: 'auth.register.firstNameHint'
                                          .tr(),
                                      focusKey: 'firstName',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(
                                            r"[\p{L} .'\-]",
                                            unicode: true,
                                          ),
                                        ),
                                      ],
                                      validator: (v) => _validateName(
                                        v,
                                        requiredKey:
                                            'auth.register.firstNameRequired',
                                      ),
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
                                      isRequired: true,
                                    ),
                                    SizedBox(height: 6.h),
                                    _buildTextField(
                                      controller: _lastNameController,
                                      hintText: 'auth.register.lastNameHint'
                                          .tr(),
                                      focusKey: 'lastName',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(
                                            r"[\p{L} .'\-]",
                                            unicode: true,
                                          ),
                                        ),
                                      ],
                                      validator: (v) => _validateName(
                                        v,
                                        requiredKey:
                                            'auth.register.lastNameRequired',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Phone Number
                          AuthFieldLabel(
                            'auth.register.phoneNumber'.tr(),
                            isRequired: true,
                          ),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _phoneNumberController,
                            hintText: 'auth.register.phoneNumberHint'.tr(),
                            keyboardType: TextInputType.phone,
                            focusKey: 'phoneNumber',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: _validatePhoneNumber,
                          ),
                          SizedBox(height: 16.h),

                          // Gender
                          AuthFieldLabel(
                            'auth.register.gender'.tr(),
                            isRequired: true,
                          ),
                          SizedBox(height: 6.h),
                          _buildGenderSelector(),
                          SizedBox(height: 16.h),

                          // Birth Date
                          AuthFieldLabel(
                            'auth.register.birthDate'.tr(),
                            isRequired: true,
                          ),
                          SizedBox(height: 6.h),
                          _buildBirthDateField(),
                          SizedBox(height: 16.h),

                          // Password
                          AuthFieldLabel(
                            'auth.register.password'.tr(),
                            isRequired: true,
                          ),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: 'auth.register.passwordHint'.tr(),
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            focusKey: 'password',
                            validator: _validatePassword,
                          ),
                          SizedBox(height: 10.h),
                          _buildPasswordRequirements(),
                          SizedBox(height: 16.h),

                          // Confirm Password
                          AuthFieldLabel(
                            'auth.register.confirmPassword'.tr(),
                            isRequired: true,
                          ),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            fieldKey: _confirmPasswordFieldKey,
                            controller: _confirmPasswordController,
                            hintText: 'auth.register.confirmPasswordHint'.tr(),
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            focusKey: 'confirmPassword',
                            validator: _validateConfirmPassword,
                          ),
                          SizedBox(height: 16.h),

                          // National ID
                          _buildRequiredHint(
                            'auth.register.nationalIdOrPassportRequired'.tr(),
                          ),
                          SizedBox(height: 10.h),
                          AuthFieldLabel('auth.register.nationalId'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            fieldKey: _nationalIdFieldKey,
                            controller: _nationalIdController,
                            hintText: 'auth.register.nationalIdHint'.tr(),
                            keyboardType: TextInputType.number,
                            focusKey: 'nationalId',
                            required: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(14),
                            ],
                            validator: _validateNationalId,
                          ),
                          SizedBox(height: 16.h),

                          // Passport Number (optional)
                          AuthFieldLabel('auth.register.passportNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _passportNumberController,
                            hintText: 'auth.register.passportNumberHint'.tr(),
                            required: false,
                            focusKey: 'passportNumber',
                            validator: _validatePassportNumber,
                            onChanged: (_) =>
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

  // ── Text Field ──────────────────────────────────────────────────────────────

  Widget _buildTextField({
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? focusKey,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      focusNode: focusKey != null ? _focusNodes[focusKey] : null,
      autovalidateMode: focusKey != null && _touchedFields.contains(focusKey)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
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
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    String? focusKey,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscure,
      focusNode: focusKey != null ? _focusNodes[focusKey] : null,
      autovalidateMode: focusKey != null && _touchedFields.contains(focusKey)
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
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

  Widget _buildPasswordRequirements() {
    final password = LanguageHelper.convertArabicToEnglishNumerals(
      _passwordController.text.trim(),
    );
    final showInvalidRequirements = password.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.register.passwordRequirementsTitle'.tr(),
          style: TextStyle(
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
              style: TextStyle(
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

  Widget _buildRequiredHint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '*',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: kAuthGreyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

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
            onTap: () {
              _clearInputFocus();
              setState(() => _isMale = true);
            },
          ),
          SizedBox(width: 32.w),
          AuthGenderOption(
            label: 'auth.register.female'.tr(),
            selected: !_isMale,
            onTap: () {
              _clearInputFocus();
              setState(() => _isMale = false);
            },
          ),
        ],
      ),
    );
  }
}
