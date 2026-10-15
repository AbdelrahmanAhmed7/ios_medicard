import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theming/app_text_styles.dart';

class SearchBarWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const SearchBarWidget({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/search',
          extra: {'userLatitude': latitude, 'userLongitude': longitude},
        );
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'home.search_hint'.tr(),
            hintStyle: AppTextStyles.of(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
      ),
    );
  }
}
