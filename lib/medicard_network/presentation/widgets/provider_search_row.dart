import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_text_styles.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import '../../../core/widgets/unified_search_field.dart';

/// Search field + view-switcher dropdown. The text field keeps its own input
/// state; this row rebuilds only when its visibility or the dropdown value
/// can change (view switches) — never on keystrokes.
class ProviderSearchRow extends StatelessWidget {
  const ProviderSearchRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isSearchRowSliceChanged,
      builder: (context, state) {
        if (state.currentView == ProviderViewType.reviews) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<ProviderPageCubit>();
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: UnifiedSearchField(
                      onChanged: (query) => cubit.updateSearchQuery(query),
                      hintText: 'provider_page.search_services'.tr(),
                      borderRadius: 12.r,
                      useShadow: false,
                      transparentBackground: false,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: PopupMenuButton<ProviderViewType>(
                    initialValue: state.catalogView,
                    position: PopupMenuPosition.under,
                    offset: Offset(0, 8.h),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: ProviderViewType.services,
                        child: Text(
                          'provider_page.services'.tr(),
                          style: AppTextStyles.of(
                            color: AppColors.inkClr,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: ProviderViewType.packages,
                        child: Text(
                          'provider_page.packages'.tr(),
                          style: AppTextStyles.of(
                            color: AppColors.inkClr,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                    onSelected: (newValue) async {
                      await cubit.switchView(newValue);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.catalogView == ProviderViewType.packages
                              ? 'provider_page.packages'.tr()
                              : 'provider_page.services'.tr(),
                          style: AppTextStyles.of(
                            color: const Color(0xFF64748B),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        );
      },
    );
  }
}
