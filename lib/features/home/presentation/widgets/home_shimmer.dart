import 'package:flutter/material.dart';

import '../../../../core/utils/shimmer_card.dart';
import 'home_horizontal_card_style.dart';

/// Shimmer skeleton that mimics the real HomeScreen layout sections.
/// Wrap it inside a parent scroll (e.g. SingleChildScrollView or SliverToBoxAdapter).
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Promo banner ────────────────────────────────────────────────────
          const ShimmerCard(
            width: double.infinity,
            height: 160,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),

          const SizedBox(height: 24),

          // ── Section title placeholder ───────────────────────────────────────
          _SectionTitleShimmer(),
          const SizedBox(height: 12),

          // ── Appointments horizontal scroll (w=310, h=90) ───────────────────
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                ShimmerCard(
                  width: 310,
                  height: 90,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: 12),
                ShimmerCard(
                  width: 310,
                  height: 90,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section title placeholder ───────────────────────────────────────
          _SectionTitleShimmer(),
          const SizedBox(height: 12),

          // ── Nearest providers horizontal scroll (w=270, h=274) ─────────────
          SizedBox(
            height: HomeHorizontalCardStyle.height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: HomeHorizontalCardStyle.listPadding,
              children: const [
                ShimmerCard(
                  width: HomeHorizontalCardStyle.width,
                  height: HomeHorizontalCardStyle.height,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: HomeHorizontalCardStyle.cardGap),
                ShimmerCard(
                  width: HomeHorizontalCardStyle.width,
                  height: HomeHorizontalCardStyle.height,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section title placeholder ───────────────────────────────────────
          _SectionTitleShimmer(),
          const SizedBox(height: 12),

          // ── Featured services horizontal scroll ────────────────────────────
          SizedBox(
            height: HomeHorizontalCardStyle.height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: HomeHorizontalCardStyle.listPadding,
              children: const [
                ShimmerCard(
                  width: HomeHorizontalCardStyle.width,
                  height: HomeHorizontalCardStyle.height,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: HomeHorizontalCardStyle.cardGap),
                ShimmerCard(
                  width: HomeHorizontalCardStyle.width,
                  height: HomeHorizontalCardStyle.height,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Small helper that renders a shimmer pill mimicking a section title row.
class _SectionTitleShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SmoothShimmer(
        child: Container(
          height: 16,
          width: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
