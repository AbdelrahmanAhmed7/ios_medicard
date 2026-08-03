import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/widgets/app_blue_header.dart';
import '../../../ecard/data/models/card_data_response_model.dart';
import '../../../ecard/presentation/cubit/ecard_cubit.dart';
import '../../../ecard/presentation/cubit/ecard_state.dart';

class ECardScreen extends StatefulWidget {
  const ECardScreen({super.key});

  @override
  State<ECardScreen> createState() => _ECardScreenState();
}

class _ECardScreenState extends State<ECardScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          AppBlueHeader(
            title: 'ecard.title'.tr(),
            showBack: false,
            contentHeight: kMainTabHeaderContentHeight,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          Expanded(
            child: BlocBuilder<ECardCubit, ECardState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const _ECardLoading(),
                  loading: () => const _ECardLoading(),
                  loaded: (data) => data == null
                      ? const _NoCardView()
                      : _ActiveCardView(card: data),
                  failed: (error) => _ECardErrorView(message: error),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ECardLoading extends StatelessWidget {
  const _ECardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF3976B7)),
    );
  }
}

class _ECardErrorView extends StatelessWidget {
  final String message;

  const _ECardErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: const Color(0xFF9CA3AF),
              size: 48.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              message.isNotEmpty
                  ? message
                  : 'errors.something_went_wrong'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<ECardCubit>().loadCardData(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3976B7),
                foregroundColor: Colors.white,
              ),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCardView extends StatelessWidget {
  const _NoCardView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15.w, 19.h, 15.w, 32.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24.w, 29.h, 24.w, 37.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: const Color(0xFFCFE0F6)),
        ),
        child: Column(
          children: [
            Text(
              'ecard.no_card_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF111D37),
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'ecard.no_card_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF435579),
                fontSize: 12.sp,
                height: 1.18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveCardView extends StatelessWidget {
  final CardData card;

  const _ActiveCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15.w, 24.h, 15.w, 32.h),
      child: _MediCardPreview(card: card),
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
                    style: TextStyle(
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
                style: TextStyle(
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
                style: TextStyle(
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
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    expiry,
                    style: TextStyle(
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
