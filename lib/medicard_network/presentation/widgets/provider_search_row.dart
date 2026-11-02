import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_text_styles.dart';
import '../../../core/widgets/app_dropdown_menu_item.dart';
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
                  child: UnifiedSearchField(
                    onChanged: (query) => cubit.updateSearchQuery(query),
                    hintText: 'provider_page.search_services'.tr(),
                    useShadow: false,
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
                  child: AppDropdownTheme(
                    child: MenuAnchor(
                      alignmentOffset: Offset(0, 8.h),
                      style: AppDropdownTheme.menuStyle,
                      menuChildren: [
                        MenuItemButton(
                          style:
                              AppDropdownTheme.menuItemButtonStyle(
                                isSelected:
                                    state.catalogView ==
                                    ProviderViewType.services,
                              ).copyWith(
                                minimumSize: WidgetStatePropertyAll(
                                  Size(150.w, 48.h),
                                ),
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 16.w),
                                ),
                              ),
                          onPressed: () async {
                            await cubit.switchView(ProviderViewType.services);
                          },
                          child: Text(
                            'provider_page.services'.tr(),
                            style: AppDropdownTheme.menuItemTextStyle(
                              selected:
                                  state.catalogView ==
                                  ProviderViewType.services,
                            ),
                          ),
                        ),
                        MenuItemButton(
                          style:
                              AppDropdownTheme.menuItemButtonStyle(
                                isSelected:
                                    state.catalogView ==
                                    ProviderViewType.packages,
                              ).copyWith(
                                minimumSize: WidgetStatePropertyAll(
                                  Size(150.w, 48.h),
                                ),
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 16.w),
                                ),
                              ),
                          onPressed: () async {
                            await cubit.switchView(ProviderViewType.packages);
                          },
                          child: Text(
                            'provider_page.packages'.tr(),
                            style: AppDropdownTheme.menuItemTextStyle(
                              selected:
                                  state.catalogView ==
                                  ProviderViewType.packages,
                            ),
                          ),
                        ),
                      ],
                      builder: (context, controller, child) => InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.catalogView == ProviderViewType.packages
                                  ? 'provider_page.packages'.tr()
                                  : 'provider_page.services'.tr(),
                              style: AppTextStyles.of(
                                color: AppColors.brandBlueClr,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.brandBlueClr,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
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
