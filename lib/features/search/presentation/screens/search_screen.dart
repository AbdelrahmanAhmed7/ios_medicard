import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../cubit/filter_cubit.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/provider_card.dart';
import '../widgets/search_shimmer.dart';

class SearchScreen extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final int? categoryId;
  final int initialTabIndex;
  final bool enableCartFeatures;

  const SearchScreen({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.categoryId,
    this.initialTabIndex = 0,
    this.enableCartFeatures = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  /// Guests cannot use services, so when cart features are disabled
  /// (guest mode) only the providers tab is shown.
  bool get _showServicesTab => widget.enableCartFeatures;

  @override
  void initState() {
    super.initState();
    final tabCount = _showServicesTab ? 2 : 1;
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, tabCount - 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().init(
        lat: widget.userLatitude,
        lng: widget.userLongitude,
        categoryId: widget.categoryId,
        enableCartFeatures: widget.enableCartFeatures,
      );
      context.read<FilterCubit>().loadGovernorates();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchCubit>().search(keyword: value);
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SearchCubit>()),
          BlocProvider.value(value: context.read<FilterCubit>()),
        ],
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listenWhen: (previous, current) =>
          previous.cartActionError != current.cartActionError &&
          current.cartActionError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.cartActionError!)));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            _SearchAppBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onFilterTap: _openFilterSheet,
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
                labelColor: const Color(0xFF2D5FA6),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: const Color(0xFF2D5FA6),
                indicatorWeight: 2.5.h,
                tabs: [
                  Tab(text: 'home.providers'.tr()),
                  if (_showServicesTab) Tab(text: 'home.services'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProvidersTab(scrollController: _scrollController),
                  if (_showServicesTab)
                    _ServicesTab(enableCartFeatures: widget.enableCartFeatures),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _SearchAppBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3872B1),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),

              // Search field — matches home SearchBarWidget exactly,
              // except the filter icon background is transparent here.
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'home.search_hint'.tr(),
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    // Same position/size as home bar's blue circle,
                    // but with a grey icon on transparent background.
                    suffixIcon: GestureDetector(
                      onTap: onFilterTap,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Color(0xFF9CA3AF),
                          size: 18,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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

class _ProvidersTab extends StatelessWidget {
  final ScrollController scrollController;
  const _ProvidersTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (p, c) =>
          p.categories != c.categories ||
          p.selectedCategoryId != c.selectedCategoryId ||
          p.items != c.items ||
          p.isLoading != c.isLoading ||
          p.isLoadingMore != c.isLoadingMore ||
          p.error != c.error,
      builder: (context, state) {
        return Column(
          children: [
            if (state.categories.isNotEmpty)
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      CategoryChip(
                        category: null,
                        isSelected: state.selectedCategoryId == null,
                        onTap: () =>
                            context.read<SearchCubit>().selectCategory(null),
                      ),
                      ...state.categories.map(
                        (cat) => CategoryChip(
                          category: cat,
                          isSelected: state.selectedCategoryId == cat.id,
                          onTap: () => context
                              .read<SearchCubit>()
                              .selectCategory(cat.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: _ResultsBody(scrollController: scrollController)),
          ],
        );
      },
    );
  }
}

class _ResultsBody extends StatelessWidget {
  final ScrollController scrollController;
  const _ResultsBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (p, c) =>
          p.isLoading != c.isLoading ||
          p.isLoadingMore != c.isLoadingMore ||
          p.items != c.items ||
          p.error != c.error,
      builder: (context, state) {
        if (state.isLoading) return const SearchShimmer();
        if (state.error != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.error!,
            onRetry: () =>
                context.read<SearchCubit>().search(keyword: state.keyword),
          );
        }
        if (state.items.isEmpty) return const _EmptyView();

        return ListView.builder(
          key: const PageStorageKey<String>('providers_list'),
          controller: scrollController,
          padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF2D5FA6),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }
            return ProviderCard(provider: state.items[index]);
          },
        );
      },
    );
  }
}

class _ServicesTab extends StatefulWidget {
  final bool enableCartFeatures;

  const _ServicesTab({required this.enableCartFeatures});

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
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
                      color: Color(0xFF2D5FA6),
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
              style: TextStyle(
                fontFamily: 'Inter',
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
        child: CircularProgressIndicator(color: Color(0xFF2D5FA6)),
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
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => context
                    .read<SearchCubit>()
                    .loadCategoryServices(_selectedCategoryId!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5FA6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                  minimumSize: Size(120.w, 40.h),
                ),
                child: Text(
                  'common.retry'.tr(),
                  style: TextStyle(
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
              style: TextStyle(
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

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        totalSelected > 0 ? MediaQuery.of(context).padding.bottom + 92.h : 16.h,
      ),
      itemCount: state.services.length,
      itemBuilder: (context, index) {
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
              context.push('/medicard-login');
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
              ? const Color(0xFF2D5FA6).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: TextStyle(
                    fontFamily: 'Inter',
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
                    ? const Color(0xFF2D5FA6)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xFF2D5FA6), width: 1.8),
              ),
              child: Center(
                child: isPending
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: Color(0xFF2D5FA6),
                        ),
                      )
                    : Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2D5FA6),
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
            color: const Color(0xFF2D5FA6),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D5FA6).withValues(alpha: 0.30),
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
                    style: TextStyle(
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
                style: TextStyle(
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
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
            'search.no_providers_found'.tr(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'search.try_different_keyword'.tr(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5FA6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
                minimumSize: Size(120.w, 40.h),
              ),
              child: Text(
                'common.retry'.tr(),
                style: TextStyle(
                  fontFamily: 'Inter',
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
}
