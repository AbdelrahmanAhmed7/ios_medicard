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
  final int? initialCategoryId;

  const SearchServicesTab({
    super.key,
    required this.enableCartFeatures,
    this.initialCategoryId,
  });

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
          previous.categoryServiceCounts != current.categoryServiceCounts ||
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
        final selectedCategoryTitle =
            state.serviceCategories
                .where((cat) => cat.id == _selectedCategoryId)
                .firstOrNull
                ?.name ??
            state.servicesData?.categoryName ??
            '';

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
                          serviceCount: state.categoryServiceCounts[cat.id],
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
            if (selectedCategoryTitle.isNotEmpty)
              _ServicesHeader(title: selectedCategoryTitle),
            Expanded(
              child: Stack(
                children: [
                  _buildServicesBody(context, state, totalSelected),
                  if (widget.enableCartFeatures && totalSelected > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ReviewServicesBar(count: totalSelected),
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

    final firstCategoryId =
        widget.initialCategoryId ??
        state.serviceCategories
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
          key: ValueKey('svc_${service.serviceId ?? index}'),
          serviceId: serviceId,
          categoryId: categoryId,
          serviceNameAr: service.serviceNameAr,
          serviceNameEn: service.serviceNameEn,
          isSelected: isSelected,
        );
      },
    );
  }
}

class _ServicesHeader extends StatelessWidget {
  final String title;

  const _ServicesHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 2.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.of(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'search.choose_services'.tr(),
              style: AppTextStyles.of(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A94A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCardConnector extends StatefulWidget {
  final int serviceId;
  final int categoryId;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final bool isSelected;

  const _ServiceCardConnector({
    super.key,
    required this.serviceId,
    required this.categoryId,
    required this.serviceNameAr,
    required this.serviceNameEn,
    required this.isSelected,
  });

  @override
  State<_ServiceCardConnector> createState() => _ServiceCardConnectorState();
}

class _ServiceCardConnectorState extends State<_ServiceCardConnector> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchCubit, SearchState, bool>(
      selector: (state) => state.pendingServiceIds.contains(widget.serviceId),
      builder: (context, isPending) {
        return _ServiceCard(
          serviceId: widget.serviceId,
          serviceNameAr: widget.serviceNameAr,
          serviceNameEn: widget.serviceNameEn,
          isSelected: widget.isSelected,
          isPending: isPending,
          isMedicine: widget.categoryId == 1,
          quantity: quantity,
          onIncrement: () {
            if (!widget.isSelected || isPending || widget.categoryId != 1) {
              return;
            }
            final next = quantity + 1;
            setState(() => quantity = next);
            context.read<SearchCubit>().updateMedicineQuantity(
              serviceId: widget.serviceId,
              quantity: next,
            );
          },
          onDecrement: () {
            if (!widget.isSelected || isPending || widget.categoryId != 1) {
              return;
            }
            if (quantity <= 1) {
              context.read<SearchCubit>().removeServiceFromCart(
                serviceId: widget.serviceId,
                categoryId: widget.categoryId,
              );
              return;
            }
            final next = quantity - 1;
            setState(() => quantity = next);
            context.read<SearchCubit>().updateMedicineQuantity(
              serviceId: widget.serviceId,
              quantity: next,
            );
          },
          onToggle: () {
            if (!context.read<SearchCubit>().enableCartFeatures) {
              showLoginRequiredMessage(context);
              return;
            }
            if (widget.isSelected) {
              context.read<SearchCubit>().removeServiceFromCart(
                serviceId: widget.serviceId,
                categoryId: widget.categoryId,
              );
            } else {
              context.read<SearchCubit>().addServiceToCart(
                serviceId: widget.serviceId,
                categoryId: widget.categoryId,
                quantity: widget.categoryId == 1 ? quantity : 1,
              );
            }
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final int serviceId;
  final String? serviceNameAr;
  final String? serviceNameEn;
  final bool isSelected;
  final bool isPending;
  final bool isMedicine;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onToggle;

  const _ServiceCard({
    required this.serviceId,
    required this.serviceNameAr,
    required this.serviceNameEn,
    required this.isSelected,
    required this.isPending,
    required this.isMedicine,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onToggle,
  });

  static const _iconBackgrounds = [
    Color(0xFFFDECEC),
    Color(0xFFE8F0FB),
    Color(0xFFF3EDFB),
    Color(0xFFE6F6EE),
    Color(0xFFFEF4E2),
  ];

  static const _iconForegrounds = [
    Color(0xFFE05B5B),
    Color(0xFF3872B1),
    Color(0xFF8A5BD6),
    Color(0xFF16A374),
    Color(0xFFD99A28),
  ];

  @override
  Widget build(BuildContext context) {
    final tone = serviceId.abs() % _iconBackgrounds.length;
    final isArabic = context.locale.languageCode == 'ar';
    final primaryName =
        (isArabic ? serviceNameAr : serviceNameEn)?.trim() ?? '';
    final secondaryName =
        (isArabic ? serviceNameEn : serviceNameAr)?.trim() ?? '';
    final title = primaryName.isNotEmpty ? primaryName : secondaryName;
    final showSecondary =
        primaryName.isNotEmpty &&
        secondaryName.isNotEmpty &&
        secondaryName.toLowerCase() != primaryName.toLowerCase();
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: _iconBackgrounds[tone],
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.medical_services_rounded,
              size: 22.sp,
              color: _iconForegrounds[tone],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                if (showSecondary) ...[
                  SizedBox(height: 4.h),
                  Text(
                    secondaryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
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
          if (isMedicine && isSelected && !isPending) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: quantity <= 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove,
                  onTap: onDecrement,
                ),
                SizedBox(
                  width: 26.w,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _QuantityButton(icon: Icons.add, onTap: onIncrement),
                SizedBox(width: 6.w),
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEAF1F9),
                      border: Border.all(color: const Color(0xFF3872B1)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF3872B1),
                      size: 19.sp,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            InkWell(
              onTap: isPending ? null : onToggle,
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected && !isPending
                      ? const Color(0xFF3872B1)
                      : const Color(0xFFF1F6FC),
                  border: Border.all(
                    color: const Color(0xFF3872B1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isPending
                      ? SizedBox(
                          width: 17.r,
                          height: 17.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: Color(0xFF3872B1),
                          ),
                        )
                      : Icon(
                          isSelected ? Icons.check_rounded : Icons.add_rounded,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF3872B1),
                          size: 19.sp,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFF3872B1)),
      ),
      child: Icon(icon, size: 17.sp, color: const Color(0xFF3872B1)),
    ),
  );
}

class _ReviewServicesBar extends StatelessWidget {
  final int count;
  const _ReviewServicesBar({required this.count});

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
        onTap: () => context.push('/cart'),
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
                'cart.review_services'.tr(),
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
