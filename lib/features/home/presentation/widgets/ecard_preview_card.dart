import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/shimmer_card.dart';
import '../../../ecard/data/models/card_data_response_model.dart';
import '../../../ecard/presentation/cubit/ecard_cubit.dart';
import '../../../ecard/presentation/cubit/ecard_state.dart';

import 'package:medicard/core/theming/app_colors.dart';
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
          initial: () => const ECardPreviewShimmer(animate: false),
          loading: () => const ECardPreviewShimmer(),
          loaded: (data) {
            if (data == null) return const SizedBox.shrink();
            return Padding(
              padding: AppSpacing.pageHorizontalInsets,
              child: GestureDetector(
                onTap: () => context.push('/digital-membership'),
                child: _MediCardPreview(card: data),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Reserves the exact space occupied by the home eCard while its separate
/// request is in flight, preventing the quick actions from jumping down when
/// the card data arrives.
class ECardPreviewShimmer extends StatelessWidget {
  final bool animate;

  const ECardPreviewShimmer({super.key, this.animate = true});

  @override
  Widget build(BuildContext context) {
    const placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.exactFFE8E8E8,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );

    return Padding(
      padding: AppSpacing.pageHorizontalInsets,
      child: AspectRatio(
        key: const ValueKey('home-shimmer-ecard'),
        aspectRatio: _MediCardPreview.aspectRatio,
        child: animate ? const SmoothShimmer(child: placeholder) : placeholder,
      ),
    );
  }
}

/// Tiny uppercase caption over a value on the card artwork (bank-card style).
/// Letter-spacing is dropped in Arabic — it breaks letter connections.
class _CardLabel extends StatelessWidget {
  final String text;

  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Text(
      text,
      style: AppTextStyles.of(
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 9.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: isArabic ? 0 : 1.0,
      ),
    );
  }
}

class _MediCardPreview extends StatelessWidget {
  final CardData card;

  const _MediCardPreview({required this.card});

  static const _assetPath = 'assets/ecard/card_background.jpg';
  static const aspectRatio = 1024 / 596;

  @override
  Widget build(BuildContext context) {
    final name = card.fullName;
    final number = card.formattedCardNumber;
    final expiry = card.formattedExpiry;
    final direction = Directionality.of(context);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            top: 88.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardLabel('membership.card_number'.tr().toUpperCase()),
                SizedBox(height: 2.h),
                Text(
                  number.isEmpty ? '—' : number,
                  style: AppTextStyles.of(
                    color: AppColors.whiteClr,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned.directional(
            textDirection: direction,
            start: 24.w,
            end: 110.w,
            bottom: 18.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardLabel('membership.member_name'.tr().toUpperCase()),
                SizedBox(height: 2.h),
                Text(
                  name.isEmpty ? '—' : name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    color: AppColors.whiteClr,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned.directional(
            textDirection: direction,
            end: 18.w,
            bottom: 18.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardLabel('membership.expiry_date_label'.tr().toUpperCase()),
                SizedBox(height: 2.h),
                Text(
                  expiry,
                  style: AppTextStyles.of(
                    color: AppColors.whiteClr,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

