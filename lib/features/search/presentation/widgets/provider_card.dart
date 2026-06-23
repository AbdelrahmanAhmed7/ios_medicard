import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/search_provider_model.dart';

class ProviderCard extends StatelessWidget {
  final SearchProviderModel provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFC6D8EC);

    return Container(
      constraints: BoxConstraints(minHeight: 110.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(borderColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(provider.providerName)) ...[
                    Text(
                      provider.providerName!.trim(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color: const Color(0xFF000000),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if ((provider.maxDiscountPercentage ?? 0) > 0) ...[
                    _DiscountChipsRow(
                      categoryName: provider.categoryName,
                      maxDiscount: provider.maxDiscountPercentage,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  _RatingAndLocationRow(provider: provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color borderColor) {
    return Container(
      width: 100.w,
      height: 110.h,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: borderColor, width: 1.w),
        ),
      ),
      padding: EdgeInsets.all(12.r),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: provider.imageUrl ?? '',
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => Icon(
            Icons.local_hospital_outlined,
            color: const Color(0xFF2D5FA6),
            size: 28.sp,
          ),
        ),
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

class _DiscountChipsRow extends StatelessWidget {
  final String? categoryName;
  final double? maxDiscount;

  const _DiscountChipsRow({this.categoryName, this.maxDiscount});

  @override
  Widget build(BuildContext context) {
    if (maxDiscount == null || maxDiscount! <= 0) {
      return const SizedBox.shrink();
    }

    final pct = maxDiscount!.toStringAsFixed(0);
    final chips = <String>[];
    if (categoryName != null && categoryName!.trim().isNotEmpty) {
      chips.add('Scan $pct%');
    }
    chips.add('$pct% Off');

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: chips.map((label) => _buildChip(label)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FD),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF8BA9D4), width: 1.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: const Color(0xFF2D5FA6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RatingAndLocationRow extends StatelessWidget {
  final SearchProviderModel provider;

  const _RatingAndLocationRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final hasRating = (provider.averageRating ?? 0) > 0;
    final hasDistance = provider.distanceKm != null;

    if (!hasRating && !hasDistance) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (hasRating) ...[
          Icon(Icons.star_rounded, color: const Color(0xFFF5A623), size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            provider.averageRating!.toStringAsFixed(1),
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
        if (hasRating && hasDistance) const Spacer(),
        if (hasDistance) ...[
          Icon(
            Icons.location_on_outlined,
            size: 14.sp,
            color: const Color(0xFF475569),
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              '${provider.distanceKm!.toStringAsFixed(1)} km',
              style: TextStyle(fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}