import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../data/home_mock_data.dart';

import 'package:medicard/core/theming/app_colors.dart';
class PromoBannerWidget extends StatefulWidget {
  final List<PromoBanner> banners;

  const PromoBannerWidget({super.key, required this.banners});

  @override
  State<PromoBannerWidget> createState() => _PromoBannerWidgetState();
}

class _PromoBannerWidgetState extends State<PromoBannerWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (widget.banners.isEmpty) return;
      final nextPage = (_currentPageNotifier.value + 1) % widget.banners.length;
      _currentPageNotifier.value = nextPage;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            8.h,
            AppSpacing.pageHorizontal,
            8.h,
          ),
          child: Text(
            'home.discover_offers'.tr(),
            style: AppTextStyles.of(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkClr,
            ),
          ),
        ),
        SizedBox(
          height: 165,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              _currentPageNotifier.value = index;
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: GestureDetector(
                  onTap: banner.providerId == null
                      ? null
                      : () => context.push(
                          '/provider-page',
                          extra: banner.providerId,
                        ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.exactFFF8FAFC,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      memCacheWidth: 800,
                      memCacheHeight: 400,
                      width: double.infinity,
                      height: 165,
                      // Offer artwork often contains text/logos near its
                      // edges. `cover` crops those edges on narrower phones;
                      // `contain` keeps the complete creative visible.
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) =>
                          const ColoredBox(color: AppColors.exactFFF8FAFC),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: _currentPageNotifier,
          builder: (context, currentPage, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (index) {
                final isActive = currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.brandBlueClr
                        : AppColors.exactFF9CA3AF,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

