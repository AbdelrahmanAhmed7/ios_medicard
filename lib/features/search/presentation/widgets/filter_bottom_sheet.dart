import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';
import '../cubit/search_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_dropdown_menu_item.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key, this.hideProviderFilters = false});

  /// The sort and location filters only apply to the providers search. The
  /// backend services endpoints support neither sorting nor geo filtering nor
  /// carry discount data — so those sections are hidden on the services tab.
  final bool hideProviderFilters;

  static const List<_SortOption> _sortOptions = [
    _SortOption(value: 1, labelKey: 'sort_filter.nearest'),
    _SortOption(value: 2, labelKey: 'sort_filter.highest_discount'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24.h,
      ),
      child: BlocBuilder<FilterCubit, FilterState>(
        builder: (context, state) {
          final filterCubit = context.read<FilterCubit>();
          final searchCubit = context.read<SearchCubit>();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar النظيف العلوي
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // العنوان مع زر الـ Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'search.filter'.tr(),
                      style: AppTextStyles.of(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    TextButton(
                      onPressed: () => filterCubit.resetFilters(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'search.reset'.tr(),
                        style: AppTextStyles.of(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: const Color(0xFF3872B1),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Sort By Section
                if (!hideProviderFilters) ...[
                  _SectionTitle(title: 'sort_filter.sort_by'.tr()),
                  SizedBox(height: 10.h),
                  ..._sortOptions.map(
                    (option) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _SortOptionTile(
                        label: option.labelKey.tr(),
                        value: option.value,
                        groupValue: state.selectedSortBy,
                        onTap: () => filterCubit.selectSortBy(option.value),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Location Section
                if (!hideProviderFilters) ...[
                  _SectionTitle(title: 'sort_filter.location'.tr()),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _LookupDropdown(
                          hint: 'sort_filter.government'.tr(),
                          isLoading: state.isLoadingGovernorates,
                          items: state.governorates
                              .map(
                                (g) => AppDropdownMenuItem(
                                  value: g.id,
                                  label: g.name ?? '',
                                ),
                              )
                              .toList(),
                          value: state.selectedGovernorateId,
                          onChanged: (id) => filterCubit.selectGovernorate(id),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _LookupDropdown(
                          hint: 'sort_filter.city'.tr(),
                          isLoading: state.isLoadingCities,
                          isDisabled: state.selectedGovernorateId == null,
                          items: state.cities
                              .map(
                                (c) => AppDropdownMenuItem(
                                  value: c.id,
                                  label: c.name ?? '',
                                ),
                              )
                              .toList(),
                          value: state.selectedCityId,
                          onChanged: state.selectedGovernorateId == null
                              ? null
                              : (id) => filterCubit.selectCity(id),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],

                // Apply button المظبوط
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3872B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      searchCubit.applyFilters(
                        governorateId: state.selectedGovernorateId,
                        cityId: state.selectedCityId,
                        sortBy: state.selectedSortBy,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'search.apply_filters'.tr(),
                      style: AppTextStyles.of(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.of(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: const Color(0xFF374151),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String label;
  final int value;
  final int? groupValue;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3872B1)
                : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3872B1)
                      : const Color(0xFFD1D5DB),
                  width: 2.w,
                ),
                color: isSelected
                    ? const Color(0xFF3872B1)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFF374151),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18.sp,
                color: const Color(0xFF3872B1),
              ),
          ],
        ),
      ),
    );
  }
}

class _LookupDropdown extends StatelessWidget {
  final String hint;
  final bool isLoading;
  final bool isDisabled;
  final List<DropdownMenuItem<int?>> items;
  final int? value;
  final ValueChanged<int?>? onChanged;

  const _LookupDropdown({
    required this.hint,
    required this.isLoading,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 46.h,
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3872B1),
                ),
              ),
            )
          : AppDropdownTheme(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  hint: Text(
                    hint,
                    style: AppTextStyles.of(
                      fontSize: 13.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  value: value,
                  items: items,
                  onChanged: isDisabled ? null : onChanged,
                  style: AppTextStyles.of(
                    fontSize: 13.sp,
                    color: const Color(0xFF1A1A2E),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9CA3AF),
                    size: 22.sp,
                  ),
                ),
              ),
            ),
    );
  }
}

class _SortOption {
  final int value;
  final String labelKey;
  const _SortOption({required this.value, required this.labelKey});
}
