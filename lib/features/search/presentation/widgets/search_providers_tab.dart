import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import 'category_chip.dart';
import 'provider_card.dart';
import 'search_shimmer.dart';

class SearchProvidersTab extends StatelessWidget {
  final ScrollController scrollController;
  const SearchProvidersTab({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ProviderCategoryStrip(),
        Expanded(child: _ResultsBody(scrollController: scrollController)),
      ],
    );
  }
}

class _ProviderCategoryStrip extends StatelessWidget {
  const _ProviderCategoryStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategoryId != current.selectedCategoryId,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();

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
                  isSelected: state.selectedCategoryId == null,
                  onTap: () => context.read<SearchCubit>().selectCategory(null),
                ),
                ...state.categories.map(
                  (category) => CategoryChip(
                    category: category,
                    isSelected: state.selectedCategoryId == category.id,
                    onTap: () =>
                        context.read<SearchCubit>().selectCategory(category.id),
                  ),
                ),
              ],
            ),
          ),
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
                      color: Color(0xFF3872B1),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }
            final provider = state.items[index];
            return ProviderCard(
              key: ValueKey('provider_${provider.providerId ?? index}'),
              provider: provider,
            );
          },
        );
      },
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
            style: AppTextStyles.of(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'search.try_different_keyword'.tr(),
            style: AppTextStyles.of(
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
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
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
}
