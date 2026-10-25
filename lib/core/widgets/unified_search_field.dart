import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/app_text_styles.dart';

class UnifiedSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? hintText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool showPrefixIcon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final bool useShadow;
  final bool transparentBackground;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final TextInputType? keyboardType;

  // Animated hint (like SearchAppBar)
  final bool showAnimatedHint;
  final List<String> hintWordKeys;
  final String? searchForPrefixKey;

  const UnifiedSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.hintText,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.showPrefixIcon = true,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 12,
    this.borderColor = const Color(0xFFE2E8F0),
    this.backgroundColor = Colors.white,
    this.useShadow = false,
    this.transparentBackground = false,
    this.contentPadding,
    this.height,
    this.keyboardType,
    this.showAnimatedHint = false,
    this.hintWordKeys = const [],
    this.searchForPrefixKey = 'home.search_for',
  });

  @override
  State<UnifiedSearchField> createState() => _UnifiedSearchFieldState();
}

class _UnifiedSearchFieldState extends State<UnifiedSearchField> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  Timer? _hintTimer;
  int _hintIndex = 0;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  bool get _showOverlay {
    if (!widget.showAnimatedHint) return false;
    if (_effectiveFocusNode.hasFocus) return false;
    if (_effectiveController.text.isNotEmpty) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _effectiveFocusNode.addListener(_onFocusChanged);
    _effectiveController.addListener(_onTextChanged);

    if (widget.showAnimatedHint && widget.hintWordKeys.isNotEmpty) {
      _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        if (!_showOverlay) return;
        setState(
          () => _hintIndex = (_hintIndex + 1) % widget.hintWordKeys.length,
        );
      });
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
    } else {
      _effectiveFocusNode.removeListener(_onFocusChanged);
      _effectiveController.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = widget.hintText ?? 'home.search_hint'.tr();
    final contentPadding =
        widget.contentPadding ??
        EdgeInsetsDirectional.only(
          start: widget.showPrefixIcon ? 0 : 4.w,
          end: 4.w,
          top: 12.h,
          bottom: 12.h,
        );
    return Container(
      height: widget.height ?? 44.h,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
        boxShadow: widget.useShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.showPrefixIcon)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 6.w, end: 2.w),
              child:
                  widget.prefixIcon ??
                  Icon(
                    Icons.search,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
            ),
          Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: _effectiveController,
                  focusNode: _effectiveFocusNode,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.transparentBackground
                        ? Colors.transparent
                        : widget.backgroundColor,
                    hintText: _showOverlay ? '' : effectiveHint,
                    hintStyle: AppTextStyles.of(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14.sp,
                    ),
                    suffixIcon: widget.suffixIcon,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: contentPadding,
                  ),
                ),
                if (_showOverlay && widget.hintWordKeys.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: contentPadding
                                .resolve(Directionality.of(context))
                                .left,
                            right: contentPadding
                                .resolve(Directionality.of(context))
                                .right,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.searchForPrefixKey != null)
                                Text(
                                  '${widget.searchForPrefixKey!.tr()} ',
                                  style: AppTextStyles.of(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              Flexible(
                                child: AnimatedSize(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      // Fade the old word out completely before
                                      // revealing the next one. A regular
                                      // cross-fade paints both words on top of
                                      // each other and looks like a brief hang.
                                      final opacity = CurvedAnimation(
                                        parent: animation,
                                        curve: const Interval(
                                          0.5,
                                          1,
                                          curve: Curves.easeOut,
                                        ),
                                      );
                                      return FadeTransition(
                                        opacity: opacity,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      widget.hintWordKeys[_hintIndex].tr(),
                                      key: ValueKey<int>(_hintIndex),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.of(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 14.sp,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
