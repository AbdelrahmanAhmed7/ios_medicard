import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/unified_search_field.dart';

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
    'home.search_word_4',
  ];

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppHeaderSpacing.padding(top: 12.h, bottom: 6.h),
          child: Row(
            children: [
              AppHeaderBackButton(
                onPressed: () {
                  // Search can be the last page on the stack (deep link or
                  // restored state) — a bare pop() crashes go_router there.
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/medicard-home');
                  }
                },
                color: const Color(0xFF111827),
              ),

              // Floating search pill.
              Expanded(
                child: UnifiedSearchField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  autofocus: false,
                  useShadow: false,
                  showPrefixIcon: true,
                  showAnimatedHint: true,
                  hintWordKeys: _wordKeys,
                  searchForPrefixKey: 'home.search_for',
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
                                margin: const EdgeInsetsDirectional.only(
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
                                            color: const Color(0xFF3872B1),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
