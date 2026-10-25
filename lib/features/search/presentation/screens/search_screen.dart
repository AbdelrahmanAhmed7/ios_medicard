import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/search_providers_tab.dart';
import '../widgets/search_services_tab.dart';

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

  /// Both providers and services tabs are always shown. Guests browse the
  /// services tab in read-only mode (no cart selection), backed by the
  /// public `GuestMobileHome/servicesByCategory` endpoint.
  bool get _showServicesTab => true;

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
    final servicesTabIndex = _showServicesTab ? 1 : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SearchCubit>()),
          BlocProvider.value(value: context.read<FilterCubit>()),
        ],
        child: FilterBottomSheet(
          hideProviderFilters: _tabController.index == servicesTabIndex,
        ),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.cartActionError != current.cartActionError &&
              current.cartActionError != null,
          listener: (context, state) {
            final message = state.cartActionError!;
            context.read<SearchCubit>().consumeCartActionError();
            showErrorToast(message);
          },
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.filterError != current.filterError &&
              current.filterError != null,
          listener: (context, state) {
            showErrorToast(state.filterError!);
          },
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.categoriesError != current.categoriesError &&
              current.categoriesError != null,
          listener: (context, state) {
            showErrorToast(state.categoriesError!);
          },
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.serviceCategoriesError !=
                  current.serviceCategoriesError &&
              current.serviceCategoriesError != null,
          listener: (context, state) {
            showErrorToast(state.serviceCategoriesError!);
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                final servicesTabIndex = _showServicesTab ? 1 : null;
                final onServicesTab = _tabController.index == servicesTabIndex;
                return BlocSelector<FilterCubit, FilterState, bool>(
                  selector: (state) =>
                      state.selectedGovernorateId != null ||
                      state.selectedCityId != null ||
                      state.selectedSortBy != null,
                  builder: (context, hasActiveFilters) => SearchAppBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onFilterTap: onServicesTab ? null : _openFilterSheet,
                    hasActiveFilters: hasActiveFilters,
                  ),
                );
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEF1F5), width: 1),
                ),
              ),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  final tabs = [
                    'home.providers'.tr(),
                    if (_showServicesTab) 'home.services'.tr(),
                  ];
                  return Row(
                    children: List.generate(tabs.length, (i) {
                      final isSelected = _tabController.index == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(i),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Text(
                                  tabs[i],
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.of(
                                    fontSize: 15.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: const Color(0xFF3872B1),
                                  ),
                                ),
                              ),
                              Container(
                                height: 3.h,
                                margin: EdgeInsets.symmetric(horizontal: 32.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF3872B1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(3.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SearchProvidersTab(scrollController: _scrollController),
                  if (_showServicesTab)
                    SearchServicesTab(
                      enableCartFeatures: widget.enableCartFeatures,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
