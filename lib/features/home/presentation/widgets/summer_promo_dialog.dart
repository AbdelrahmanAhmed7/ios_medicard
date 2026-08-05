import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shows a summer-promotion popup once per app launch,
/// only between June 1 and October 15 of the current year.
class SummerPromoDialog {
  static const _assetPath = 'assets/promotions/summer_promo.jpeg';

  // In-memory flag — resets every cold start.
  static bool _shownThisLaunch = false;

  static bool get _isPromoActive {
    final now = DateTime.now();
    final start = DateTime(now.year, 6, 1);
    final end = DateTime(now.year, 10, 30, 23, 59, 59);
    return !now.isBefore(start) && !now.isAfter(end);
  }

  static Future<void> maybeShow(BuildContext context) async {
    if (_shownThisLaunch) return;
    if (!_isPromoActive) return;
    if (!context.mounted) return;

    _shownThisLaunch = true;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      barrierDismissible: true,
      builder: (_) => const _SummerPromoDialog(),
    );
  }
}

class _SummerPromoDialog extends StatelessWidget {
  const _SummerPromoDialog();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            constraints: BoxConstraints(maxHeight: screenHeight * 0.78),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                SummerPromoDialog._assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          // Close button — floats above the card's top-right corner
          Positioned(
            top: -14.r,
            right: 24.w - 14.r,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
