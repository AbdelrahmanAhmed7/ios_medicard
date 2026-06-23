import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/provider_model.dart';

class NearestProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const NearestProviderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + rating badge
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: provider.imageUrl,
                height: 159,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFEEF3FB),
                  height: 160,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFEEF3FB),
                  height: 160,
                  width: double.infinity,
                  child: const Icon(Icons.broken_image, color: Color(0xFF9CA3AF)),
                ),
              ),
              if (provider.rating > 0 || provider.reviewCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF5A623), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '${provider.rating} (${provider.reviewCount})',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Bottom info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Discount badges
                if (provider.badges.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: provider.badges.map((badge) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2D5FA6), width: 0.8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D5FA6),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 6),
                ],

                // Provider name
                Text(
                  provider.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider.type.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    provider.type,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (provider.location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          provider.location,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
