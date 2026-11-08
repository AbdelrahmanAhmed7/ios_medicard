import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/search_medicines_tab.dart';
import '../widgets/search_services_tab.dart';

class SearchScreen extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final int? categoryId;
  final int initialTabIndex;
  final int? initialServiceCategoryId;
  final bool enableCartFeatures;

  const SearchScreen({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.categoryId,
    this.initialTabIndex = 0,
    this.initialServiceCategoryId,
    this.enableCartFeatures = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    const tabCount = 2;
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
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchCubit>().search(keyword: value);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            SearchAppBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
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
                  final tabs = ['home.services'.tr(), 'cart.medicines'.tr()];
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
                  SearchServicesTab(
                    enableCartFeatures: widget.enableCartFeatures,
                    initialCategoryId: widget.initialServiceCategoryId,
                  ),
                  SearchMedicinesTab(
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
