import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../ecard/data/models/card_data_response_model.dart';
import '../../../ecard/presentation/cubit/ecard_cubit.dart';
import '../../../ecard/presentation/cubit/ecard_state.dart';

class ECardPreviewCard extends StatefulWidget {
  const ECardPreviewCard({super.key});

  @override
  State<ECardPreviewCard> createState() => _ECardPreviewCardState();
}

class _ECardPreviewCardState extends State<ECardPreviewCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ECardCubit>().loadCardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ECardCubit, ECardState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (data) {
            if (data == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _MediCardPreview(card: data),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _MediCardPreview extends StatelessWidget {
  final CardData card;

  const _MediCardPreview({required this.card});

  static const _assetPath = 'assets/ecard/card_background.jpg';
  static const _aspectRatio = 1024 / 596;

  @override
  Widget build(BuildContext context) {
    final name = card.fullName;
    final plan = (card.planType ?? '').trim();
    final number = card.formattedCardNumber;
    final expiry = card.formattedExpiry;

    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _assetPath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            if (plan.isNotEmpty)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    plan,
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 24.w,
              right: 24.w,
              top: 88.h,
              child: Text(
                number.isEmpty ? '—' : number,
                style: AppTextStyles.of(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Positioned(
              left: 24.w,
              right: 110.w,
              bottom: 18.h,
              child: Text(
                name.isEmpty ? '—' : name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.of(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            Positioned(
              right: 18.w,
              bottom: 18.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ecard.expiry_date'.tr(),
                    style: AppTextStyles.of(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    expiry,
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
