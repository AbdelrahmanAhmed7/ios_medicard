import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant UnifiedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_onTextChanged);
      } else {
        oldWidget.controller!.removeListener(_onTextChanged);
      }
      if (widget.controller == null) {
        _controller.addListener(_onTextChanged);
      } else {
        widget.controller!.addListener(_onTextChanged);
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_onFocusChanged);
      } else {
        oldWidget.focusNode!.removeListener(_onFocusChanged);
      }
      if (widget.focusNode == null) {
        _focusNode.addListener(_onFocusChanged);
      } else {
        widget.focusNode!.addListener(_onFocusChanged);
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChanged);
      _focusNode.dispose();
    } else {
      widget.focusNode!.removeListener(_onFocusChanged);
    }
    if (widget.controller == null) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
    } else {
      widget.controller!.removeListener(_onTextChanged);
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
    final resolvedPadding = contentPadding.resolve(Directionality.of(context));
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final suffixReserve = widget.suffixIcon != null ? 36.w : 0.0;

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
                            left: resolvedPadding.left +
                                (isRtl ? suffixReserve : 0.0),
                            right: resolvedPadding.right +
                                (isRtl ? 0.0 : suffixReserve),
                          ),
                          child: _AnimatedSearchHint(
                            hintWordKeys: widget.hintWordKeys,
                            searchForPrefixKey: widget.searchForPrefixKey,
                            textStyle: AppTextStyles.of(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 14.sp,
                            ),
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

class _AnimatedSearchHint extends StatefulWidget {
  final List<String> hintWordKeys;
  final String? searchForPrefixKey;
  final TextStyle textStyle;

  const _AnimatedSearchHint({
    required this.hintWordKeys,
    this.searchForPrefixKey,
    required this.textStyle,
  });

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint> {
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.hintWordKeys.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.hintWordKeys.length;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hintWordKeys != widget.hintWordKeys) {
      if (_currentIndex >= widget.hintWordKeys.length) {
        _currentIndex = 0;
      }
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hintWordKeys.isEmpty) return const SizedBox.shrink();

    final safeIndex = _currentIndex % widget.hintWordKeys.length;
    final prefix = widget.searchForPrefixKey != null
        ? '${widget.searchForPrefixKey!.tr()} '
        : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix.isNotEmpty)
          Text(
            prefix,
            style: widget.textStyle,
          ),
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: AlignmentDirectional.centerStart,
                children: <Widget>[
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              final isIncoming = child.key == ValueKey<int>(safeIndex);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isIncoming
                      ? const Offset(0.0, 0.35)
                      : const Offset(0.0, -0.35),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              widget.hintWordKeys[safeIndex].tr(),
              key: ValueKey<int>(safeIndex),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
