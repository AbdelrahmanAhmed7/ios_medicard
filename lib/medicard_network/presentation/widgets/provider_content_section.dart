import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../core/utils/error_state_widget.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import 'category_service_card.dart';
import 'package_details_sheet.dart';
import 'provider_package_card.dart';
import 'provider_review_card.dart';
import 'provider_service_card.dart';
import 'provider_shared_widgets.dart';

import 'package:medicard/core/theming/app_colors.dart';
/// Sliver content for the selected provider view. Lists stay lazy in the
/// screen's single scrollable instead of measuring nested shrink-wrapped lists.
class ProviderContentSection extends StatelessWidget {
  final ProviderBranch? selectedBranch;

  const ProviderContentSection({super.key, required this.selectedBranch});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isContentSliceChanged,
      builder: (context, state) {
        late final Widget content;
        String? title;
        if (state.currentView == ProviderViewType.services) {
          title = 'provider_page.services'.tr();
          content = CategoryTabsSection(state: state);
        } else if (state.currentView == ProviderViewType.packages) {
          title = 'provider_page.packages'.tr();
          content = PackagesSection(
            state: state,
            selectedBranch: selectedBranch,
          );
        } else {
          content = ReviewsSection(state: state);
        }

        return SliverMainAxisGroup(
          slivers: [
            if (title != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    title,
                    style: AppTextStyles.of(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkClr,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            content,
          ],
        );
      },
    );
  }
}

/// Category chips row + the selected tab's services.
class CategoryTabsSection extends StatelessWidget {
  final ProviderPageState state;

  const CategoryTabsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    if (state.isProviderLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.categoryTabs.isEmpty) {
      return ProviderServicesBody(state: state);
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(state.categoryTabs.length, (index) {
                final tab = state.categoryTabs[index];
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.w),
                  child: CategoryTabChip(
                    tab: tab,
                    isSelected: index == state.selectedCategoryIndex,
                    onTap: () => cubit.selectCategoryTab(index),
                  ),
                );
              }),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        TabServicesBody(state: state),
      ],
    );
  }
}

/// Uncategorized services list (no tabs).
class ProviderServicesBody extends StatelessWidget {
  final ProviderPageState state;

  const ProviderServicesBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    if (state.isServicesLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandBlueClr),
          ),
        ),
      );
    }

    if (state.servicesError != null) {
      return SliverToBoxAdapter(
        child: ErrorStateWidget(
          error: state.servicesError!,
          onRetry: () => cubit.loadProviderServices(reset: true),
        ),
      );
    }

    if (state.services.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'provider_page.no_services_found'.tr(),
              style: AppTextStyles.of(
                color: AppColors.inkMutedClr,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: state.services.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) =>
              ProviderServiceCard(service: state.services[index]),
        ),
        if (state.isServicesLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

/// Selected category tab's services.
class TabServicesBody extends StatelessWidget {
  final ProviderPageState state;

  const TabServicesBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    final tab = state.selectedTab;

    if (tab == null || tab.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandBlueClr),
          ),
        ),
      );
    }

    if (tab.error != null) {
      return SliverToBoxAdapter(
        child: ErrorStateWidget(
          error: tab.error!,
          onRetry: () => cubit.retryTabLoad(state.selectedCategoryIndex),
        ),
      );
    }

    final rawItems = tab.services?.items ?? [];
    final query = state.searchQuery?.trim().toLowerCase() ?? '';
    final items = query.isEmpty
        ? rawItems
        : rawItems.where((service) {
            final name = (service.serviceName as String?)?.toLowerCase() ?? '';
            return name.contains(query);
          }).toList();

    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'provider_page.no_services_found'.tr(),
              style: AppTextStyles.of(
                color: AppColors.inkMutedClr,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) => CategoryServiceCard(
            service: items[index],
            categoryId: tab.categoryId,
          ),
        ),
        if (tab.hasMore && query.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: OutlinedButton(
                onPressed: tab.isLoading
                    ? null
                    : () => cubit.loadMoreCategoryServices(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlueClr,
                  side: const BorderSide(color: AppColors.brandBlueClr),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size(double.infinity, 46.h),
                ),
                child: tab.isLoading
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('common.load_more'.tr()),
              ),
            ),
          ),
      ],
    );
  }
}

/// Packages grid.
class PackagesSection extends StatelessWidget {
  final ProviderPageState state;
  final ProviderBranch? selectedBranch;

  const PackagesSection({
    super.key,
    required this.state,
    required this.selectedBranch,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    if (state.isPackagesLoading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.packagesError != null) {
      return SliverToBoxAdapter(
        child: ErrorStateWidget(
          error: state.packagesError!,
          onRetry: () => cubit.loadPackages(reset: true),
        ),
      );
    }
    if (state.packages.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('provider_page.no_packages_found'.tr())),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final crossAxisSpacing = 12.w;
            final cardWidth =
                (constraints.crossAxisExtent - crossAxisSpacing) / 2;
            return SliverGrid(
              key: const ValueKey('provider-packages-grid'),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: 12.h,
                mainAxisExtent: ProviderPackageCard.preferredHeightForWidth(
                  context,
                  cardWidth,
                ),
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final packageData = state.packages[index];
                final packageId = packageData.id;
                return ProviderPackageCard(
                  packageData: packageData,
                  onDetailsTap: packageId == null
                      ? null
                      : () => openPackageDetailsSheet(
                          context,
                          cubit,
                          packageData,
                          selectedBranch,
                        ),
                  onQuickAdd: packageId == null
                      ? null
                      : () => createPackageInvoice(
                          context,
                          cubit,
                          packageId,
                          selectedBranch,
                        ),
                );
              }, childCount: state.packages.length),
            );
          },
        ),
        if (state.isPackagesLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

/// Reviews list.
class ReviewsSection extends StatelessWidget {
  final ProviderPageState state;

  const ReviewsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    if (state.isReviewsLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.reviewsError != null) {
      return SliverToBoxAdapter(
        child: ErrorStateWidget(
          error: state.reviewsError!,
          onRetry: () => cubit.loadReviews(reset: true),
        ),
      );
    }
    if (state.reviews.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('provider_page.no_reviews_found'.tr())),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverList.separated(
          itemCount: state.reviews.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) =>
              ProviderReviewCard(review: state.reviews[index]),
        ),
        if (state.isReviewsLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

