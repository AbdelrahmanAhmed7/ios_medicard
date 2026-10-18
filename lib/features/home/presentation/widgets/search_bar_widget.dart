import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/unified_search_field.dart';

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
          borderRadius: 24.r,
          borderColor: const Color(0xFFE5E9F0),
          backgroundColor: Colors.white,
          useShadow: true,
          transparentBackground: true,
          showAnimatedHint: true,
          hintWordKeys: const [
            'home.search_word_1',
            'home.search_word_2',
            'home.search_word_3',
          ],
          searchForPrefixKey: 'home.search_for',
        ),
      ),
    );
  }
}
