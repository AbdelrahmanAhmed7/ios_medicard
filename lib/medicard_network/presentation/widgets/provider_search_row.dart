import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';

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
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TextField(
                      onChanged: (query) => cubit.updateSearchQuery(query),
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A2E),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'provider_page.search_services'.tr(),
                        hintStyle: AppTextStyles.of(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: const Color(0xFF9CA3AF),
                          size: 20.sp,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 12.h,
                        ),
                      ),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProviderViewType>(
                      // Catalog-only control. While reviews content is open,
                      // keep value null so re-selecting Services/Packages can
                      // exit reviews.
                      value: state.currentView == ProviderViewType.reviews
                          ? null
                          : state.catalogView,
                      hint: Text(
                        state.catalogView == ProviderViewType.packages
                            ? 'provider_page.packages'.tr()
                            : 'provider_page.services'.tr(),
                        style: AppTextStyles.of(
                          color: const Color(0xFF64748B),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      isDense: true,
                      items: [
                        DropdownMenuItem(
                          value: ProviderViewType.services,
                          child: Text(
                            'provider_page.services'.tr(),
                            style: AppTextStyles.of(
                              color: const Color(0xFF64748B),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ProviderViewType.packages,
                          child: Text(
                            'provider_page.packages'.tr(),
                            style: AppTextStyles.of(
                              color: const Color(0xFF64748B),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (newValue) async {
                        if (newValue != null) {
                          await cubit.switchView(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}
