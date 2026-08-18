import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/utils/language_helper.dart';
import '../../../../../core/auth/auth_session_storage.dart';
import '../../../../../core/network/dio_factory.dart';
import '../../data/models/activate_card_request_model.dart';
import '../../data/repository/activate_card_repository_impl.dart';
import '../../domain/usecases/activate_card_usecase.dart';
import '../cubit/activate_card_cubit.dart';
import '../cubit/activate_card_state.dart';
import '../../../../../core/theming/app_toast.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';

class ActivateCardScreen extends StatefulWidget {
  const ActivateCardScreen({super.key});

  @override
  State<ActivateCardScreen> createState() => _ActivateCardScreenState();
}

class _ActivateCardScreenState extends State<ActivateCardScreen> {
  static const int _passwordMinLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _nationalIdFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isMale = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const _fieldNames = [
    'firstName',
    'lastName',
    'cardNumber',
    'phoneNumber',
    'nationalId',
    'passportNumber',
    'birthDate',
    'password',
    'confirmPassword',
  ];

  late final Map<String, FocusNode> _focusNodes;
  final Set<String> _touchedFields = {};

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _focusNodes = {
      for (final name in _fieldNames) name: FocusNode(),
    };
    for (final name in _fieldNames) {
      _focusNodes[name]!.addListener(() {
        if (!_focusNodes[name]!.hasFocus && _touchedFields.add(name)) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cardNumberController.dispose();
    _phoneNumberController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (_confirmPasswordController.text.isNotEmpty) {
      _confirmPasswordFieldKey.currentState?.validate();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ActivateCardCubit(ActivateCardUseCase(ActivateCardRepositoryImpl())),
      child: BlocListener<ActivateCardCubit, ActivateCardState>(
        listener: (context, state) {
          if (state is ActivateCardSuccess) {
            showSuccessToast(
              state.response.message.isNotEmpty
                  ? state.response.message
                  : 'activate_card.success'.tr(),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await const AuthSessionStorage().clearSession();
              DioFactory.clearTokenFromHeader();
              if (!mounted) return;
              this.context.go('/medicard-login');
            });
          } else if (state is ActivateCardError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) showErrorToast(state.message);
            });
          }
        },
        child: Scaffold(
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
                      onBack: () => context.pop(),
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
                            'activate_card.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'activate_card.subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: kAuthGreyText,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // First Name
                          AuthFieldLabel('auth.register.firstName'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _firstNameController,
                            hintText: 'auth.register.firstNameHint'.tr(),
                            fieldName: 'firstName',
                            keyboardType: TextInputType.name,
                            maxLength: 30,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[A-Za-z\u0600-\u06FF\s'-]"),
                              ),
                              LengthLimitingTextInputFormatter(30),
                            ],
                            validator: _validateFirstName,
                          ),
                          SizedBox(height: 16.h),

                          // Last Name
                          AuthFieldLabel('auth.register.lastName'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _lastNameController,
                            hintText: 'auth.register.lastNameHint'.tr(),
                            fieldName: 'lastName',
                            keyboardType: TextInputType.name,
                            maxLength: 30,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[A-Za-z\u0600-\u06FF\s'-]"),
                              ),
                              LengthLimitingTextInputFormatter(30),
                            ],
                            validator: _validateLastName,
                          ),
                          SizedBox(height: 16.h),

                          // Card Number
                          AuthFieldLabel('auth.login.cardNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _cardNumberController,
                            hintText: 'auth.login.cardNumberHint'.tr(),
                            fieldName: 'cardNumber',
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            validator: _validateCardNumber,
                          ),
                          SizedBox(height: 16.h),

                          // Gender
                          AuthFieldLabel('auth.register.gender'.tr()),
                          SizedBox(height: 6.h),
                          _buildGenderSelector(),
                          SizedBox(height: 16.h),

