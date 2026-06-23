import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/constants.dart';
import '../core/helpers/shared_pref_helper.dart';

// ── Onboarding data ──────────────────────────────────────────────────────────

class _OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}

const _pages = [
  _OnboardingPage(
    imagePath: AppAssets.onboarding2,
    title: 'Less Cost\nMore Care.',
    subtitle: 'One card. Unlimited access to premium healthcare across Egypt.',
    buttonLabel: 'Next',
  ),
  _OnboardingPage(
    imagePath: AppAssets.onboarding1,
    title: '2400+ Providers All\nOver Egypt',
    subtitle:
        'Doctors, labs, pharmacies, gyms and home services all in one card.',
    buttonLabel: 'Get Started',
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class MedicardOnboardingScreen extends StatefulWidget {
  const MedicardOnboardingScreen({super.key});

  @override
  State<MedicardOnboardingScreen> createState() =>
      _MedicardOnboardingScreenState();
}

class _MedicardOnboardingScreenState extends State<MedicardOnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Full-screen immersive for the onboarding experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restore default system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _onButtonPressed() async {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as seen
      await SharedPrefHelper.setData(SharedPrefKeys.hasSeenOnboarding, true);
      if (!mounted) return;
      context.go('/medicard-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen PageView ───────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) =>
                _OnboardingPageView(page: _pages[index]),
          ),

          // ── Bottom overlay ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomOverlay(
              currentPage: _currentPage,
              totalPages: _pages.length,
              buttonLabel: _pages[_currentPage].buttonLabel,
              title: _pages[_currentPage].title,
              subtitle: _pages[_currentPage].subtitle,
              onPressed: _onButtonPressed,
              onSkip: () async {
                await SharedPrefHelper.setData(
                  SharedPrefKeys.hasSeenOnboarding,
                  true,
                );

                if (!context.mounted) return;
                context.go('/medicard-login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-screen page (image) ─────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          page.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: const Color(0xFF3D7CC9),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
        // Gradient overlay from bottom so text is readable
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.35, 0.65, 1.0],
              colors: [
                Colors.transparent,
                Color(0x993D7CC9),
                Color(0xFF1A4A8A),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom overlay (title + subtitle + dots + button) ────────────────────────

class _BottomOverlay extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String buttonLabel;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final VoidCallback onSkip;

  const _BottomOverlay({
    required this.currentPage,
    required this.totalPages,
    required this.buttonLabel,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLast = currentPage == totalPages - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, (bottomPadding + 28.h)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 12.h),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          SizedBox(height: 28.h),

          // Dots indicator + Skip row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSmoothIndicator(
                activeIndex: currentPage,
                count: totalPages,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withValues(alpha: 0.4),
                  dotHeight: 8.h,
                  dotWidth: 8.w,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
              if (!isLast)
                GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF3D7CC9,
                ).withValues(alpha: 0.85),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
