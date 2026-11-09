import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/app_toast.dart';
import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/search_providers_tab.dart';

import 'package:medicard/core/theming/app_colors.dart';
class ProvidersScreen extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final int? categoryId;
  final bool enableCartFeatures;

  const ProvidersScreen({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.categoryId,
    this.enableCartFeatures = true,
  });

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      if (mounted) context.read<SearchCubit>().search(keyword: value);
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
          listener: (context, state) => showErrorToast(state.filterError!),
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.categoriesError != current.categoriesError &&
              current.categoriesError != null,
          listener: (context, state) => showErrorToast(state.categoriesError!),
        ),
        BlocListener<SearchCubit, SearchState>(
          listenWhen: (previous, current) =>
              previous.serviceCategoriesError !=
                  current.serviceCategoriesError &&
              current.serviceCategoriesError != null,
          listener: (context, state) =>
              showErrorToast(state.serviceCategoriesError!),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.whiteClr,
        body: Column(
          children: [
            BlocSelector<FilterCubit, FilterState, bool>(
              selector: (state) =>
                  state.selectedGovernorateId != null ||
                  state.selectedCityId != null ||
                  state.selectedSortBy != null,
              builder: (context, hasActiveFilters) => SearchAppBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilterTap: _openFilterSheet,
                hasActiveFilters: hasActiveFilters,
              ),
            ),
            Expanded(
              child: SearchProvidersTab(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}

