import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/shared_pref_helper.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/haptic_feedback_service.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/models/cart.dart';
import '../../domain/repository/cart_repository.dart';
import '../../domain/services/cart_sync_service.dart';

import 'package:medicard/core/theming/app_colors.dart';
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
  static const _defaultVerticalRatio = 0.88;

  Offset? _position;
  bool _isDragging = false;
  bool _dockedRight = true;
  double _verticalRatio = _defaultVerticalRatio;
  bool _placementChangedByUser = false;
  int _count = 0;
  StreamSubscription<CartSyncEvent>? _syncSub;
  bool _wasLastLocationHidden = false;

  @override
  void initState() {
    super.initState();
    AppRouter.currentLocation.addListener(_onLocationChanged);
    _syncSub = sl<CartSyncService>().stream.listen(_onCartSyncEvent);
    unawaited(_restorePlacement());
    _refreshCount();
  }

  void _onCartSyncEvent(CartSyncEvent event) {
    if (event.cartCleared) {
      if (mounted && _count != 0) setState(() => _count = 0);
      return;
    }
    if (event.selectedServiceIds != null) {
      final newCount = event.selectedServiceIds!.length;
      if (mounted && _count != newCount) setState(() => _count = newCount);
      return;
    }
    _refreshCount();
  }

  Future<void> _restorePlacement() async {
    try {
      final hasSavedPlacement = await SharedPrefHelper.getBool(
        SharedPrefKeys.cartFabPositionSaved,
      );
      if (!hasSavedPlacement) return;

      final dockedRight = await SharedPrefHelper.getBool(
        SharedPrefKeys.cartFabDockedRight,
      );
      final verticalRatio = await SharedPrefHelper.getDouble(
        SharedPrefKeys.cartFabVerticalRatio,
      );
      if (!mounted || _placementChangedByUser || !verticalRatio.isFinite) {
        return;
      }

      setState(() {
        _dockedRight = dockedRight;
        _verticalRatio = verticalRatio.clamp(0.0, 1.0).toDouble();
      });
    } catch (_) {
      // Placement is optional UI state; keep the safe default on read errors.
    }
  }

  Future<void> _persistPlacement({
    required bool dockedRight,
    required double verticalRatio,
  }) async {
    try {
      await Future.wait([
        SharedPrefHelper.setData(
          SharedPrefKeys.cartFabDockedRight,
          dockedRight,
        ),
        SharedPrefHelper.setData(
          SharedPrefKeys.cartFabVerticalRatio,
          verticalRatio,
        ),
      ]);
      await SharedPrefHelper.setData(SharedPrefKeys.cartFabPositionSaved, true);
    } catch (_) {
      // Dragging must remain usable even if preferences cannot be persisted.
    }
  }

  bool _locationRefreshScheduled = false;

  DateTime? _lastFetchTime;

  void _onLocationChanged() {
    // The observer fires mid-build (Navigator updating); defer so setState
    // never runs during another subtree's build phase.
    if (!mounted || _locationRefreshScheduled) return;
    _locationRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationRefreshScheduled = false;
      if (!mounted) return;
      final location = AppRouter.currentLocation.value;
      if (_isSessionlessRoute(location)) {
        _wasLastLocationHidden = false;
        if (_count != 0) setState(() => _count = 0);
        return;
      }
      final isHidden = _isHiddenRoute(location);
      final returningFromHidden = _wasLastLocationHidden && !isHidden;
      _wasLastLocationHidden = isHidden;

      setState(() {});

      if (isHidden) return;

      // Always re-fetch when popping back from the cart or checkout flow,
      // when count is 0, or if at least 60s elapsed since last fetch.
      final now = DateTime.now();
      final shouldFetch = returningFromHidden ||
          _lastFetchTime == null ||
          _count == 0 ||
          now.difference(_lastFetchTime!) > const Duration(seconds: 60);

      if (shouldFetch) {
        _lastFetchTime = now;
        _refreshCount();
      }
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
    final location = AppRouter.currentLocation.value;

    // No cart on auth/guest screens — also avoids unauthenticated calls.
    // Any stale count from a previous session is dropped here.
    if (_isSessionlessRoute(location)) {
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

  static const _sessionlessRoutes = <String>{
    '/medicard-login',
    '/medicard-register',
    '/forgot-password',
    '/onboarding',
    '/medicard-activation',
    '/guest-home',
  };

  static bool _isHiddenRoute(String location) {
    if (location.isEmpty) return true;
    for (final route in _cartHiddenRoutes) {
      if (location == route || location.startsWith('$route/')) return true;
    }
    return false;
  }

  static bool _isSessionlessRoute(String location) {
    for (final route in _sessionlessRoutes) {
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
    final verticalTravel = math.max(0.0, maxY - minY);
    Offset clampPosition(Offset position) =>
        Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));

    // The saved height is normalized inside the currently usable viewport.
    // When the keyboard changes [maxY], the same ratio moves the button above
    // it and restores the original position when the keyboard closes.
    final dockedY = minY + (verticalTravel * _verticalRatio);
    final pos = clampPosition(
      _isDragging && _position != null
          ? _position!
          : Offset(_dockedRight ? maxX : minX, dockedY),
    );

    void dockToEdge() {
      final current = clampPosition(_position ?? pos);
      final dockedRight = current.dx >= (minX + maxX) / 2;
      final verticalRatio = verticalTravel == 0
          ? _verticalRatio
          : ((current.dy - minY) / verticalTravel).clamp(0.0, 1.0).toDouble();
      setState(() {
        _dockedRight = dockedRight;
        _verticalRatio = verticalRatio;
        _position = null;
        _isDragging = false;
      });
      HapticFeedbackService.instance.lightImpact();
      unawaited(
        _persistPlacement(
          dockedRight: dockedRight,
          verticalRatio: verticalRatio,
        ),
      );
    }

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      left: pos.dx,
      top: pos.dy,
      child: RepaintBoundary(
        child: GestureDetector(
        // This widget is outside the router subtree in MaterialApp.builder.
        onTap: () {
          HapticFeedbackService.instance.lightImpact();
          AppRouter.current?.push('/cart');
        },
        onPanStart: (_) {
          HapticFeedbackService.instance.selectionClick();
          setState(() {
            _placementChangedByUser = true;
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
        child: AnimatedScale(
          scale: _isDragging ? 1.08 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: AppColors.brandBlueClr,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF3872B1,
                  ).withValues(alpha: _isDragging ? 0.48 : 0.35),
                  blurRadius: _isDragging ? 18 : 12,
                  offset: Offset(0, _isDragging ? 7 : 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.whiteClr,
                  size: 26.sp,
                ),
                Positioned(
                  top: 2.h,
                  right: 2.w,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 20.r,
                      minHeight: 20.r,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: AppColors.exactFFEF4444,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          _count > 99 ? '99+' : '$_count',
                          key: ValueKey(_count),
                          style: AppTextStyles.of(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.whiteClr,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

