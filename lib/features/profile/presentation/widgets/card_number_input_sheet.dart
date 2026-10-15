import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../data/models/profile_response_model.dart';
import '../cubit/profile_cubit.dart';

Future<void> showActivateCardDialog(
  BuildContext context,
  ProfileData data,
) async {
  final cardNumber = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const CardNumberInputSheet(),
  );

  if (cardNumber == null || !context.mounted) return;
  await context.read<ProfileCubit>().activateMemberCard(
    cardNumber: cardNumber,
    currentData: data,
  );
}

class CardNumberInputSheet extends StatefulWidget {
  const CardNumberInputSheet({super.key});

  @override
  State<CardNumberInputSheet> createState() => CardNumberInputSheetState();
}

class CardNumberInputSheetState extends State<CardNumberInputSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  String? _validateCardNumber(String? value) {
    final cardNumber = value?.trim() ?? '';
    if (cardNumber.isEmpty) return 'auth.login.cardNumberRequired'.tr();
    if (!RegExp(r'^[0-9]{12}$').hasMatch(cardNumber)) {
      return 'auth.login.cardNumberInvalid'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          18.h,
          20.w,
          20.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 18.h),
            Container(
              width: 54.r,
              height: 54.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEBF1FB),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.credit_card, color: kAuthBlue, size: 26.sp),
            ),
            SizedBox(height: 14.h),
            Text(
              'profile.activate_card'.tr(),
              style: AppTextStyles.of(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'profile.activate_card_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                height: 1.35,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 20.h),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                autovalidateMode: AutovalidateMode.disabled,
                decoration: InputDecoration(
                  labelText: 'profile.card_number'.tr(),
                  hintText: 'profile.card_number_hint'.tr(),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: kAuthBlue, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: _validateCardNumber,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAuthBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size.fromHeight(50.h),
                ),
                child: Text(
                  'profile.activate_card'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size.fromHeight(48.h),
                ),
                child: Text(
                  'common.cancel'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
