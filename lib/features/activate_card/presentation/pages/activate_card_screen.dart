import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
  final _formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
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
                  : 'Card activated successfully',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go('/medicard-login');
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
                            'Activate Your Card',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Fill in your details to activate your Medicard',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: kAuthGreyText,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // First Name
                          const AuthFieldLabel('First Name'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _firstNameController,
                            hintText: 'Enter your first name',
                          ),
                          SizedBox(height: 16.h),

                          // Last Name
                          const AuthFieldLabel('Last Name'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _lastNameController,
                            hintText: 'Enter your last name',
                          ),
                          SizedBox(height: 16.h),

                          // Card Number
                          const AuthFieldLabel('Card Number'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _cardNumberController,
                            hintText: 'Enter your card number',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16.h),

                          // Gender
                          const AuthFieldLabel('Gender'),
                          SizedBox(height: 6.h),
                          _buildGenderSelector(),
                          SizedBox(height: 16.h),

                          // Phone Number
                          const AuthFieldLabel('Phone Number'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _phoneNumberController,
                            hintText: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16.h),

                          // National ID
                          const AuthFieldLabel('National ID'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _nationalIdController,
                            hintText: 'Enter your national ID (optional)',
                            keyboardType: TextInputType.number,
                            required: false,
                          ),
                          SizedBox(height: 16.h),

                          // Passport Number
                          const AuthFieldLabel('Passport Number'),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _passportNumberController,
                            hintText: 'Enter your passport number (optional)',
                            required: false,
                          ),
                          SizedBox(height: 16.h),

                          // Birth Date
                          const AuthFieldLabel('Birth Date'),
                          SizedBox(height: 6.h),
                          _buildBirthDatePicker(context),
                          SizedBox(height: 16.h),

                          // Password
                          const AuthFieldLabel('Password'),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Confirm Password
                          const AuthFieldLabel('Confirm Password'),
                          SizedBox(height: 6.h),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: '••••••••',
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
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
                                label: 'Activate',
                                isLoading: isLoading,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context
                                        .read<ActivateCardCubit>()
                                        .activateCard(
                                          ActivateCardRequestModel(
                                            firstName:
                                                _firstNameController.text,
                                            lastName: _lastNameController.text,
                                            cardNumber:
                                                _cardNumberController.text,
                                            isMale: _isMale,
                                            phoneNumber:
                                                _phoneNumberController.text,
                                            birthDate:
                                                _birthDateController.text,
                                            password: _passwordController.text,
                                            confirmPassword:
                                                _confirmPasswordController.text,
                                            nationalId:
                                                _nationalIdController
                                                    .text
                                                    .isEmpty
                                                ? null
                                                : _nationalIdController.text,
                                            passportNumber:
                                                _passportNumberController
                                                    .text
                                                    .isEmpty
                                                ? null
                                                : _passportNumberController
                                                      .text,
                                          ),
                                        );
                                  }
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
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: kAuthGreyText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/medicard-login'),
                                child: Text(
                                  'Sign in',
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
        ),
      ),
    );
  }

  // ── Text Field ──────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      decoration: authInputDecoration(hintText: hintText),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
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
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
    );
  }

  // ── Birth Date Picker ───────────────────────────────────────────────────────

  Widget _buildBirthDatePicker(BuildContext context) {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      style: TextStyle(fontSize: 15.sp, color: Colors.black),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
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
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
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
            label: 'Male',
            selected: _isMale,
            onTap: () => setState(() => _isMale = true),
          ),
          SizedBox(width: 32.w),
          AuthGenderOption(
            label: 'Female',
            selected: !_isMale,
            onTap: () => setState(() => _isMale = false),
          ),
        ],
      ),
    );
  }
}
