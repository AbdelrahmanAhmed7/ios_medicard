import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';

class SearchAppBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  static const _wordKeys = [
    'home.search_word_1',
    'home.search_word_2',
    'home.search_word_3',
  ];

  late final FocusNode _focusNode;
  Timer? _hintTimer;
  int _hintIndex = 0;

  TextEditingController get controller => widget.controller;
  bool get _showOverlay => !_focusNode.hasFocus && controller.text.isEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    controller.addListener(_onTextChanged);
    // Rotate the trailing word every 3s while the field is idle.
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_showOverlay) return;
      setState(() => _hintIndex = (_hintIndex + 1) % _wordKeys.length);
    });
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
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 16.w, 12.h),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  // Search can be the last page on the stack (deep link or
                  // restored state) — a bare pop() crashes go_router there.
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/medicard-home');
                  }
                },
                child: SizedBox(
                  width: 42.r,
                  height: 42.r,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFF111827),
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Floating search pill.
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: const Color(0xFFE5E9F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: controller,
                        focusNode: _focusNode,
                        autofocus: false,
                        onChanged: widget.onChanged,
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          color: const Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: _showOverlay ? '' : 'home.search_hint'.tr(),
                          hintStyle: AppTextStyles.of(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 0,
                          ),
                          // Same position/size as home bar's blue circle,
                          // but with a grey icon on transparent background.
                          // The filter only applies to providers, so it is hidden
                          // while browsing the services tab.
                          suffixIcon: widget.onFilterTap == null
                              ? null
                              : Builder(
                                  builder: (iconContext) {
                                    final isRtl =
                                        Localizations.localeOf(
                                          iconContext,
                                        ).languageCode ==
                                        'ar';
                                    return GestureDetector(
                                      onTap: widget.onFilterTap,
                                      child: Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                              end: 8,
                                            ),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: widget.hasActiveFilters
                                                    ? const Color(0xFFEFF6FF)
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.tune,
                                                color: widget.hasActiveFilters
                                                    ? const Color(0xFF3872B1)
                                                    : const Color(0xFF9CA3AF),
                                                size: 18,
                                              ),
                                            ),
                                            if (widget.hasActiveFilters)
                                              Positioned(
                                                top: 4,
                                                right: isRtl ? null : 4,
                                                left: isRtl ? 4 : null,
                                                child: Container(
                                                  width: 9,
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF3872B1,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                      ),
                      // Rotating showcase hint: fixed "Search for" + animated word.
                      // Visible only while idle; the real hint takes over on focus.
                      if (_showOverlay)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 40.w,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${'home.search_for'.tr()} ',
                                      style: AppTextStyles.of(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 14,
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        _wordKeys[_hintIndex].tr(),
                                        key: ValueKey<int>(_hintIndex),
                                        style: AppTextStyles.of(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 14,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
