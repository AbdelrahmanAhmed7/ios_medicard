import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import 'category_chip.dart';
import 'search_shimmer.dart';

class SearchServicesTab extends StatefulWidget {
  final bool enableCartFeatures;

  const SearchServicesTab({super.key, required this.enableCartFeatures});

  @override
  State<SearchServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<SearchServicesTab> {
  int? _selectedCategoryId;
  bool _didAutoSelectCategory = false;
  bool _isAutoSelectingCategory = false;
  bool _didFinishAutoSelectCategory = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.serviceCategories != current.serviceCategories ||
          previous.isLoadingServiceCategories !=
              current.isLoadingServiceCategories ||
          previous.categorySelectedCounts != current.categorySelectedCounts ||
          previous.isLoadingServices != current.isLoadingServices ||
          previous.loadingServiceCategoryIds !=
              current.loadingServiceCategoryIds ||
          previous.loadingMoreServiceCategoryIds !=
              current.loadingMoreServiceCategoryIds ||
          previous.servicesError != current.servicesError ||
          previous.servicesData != current.servicesData ||
          previous.services != current.services,
      builder: (context, state) {
        _autoSelectFirstCategory(context, state);
        final totalSelected = state.categorySelectedCounts.values.fold(
          0,
          (sum, c) => sum + c,
        );

        return Column(
          children: [
            if (state.isLoadingServiceCategories)
              Container(
                color: Colors.white,
                height: 110.h,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3872B1),
                    ),
                  ),
                ),
              )
            else if (state.serviceCategories.isNotEmpty)
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      ...state.serviceCategories.map((cat) {
                        if (cat.id == null) return const SizedBox.shrink();
                        final count = state.categorySelectedCounts[cat.id] ?? 0;
                        return CategoryChip(
                          category: cat,
                          isSelected: _selectedCategoryId == cat.id,
                          badgeCount: count > 0 ? count : null,
                          onTap: () {
                            setState(() => _selectedCategoryId = cat.id);
                            context.read<SearchCubit>().loadCategoryServices(
                              cat.id!,
                              search: _currentServiceSearch(context),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildServicesBody(context, state, totalSelected),
                  if (widget.enableCartFeatures && totalSelected > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ChooseProviderBar(count: totalSelected),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String? _currentServiceSearch(BuildContext context) {
    if (widget.enableCartFeatures) return null;
    final keyword = context.read<SearchCubit>().state.keyword.trim();
    return keyword.isEmpty ? null : keyword;
  }

  void _autoSelectFirstCategory(BuildContext context, SearchState state) {
    if (_didAutoSelectCategory ||
        state.isLoadingServiceCategories ||
        state.serviceCategories.isEmpty) {
      return;
    }

    final firstCategoryId = state.serviceCategories
        .map((category) => category.id)
        .whereType<int>()
        .firstOrNull;
    if (firstCategoryId == null) return;

    _didAutoSelectCategory = true;
    _isAutoSelectingCategory = true;
    _didFinishAutoSelectCategory = false;
    _selectedCategoryId = firstCategoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<SearchCubit>().loadCategoryServices(firstCategoryId);
      if (!mounted) return;
      setState(() {
        _isAutoSelectingCategory = false;
        _didFinishAutoSelectCategory = true;
      });
    });
  }

  Widget _buildServicesBody(
    BuildContext context,
    SearchState state,
    int totalSelected,
  ) {
    final isInitialServicesLoading =
        state.isLoadingServiceCategories ||
        state.isLoadingServices ||
        state.loadingServiceCategoryIds.isNotEmpty ||
        (_didAutoSelectCategory && !_didFinishAutoSelectCategory) ||
        _isAutoSelectingCategory;

    if (_selectedCategoryId == null && isInitialServicesLoading) {
      return const SearchShimmer();
    }

    if (_selectedCategoryId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_rounded,
              size: 52.sp,
              color: const Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12.h),
            Text(
              'search.no_services_found'.tr(),
              style: AppTextStyles.of(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    if (state.isLoadingServices) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      );
    }

    if (state.servicesError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 52.sp,
                color: const Color(0xFFD1D5DB),
              ),
              SizedBox(height: 12.h),
              Text(
                state.servicesError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () =>
                    context.read<SearchCubit>().loadCategoryServices(
                      _selectedCategoryId!,
                      search: _currentServiceSearch(context),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3872B1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                  minimumSize: Size(120.w, 40.h),
                ),
                child: Text(
                  'common.retry'.tr(),
                  style: AppTextStyles.of(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52.sp,
              color: const Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12.h),
            Text(
              'search.no_services_found'.tr(),
              style: AppTextStyles.of(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    final categoryId = state.servicesData?.categoryId ?? 0;
    final hasMore =
        state.loadingMoreServiceCategoryIds.isNotEmpty ||
        context.read<SearchCubit>().hasMoreCategoryServices(categoryId);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        totalSelected > 0 ? MediaQuery.of(context).padding.bottom + 92.h : 16.h,
      ),
      itemCount: state.services.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.services.length) {
          final categoryIdHere = state.servicesData?.categoryId;
          if (categoryIdHere != null &&
              !state.loadingMoreServiceCategoryIds.contains(categoryIdHere)) {
            context.read<SearchCubit>().loadMoreCategoryServices(
              categoryIdHere,
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  color: Color(0xFF3872B1),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        }
        final service = state.services[index];
        final serviceId = service.serviceId ?? 0;
        final isSelected = service.isSelected == true;
        return _ServiceCardConnector(
          serviceId: serviceId,
          categoryId: categoryId,
          serviceName: service.serviceName ?? '',
          isSelected: isSelected,
        );
      },
    );
  }
}

class _ServiceCardConnector extends StatelessWidget {
  final int serviceId;
  final int categoryId;
  final String serviceName;
  final bool isSelected;

  const _ServiceCardConnector({
    required this.serviceId,
    required this.categoryId,
    required this.serviceName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, bool>(
      selector: (state) => state.pendingServiceIds.contains(serviceId),
      builder: (context, isPending) {
        return _ServiceCard(
          serviceName: serviceName,
          isSelected: isSelected,
          isPending: isPending,
          onToggle: () {
            if (!context.read<SearchCubit>().enableCartFeatures) {
              showLoginRequiredMessage(context);
              return;
            }
            if (isSelected) {
              context.read<SearchCubit>().removeServiceFromCart(
                serviceId: serviceId,
                categoryId: categoryId,
              );
            } else {
              context.read<SearchCubit>().addServiceToCart(
                serviceId: serviceId,
                categoryId: categoryId,
              );
            }
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String serviceName;
  final bool isSelected;
  final bool isPending;
  final VoidCallback onToggle;

  const _ServiceCard({
    required this.serviceName,
    required this.isSelected,
    required this.isPending,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3872B1).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFFEF3C7),
                //     borderRadius: BorderRadius.circular(20.r),
                //     border: Border.all(
                //       color: const Color(0xFFFDE68A),
                //       width: 1,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(
                //         Icons.access_time_rounded,
                //         size: 12.sp,
                //         color: const Color(0xFFD97706),
                //       ),
                //       SizedBox(width: 4.w),
                //       Text(
                //         'No Fasting',
                //         style: TextStyle(
                //           fontSize: 11.sp,
                //           fontWeight: FontWeight.w600,
                //           color: const Color(0xFFD97706),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isPending ? null : onToggle,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected && !isPending
                    ? const Color(0xFF3872B1)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xFF3872B1), width: 1.8),
              ),
              child: Center(
                child: isPending
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: Color(0xFF3872B1),
                        ),
                      )
                    : Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF3872B1),
                        size: 18.sp,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChooseProviderBar extends StatelessWidget {
  final int count;
  const _ChooseProviderBar({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        0,
        16.w,
        MediaQuery.of(context).padding.bottom + 14.h,
      ),
      child: GestureDetector(
        onTap: () => context.push('/choose-provider'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF3872B1),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3872B1).withValues(alpha: 0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'cart.choose_provider'.tr(),
                style: AppTextStyles.of(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