                          // Phone Number
                          AuthFieldLabel('auth.register.phoneNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _phoneNumberController,
                            hintText: 'auth.register.phoneNumberHint'.tr(),
                            fieldName: 'phoneNumber',
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: _validatePhoneNumber,
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
                            controller: _nationalIdController,
                            hintText: 'activate_card.national_id_optional_hint'
                                .tr(),
                            fieldName: 'nationalId',
                            keyboardType: TextInputType.number,
                            required: false,
                            maxLength: 14,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(14),
                            ],
                            validator: _validateNationalId,
                          ),
                          SizedBox(height: 16.h),

                          // Passport Number
                          AuthFieldLabel('auth.register.passportNumber'.tr()),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _passportNumberController,
                            hintText:
                                'activate_card.passport_number_optional_hint'
                                    .tr(),
                            fieldName: 'passportNumber',
                            required: false,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 20,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9]'),
                              ),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            validator: _validatePassportNumber,
                            onChanged: (_) =>
                                _nationalIdFieldKey.currentState?.validate(),
                          ),
                          SizedBox(height: 16.h),

                          // Birth Date
                          AuthFieldLabel('auth.register.birthDate'.tr()),
                          SizedBox(height: 6.h),
                          _buildBirthDatePicker(context),
                          SizedBox(height: 16.h),

                          // Password
                          AuthFieldLabel('auth.register.password'.tr()),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            fieldName: 'password',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildPasswordRequirements(),
                          SizedBox(height: 16.h),

                          // Confirm Password
                          AuthFieldLabel('auth.register.confirmPassword'.tr()),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            fieldKey: _confirmPasswordFieldKey,
                            controller: _confirmPasswordController,
                            hintText: '••••••••',
                            fieldName: 'confirmPassword',
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            validator: (value) {
                              final confirmPassword = _normalize(value ?? '');
                              if (confirmPassword.isEmpty) {
                                return 'auth.register.confirmPasswordRequired'
                                    .tr();
                              }
                              if (confirmPassword !=
                                  _normalize(_passwordController.text)) {
                                return 'auth.register.passwordsNotMatch'.tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 28.h),

                          // Activate Button
                          BlocBuilder<ActivateCardCubit, ActivateCardState>(
                            builder: (context, state) {
                              final isLoading = state is ActivateCardLoading;
                              return AuthPrimaryButton(
                                label: 'activate_card.activate'.tr(),
                                isLoading: isLoading,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    showErrorToast(
                                      'errors.validation_failed'.tr(),
                                    );
                                    return;
                                  }
                                  context
                                      .read<ActivateCardCubit>()
                                      .activateCard(
                                        ActivateCardRequestModel(
                                          firstName: _normalize(
                                            _firstNameController.text,
                                          ),
                                          lastName: _normalize(
                                            _lastNameController.text,
                                          ),
                                          cardNumber: _normalize(
                                            _cardNumberController.text,
                                          ),
                                          isMale: _isMale,
                                          phoneNumber: _normalize(
                                            _phoneNumberController.text,
                                          ),
                                          birthDate: _birthDateController.text,
                                          password: _normalize(
                                            _passwordController.text,
                                          ),
                                          confirmPassword: _normalize(
                                            _confirmPasswordController.text,
                                          ),
                                          nationalId:
                                              _nationalIdController.text.isEmpty
                                              ? null
                                              : _normalize(
                                                  _nationalIdController.text,
                                                ),
                                          passportNumber:
                                              _passportNumberController
                                                  .text
                                                  .isEmpty
                                              ? null
                                              : _normalize(
                                                  _passportNumberController
                                                      .text,
                                                ),
                                        ),
                                      );
                                },
                              );
                            },
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
                                  'auth.login.loginButton'.tr(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: kAuthBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                MediaQuery.viewPaddingOf(context).bottom + 32.h,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Text Field ──────────────────────────────────────────────────────────────

  Widget _buildTextField({
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    String? fieldName,
    TextInputType? keyboardType,
    bool required = true,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final isTouched = fieldName != null && _touchedFields.contains(fieldName);
    final focusNode = fieldName != null ? _focusNodes[fieldName] : null;
    return TextFormField(
      key:
          fieldKey ??
          (controller == _nationalIdController ? _nationalIdFieldKey : null),
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autovalidateMode: isTouched
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(
        hintText: hintText,
      ).copyWith(counterText: ''),
      onChanged: onChanged,
      validator:
          validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'common.this_field_required'.tr();
                  }
                  return null;
                }
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
    String? fieldName,
    String? Function(String?)? validator,
  }) {
    final isTouched = fieldName != null && _touchedFields.contains(fieldName);
    final focusNode = fieldName != null ? _focusNodes[fieldName] : null;
    return TextFormField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      autovalidateMode: isTouched
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
      validator:
          validator ??
          (value) {
            final password = _normalize(value ?? '');
            if (password.isEmpty) {
              return 'auth.register.passwordRequired'.tr();
            }
            if (!_isPasswordValid(password)) {
              return 'auth.register.passwordPolicyInvalid'.tr();
            }
            return null;
          },
    );
  }

  // ── Birth Date Picker ───────────────────────────────────────────────────────

  Widget _buildPasswordRequirements() {
    final password = _normalize(_passwordController.text);
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

  Widget _buildBirthDatePicker(BuildContext context) {
    final isTouched = _touchedFields.contains('birthDate');
    final focusNode = _focusNodes['birthDate']!;
    return TextFormField(
      controller: _birthDateController,
      focusNode: focusNode,
      readOnly: true,
      autovalidateMode: isTouched
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      onTap: () async {
        FocusScope.of(context).unfocus();
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: kAuthBlue),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _birthDateController.text =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          });
        }
      },
      decoration: authInputDecoration(
        hintText: 'YYYY-MM-DD',
        suffixIcon: Icon(
          Icons.calendar_today_outlined,
          color: kAuthGreyText,
          size: 18.sp,
        ),
      ),
      validator: (value) {
        final birthDate = _parseBirthDate(value);
        if (birthDate == null) {
          return 'common.this_field_required'.tr();
        }
        if (birthDate.isAfter(DateTime.now())) {
          return 'auth.register.birthDateInvalid'.tr();
        }
        return null;
      },
    );
  }

  DateTime get _selectedBirthDate {
    final selected = _parseBirthDate(_birthDateController.text);
    return selected ?? DateTime(2000);
  }

  DateTime? _parseBirthDate(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  String? _validateFirstName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'auth.register.firstNameRequired'.tr();
    if (name.length < 2) return 'common.this_field_required'.tr();
    return null;
  }

  String? _validateLastName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'auth.register.lastNameRequired'.tr();
    if (name.length < 2) return 'common.this_field_required'.tr();
    return null;
  }

  String? _validateCardNumber(String? value) {
    final cardNumber = _normalize(value ?? '');
    if (cardNumber.isEmpty) return 'auth.login.cardNumberRequired'.tr();
    if (!RegExp(r'^[0-9]{12}$').hasMatch(cardNumber)) {
      return 'auth.login.cardNumberInvalid'.tr();
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneNumber = _normalize(value ?? '');
    if (phoneNumber.isEmpty) return 'auth.register.phoneNumberRequired'.tr();

    final cleanPhoneNumber = phoneNumber.startsWith('0')
        ? phoneNumber.substring(1)
        : phoneNumber;
    if (!RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanPhoneNumber)) {
      return 'auth.register.phoneNumberInvalid'.tr();
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    final nationalId = _normalize(value ?? '');
    final passportNumber = _normalize(_passportNumberController.text);
    if (nationalId.isEmpty) {
      return passportNumber.isEmpty
          ? 'auth.register.nationalIdOrPassportRequired'.tr()
          : null;
    }
    if (!RegExp(r'^[0-9]{14}$').hasMatch(nationalId)) {
      return 'auth.register.nationalIdInvalid'.tr();
    }
    return null;
  }

  String? _validatePassportNumber(String? value) {
    final passportNumber = _normalize(value ?? '');
    if (passportNumber.isEmpty) return null;
    if (!RegExp(r'^[A-Za-z0-9]{6,20}$').hasMatch(passportNumber)) {
      return 'auth.register.passportNumberInvalid'.tr();
    }
    return null;
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

  String _normalize(String value) {
    return LanguageHelper.convertArabicToEnglishNumerals(value.trim());
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
