import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';

/// Compact three-step indicator for the provider checkout flow:
/// choose provider -> review order -> payment.
class OrderStepsIndicator extends StatelessWidget {
  static const _blue = Color(0xFF3872B1);
  static const _line = Color(0xFFE2E8F0);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF94A3B8);

  /// Zero-based index of the active step.
  final int currentStep;

  const OrderStepsIndicator({super.key, required this.currentStep});

  static const List<String> _labels = [
    'cart.step_provider',
    'cart.step_review',
    'cart.step_payment',
  ];

  @override
  Widget build(BuildContext context) {
    // Rebuild when the locale changes so the labels follow the language.
    final _ = context.locale;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 12.h),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      color: i <= currentStep ? _blue : _line,
                    ),
                  ),
                _StepDot(
                  number: i + 1,
                  isDone: i < currentStep,
                  isCurrent: i == currentStep,
                ),
              ],
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: Text(
                    _labels[i].tr(),
                    textAlign: i == 0
                        ? TextAlign.start
                        : i == _labels.length - 1
                        ? TextAlign.end
                        : TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(
                      fontSize: 11.5.sp,
                      fontWeight: i == currentStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i <= currentStep ? _ink : _muted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool isDone;
  final bool isCurrent;

  const _StepDot({
    required this.number,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isDone || isCurrent;
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? OrderStepsIndicator._blue : Colors.white,
        border: Border.all(
          color: isActive
              ? OrderStepsIndicator._blue
              : OrderStepsIndicator._line,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check_rounded, size: 13.sp, color: Colors.white)
            : Text(
                '$number',
                style: AppTextStyles.of(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? Colors.white : OrderStepsIndicator._muted,
                ),
              ),
      ),
    );
  }
}
