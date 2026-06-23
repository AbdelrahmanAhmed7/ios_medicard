import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  const SearchScreen({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.categoryId,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().init(
        lat: widget.userLatitude,
        lng: widget.userLongitude,
        categoryId: widget.categoryId,
      );
      context.read<FilterCubit>().loadGovernorates();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // ترك الـ 200 كمقياس بيكسل ثابت للإزاحة قبل نهاية القائمة يعتبر ممارسة طبيعية ولا تحتاج ScreenUtil في الغالب
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _SearchAppBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onFilterTap: _openFilterSheet,
          ),
          // Tab bar المظبوط
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
              tabs: const [
                Tab(text: 'Provider'),
                Tab(text: 'Services'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProvidersTab(scrollController: _scrollController),
                const _ServicesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App bar with integrated search ──────────────────────────────────────────

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
      color: const Color(0xFF2D5FA6),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 12.w, 12.h),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                onPressed: () => Navigator.of(context).pop(),
              ),
              // Search field المطور بالكامل
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
                    hintText: 'Doctor name, pharmacy, lab...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: const Color(0xFF9CA3AF),
                      size: 20.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Filter icon المتجاوب
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.tune, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Providers tab ────────────────────────────────────────────────────────────

class _ProvidersTab extends StatelessWidget {
  final ScrollController scrollController;

  const _ProvidersTab({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.categories.isNotEmpty)
              _CategoryChipsRow(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onSelect: (id) =>
                    context.read<SearchCubit>().selectCategory(id),
              ),
            Expanded(child: _ResultsBody(scrollController: scrollController)),
          ],
        );
      },
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  final List categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelect;

  const _CategoryChipsRow({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            CategoryChip(
              category: null,
              isSelected: selectedCategoryId == null,
              onTap: () => onSelect(null),
            ),
            ...categories.map(
              (cat) => CategoryChip(
                category: cat,
                isSelected: selectedCategoryId == cat.id,
                onTap: () => onSelect(cat.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  final ScrollController scrollController;

  const _ResultsBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SearchShimmer();
        }

        if (state.error != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.error!,
            onRetry: () =>
                context.read<SearchCubit>().search(keyword: state.keyword),
          );
        }

        if (state.items.isEmpty) {
          return const _EmptyView();
        }

        return ListView.builder(
          key: const PageStorageKey<String>('providers_results_list'),
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

// ─── Services tab placeholder ─────────────────────────────────────────────────

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 52.sp,
            color: const Color(0xFFD1D5DB),
          ),
          SizedBox(height: 12.h),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Services search will be available soon.',
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

// ─── Empty & Error views ──────────────────────────────────────────────────────

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
            'No providers found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try a different keyword or clear filters.',
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
                'Retry',
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
