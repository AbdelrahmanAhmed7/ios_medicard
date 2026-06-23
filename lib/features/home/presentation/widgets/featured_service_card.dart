import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/featured_service_model.dart';

class FeaturedServiceCard extends StatelessWidget {
  final FeaturedServiceModel service;

  const FeaturedServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final hasProviderLogo = service.providerLogoUrl.trim().isNotEmpty;
    final hasRating = service.rating > 0 || service.reviewCount > 0;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: service.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFFEEF3FB),
                  height: 120,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFEEF3FB),
                  height: 120,
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (hasProviderLogo)
                Positioned(
                  top: 8,
                  left: 8,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: service.providerLogoUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: const Color(0xFFEEF3FB)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 16),
                      ),
                    ),
                  ),
                ),
              if (hasRating)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF5A623),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${service.rating} (${service.reviewCount})',
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

          // Info area
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Service name
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                Text(
                  service.providerName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        service.location,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${service.originalPrice.toInt()} EGP',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${service.discountedPrice.toInt()} EGP',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D5FA6),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5FA6),
                          foregroundColor: const Color(0xFF2D5FA6),
                          side: const BorderSide(
                            color: Color(0xFF2D5FA6),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}