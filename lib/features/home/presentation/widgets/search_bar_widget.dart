import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/unified_search_field.dart';

import 'package:medicard/core/theming/app_colors.dart';
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
        child: UnifiedSearchField(
          readOnly: true,
          borderRadius: 14.r,
          borderColor: AppColors.lineClr,
          backgroundColor: AppColors.exactFFF8FAFC,
          useShadow: false,
          transparentBackground: true,
          showAnimatedHint: true,
          hintWordKeys: const [
            'home.search_word_1',
            'home.search_word_2',
            'home.search_word_3',
            'home.search_word_4',
          ],
          searchForPrefixKey: 'home.search_for',
        ),
      ),
    );
  }
}

