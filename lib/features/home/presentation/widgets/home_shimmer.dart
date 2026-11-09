import 'package:flutter/material.dart';

import '../../../../core/utils/shimmer_card.dart';
import 'home_horizontal_card_style.dart';

import 'package:medicard/core/theming/app_colors.dart';
const _placeholderColor = AppColors.exactFFE8E8E8;

class HomeShimmer extends StatelessWidget {
  final bool showAppointments;

  const HomeShimmer({super.key, this.showAppointments = true});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ExcludeSemantics(
        // A single shimmer keeps every placeholder in phase and avoids
        // creating an animation controller for each individual card.
        child: SmoothShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PromoBannerShimmer(),
              const SizedBox(height: 24),
              if (showAppointments) ...[
                const _HomeSectionShimmer(
                  key: ValueKey('home-shimmer-appointments'),
                  cardWidth: 310,
                  cardHeight: 90,
                ),
                const SizedBox(height: 24),
              ],
              const _HomeSectionShimmer(
                key: ValueKey('home-shimmer-providers'),
                cardWidth: HomeHorizontalCardStyle.width,
                cardHeight: HomeHorizontalCardStyle.height,
              ),
              const SizedBox(height: 24),
              const _HomeSectionShimmer(
                key: ValueKey('home-shimmer-services'),
                cardWidth: HomeHorizontalCardStyle.width,
                cardHeight: HomeHorizontalCardStyle.height,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBannerShimmer extends StatelessWidget {
  const _PromoBannerShimmer();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('home-shimmer-promo'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _ShimmerBlock(width: 150, height: 20, radius: 6),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _ShimmerBlock(
            width: double.infinity,
            height: 165,
            radius: HomeHorizontalCardStyle.radius,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ShimmerBlock(width: 16, height: 6, radius: 3),
            SizedBox(width: 6),
            _ShimmerBlock(width: 6, height: 6, radius: 3),
            SizedBox(width: 6),
            _ShimmerBlock(width: 6, height: 6, radius: 3),
          ],
        ),
      ],
    );
  }
}

class _HomeSectionShimmer extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;

  const _HomeSectionShimmer({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: HomeHorizontalCardStyle.listPadding,
          child: Row(
            children: [
              _ShimmerBlock(width: 140, height: 18, radius: 6),
              Spacer(),
              _ShimmerBlock(width: 58, height: 14, radius: 6),
            ],
          ),
        ),
        const SizedBox(height: HomeHorizontalCardStyle.sectionGap),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: HomeHorizontalCardStyle.listPadding,
            itemCount: 2,
            separatorBuilder: (_, _) =>
                const SizedBox(width: HomeHorizontalCardStyle.cardGap),
            itemBuilder: (_, _) => _ShimmerBlock(
              width: cardWidth,
              height: cardHeight,
              radius: HomeHorizontalCardStyle.radius,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _placeholderColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

