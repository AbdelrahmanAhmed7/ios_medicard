import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/models/cart.dart';
import '../../domain/repository/cart_repository.dart';
import '../../domain/services/cart_sync_service.dart';

/// Floating draggable cart button shown app-wide above all screens.
///
/// - Follows the finger and docks to the nearest side when released.
/// - A tap opens the cart.
/// - Badge count refreshes automatically on every cart change.
/// - Hidden while the cart is empty.
class FloatingCartButton extends StatefulWidget {
  const FloatingCartButton({super.key});

  @override
  State<FloatingCartButton> createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends State<FloatingCartButton> {
  Offset? _position;
  bool _isDragging = false;
  bool _dockedRight = true;
  int _count = 0;
  StreamSubscription<CartSyncEvent>? _syncSub;

  @override
  void initState() {
    super.initState();
    AppRouter.currentLocation.addListener(_onLocationChanged);
    _syncSub = sl<CartSyncService>().stream.listen((_) => _refreshCount());
    _refreshCount();
  }

  bool _locationRefreshScheduled = false;

  void _onLocationChanged() {
    // The observer fires mid-build (Navigator updating); defer so setState
    // never runs during another subtree's build phase.
    if (!mounted || _locationRefreshScheduled) return;
    _locationRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationRefreshScheduled = false;
      if (!mounted) return;
      setState(() {});
      // Re-sync on every navigation: entering a visible route (e.g. home
      // right after login) must re-fetch instead of trusting a stale 0.
      // _refreshCount no-ops on hidden routes by itself.
      _refreshCount();
    });
  }

  @override
  void dispose() {
    AppRouter.currentLocation.removeListener(_onLocationChanged);
    _syncSub?.cancel();
    super.dispose();
  }

  /// Guards overlapping fetches (init + rapid sync events): only the
  /// latest response is allowed to touch [_count].
  int _refreshGeneration = 0;

  Future<void> _refreshCount() async {
    // No cart on auth/guest screens — also avoids unauthenticated calls.
    // Any stale count from a previous session is dropped here.
    if (_isHiddenRoute(AppRouter.currentLocation.value)) {
      if (mounted && _count != 0) setState(() => _count = 0);
      return;
    }
    final generation = ++_refreshGeneration;
    try {
      final ApiResult<Cart> result = await sl<CartRepository>().getCart();
      if (!mounted || generation != _refreshGeneration) return;
      result.when(
        success: (cart) {
          if (!mounted || generation != _refreshGeneration) return;
          final count = cart.totalCount;
          if (count != _count) setState(() => _count = count);
        },
        failure: (_) {
          // Keep the last known count: a transient failure (offline blip,
          // timeout, token mid-refresh) must not hide a non-empty cart.
          // The count still resets on hidden routes and on the next
          // successful fetch.
        },
      );
    } catch (_) {}
  }

  /// Routes where the cart button must never appear: the purchase flow
  /// itself plus every screen reachable without a logged-in shopping
  /// session (auth, onboarding, guest, activation).
  static const _cartHiddenRoutes = <String>{
    '/cart',
    '/checkout',
    '/choose-provider',
    '/medicard-login',
    '/medicard-register',
    '/forgot-password',
    '/onboarding',
    '/medicard-activation',
    '/guest-home',
  };

  static bool _isHiddenRoute(String location) {
    for (final route in _cartHiddenRoutes) {
      if (location == route || location.startsWith('$route/')) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = AppRouter.currentLocation.value;
    if (_isHiddenRoute(location)) {
      return const SizedBox.shrink();
    }
    if (_count <= 0) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final buttonSize = 56.r;
    final minX = padding.left + 8;
    final maxX = math.max(minX, size.width - padding.right - buttonSize - 8);
    final minY = padding.top + 8;
    final maxY = math.max(
      minY,
      size.height -
          math.max(padding.bottom, viewInsets.bottom) -
          buttonSize -
          8,
    );
    Offset clampPosition(Offset position) =>
        Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));

    // Default dock: bottom-right above the bottom nav.
    _position ??= Offset(maxX, size.height - buttonSize - 120.h);
    final pos = clampPosition(
      Offset(
        _isDragging ? _position!.dx : (_dockedRight ? maxX : minX),
        _position!.dy,
      ),
    );

    void dockToEdge() {
      final current = clampPosition(_position ?? pos);
      setState(() {
        _dockedRight = current.dx >= (minX + maxX) / 2;
        _position = Offset(_dockedRight ? maxX : minX, current.dy);
        _isDragging = false;
      });
    }

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        // This widget is outside the router subtree in MaterialApp.builder.
        onTap: () => AppRouter.current?.push('/cart'),
        onPanStart: (_) {
          setState(() {
            _position = pos;
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position = clampPosition(_position! + details.delta);
          });
        },
        onPanEnd: (_) => dockToEdge(),
        onPanCancel: dockToEdge,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: const Color(0xFF3872B1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3872B1).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 26.sp,
              ),
              Positioned(
                top: 2.h,
                right: 2.w,
                child: Container(
                  constraints: BoxConstraints(minWidth: 20.r, minHeight: 20.r),
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      _count > 99 ? '99+' : '$_count',
                      style: AppTextStyles.of(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
