import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../data/models/card_data_response_model.dart';
import '../cubit/ecard_cubit.dart';
import '../cubit/ecard_state.dart';

/// Digital membership screen (see design: blue member card + membership
/// details). Only fields the backend actually provides are shown —
/// everything else (member code, MCI id, employer, insurance conditions)
/// stays hidden until an endpoint ships it.
class DigitalMembershipScreen extends StatelessWidget {
  const DigitalMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<ECardCubit, ECardState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<ECardCubit>().loadCardData();
                }
              });
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            failed: (error) => ErrorStateWidget(
              error: error,
              onRetry: () =>
                  context.read<ECardCubit>().loadCardData(forceRefresh: true),
            ),
            loaded: (data) {
              if (data == null) {
                return ErrorStateWidget(
                  error: 'errors.not_found_error'.tr(),
                  onRetry: () => context.read<ECardCubit>().loadCardData(
                    forceRefresh: true,
                  ),
                );
              }
              return _MembershipBody(card: data);
            },
          );
        },
      ),
    );
  }
}

class _MembershipBody extends StatelessWidget {
  final CardData card;

  const _MembershipBody({required this.card});

  @override
  Widget build(BuildContext context) {
    final name = card.fullName.isEmpty ? '—' : card.fullName;
    final expiry = _formatExpiry(card.expireAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 0),
            child: _DigitalCardArt(card: card),
          ),
          SizedBox(height: 20.h),
          _SectionTitle('membership.details_title'.tr()),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _DetailsGroup(
              rows: [
                _DetailRow(label: 'membership.member_name'.tr(), value: name),
                if (card.formattedCardNumber.isNotEmpty)
                  _DetailRow(
                    label: 'membership.card_number'.tr(),
                    value: card.formattedCardNumber,
                  ),
                _DetailRow(label: 'membership.valid_until'.tr(), value: expiry),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  static String _formatExpiry(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppHeaderBackButton(
              color: const Color(0xFF111827),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Text(
                'membership.title'.tr(),
                style: AppTextStyles.of(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Digital card visual reusing the ecard artwork — the same card shown
/// on home. The artwork is shown edge to edge (no frame/clip) so it reads as
/// a single printed surface.
class _DigitalCardArt extends StatelessWidget {
  final CardData card;

  const _DigitalCardArt({required this.card});

  static const _assetPath = 'assets/ecard/card_background.jpg';
  static const _aspectRatio = 1024 / 596;

  @override
  Widget build(BuildContext context) {
    final name = card.fullName.isEmpty ? '—' : card.fullName;
    final number = card.formattedCardNumber;
    final expiry = card.formattedExpiry;
    final direction = Directionality.of(context);

    return AspectRatio(
      aspectRatio: _aspectRatio,
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
                    color: Colors.white,
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
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    color: Colors.white,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: Text(
        title,
        style: AppTextStyles.of(
          color: const Color(0xFF111827),
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailsGroup extends StatelessWidget {
  final List<_DetailRow> rows;

  const _DetailsGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, color: Color(0xFFEEF1F5)),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.of(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
