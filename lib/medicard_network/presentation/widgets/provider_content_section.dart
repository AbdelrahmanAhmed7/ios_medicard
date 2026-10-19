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

/// Switches between services / packages / reviews bodies. Rebuilds only when
/// the content slice changes (see [_isContentSliceChanged] on the screen).
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

        if (title == null) return content;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.of(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
            ),
            SizedBox(height: 8.h),
            content,
          ],
        );
      },
    );
  }
}

/// Category chips row + the selected tab's services. Pure given [state];
/// the cubit comes from context for actions.
class CategoryTabsSection extends StatelessWidget {
  final ProviderPageState state;

  const CategoryTabsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProviderPageCubit>();
    if (state.isProviderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.categoryTabs.isEmpty) {
      return ProviderServicesBody(state: state);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tab chips row ────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(state.categoryTabs.length, (i) {
              final tab = state.categoryTabs[i];
              final isSelected = i == state.selectedCategoryIndex;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 10.w),
                child: CategoryTabChip(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => cubit.selectCategoryTab(i),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 12.h),

        // ── Services for selected tab ────────────────────────────────────
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF3872B1)),
        ),
      );
    }

    if (state.servicesError != null) {
      return ErrorStateWidget(
        error: state.servicesError!,
        onRetry: () => cubit.loadProviderServices(reset: true),
      );
    }

    if (state.services.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'provider_page.no_services_found'.tr(),
            style: AppTextStyles.of(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.services.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return ProviderServiceCard(service: state.services[index]);
          },
        ),
        if (state.isServicesLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF3872B1)),
        ),
      );
    }

    if (tab.error != null) {
      return ErrorStateWidget(
        error: tab.error!,
        onRetry: () => cubit.retryTabLoad(state.selectedCategoryIndex),
      );
    }

    final rawItems = tab.services?.items ?? [];
    // The category endpoint has no search: filter loaded items locally.
    final query = state.searchQuery?.trim().toLowerCase() ?? '';
    final items = query.isEmpty
        ? rawItems
        : rawItems.where((s) {
            final name = (s.serviceName as String?)?.toLowerCase() ?? '';
            return name.contains(query);
          }).toList();

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'provider_page.no_services_found'.tr(),
            style: AppTextStyles.of(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    // Plain Column (not a nested shrink-wrap ListView) so the list takes
    // exactly its children's height — no phantom gap above the cards.
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          CategoryServiceCard(service: items[i], categoryId: tab.categoryId),
          if (i < items.length - 1) SizedBox(height: 12.h),
        ],
        if (tab.hasMore && query.isEmpty) ...[
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: tab.isLoading
                ? null
                : () => cubit.loadMoreCategoryServices(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3872B1),
              side: const BorderSide(color: Color(0xFF3872B1)),
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
        ],
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
      return const Center(child: CircularProgressIndicator());
    }
    if (state.packagesError != null) {
      return ErrorStateWidget(
        error: state.packagesError!,
        onRetry: () => cubit.loadPackages(reset: true),
      );
    }
    if (state.packages.isEmpty) {
      return Center(child: Text('provider_page.no_packages_found'.tr()));
    }
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.78,
          ),
          itemCount: state.packages.length,
          itemBuilder: (context, index) {
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
          },
        ),
        if (state.isPackagesLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (state.reviewsError != null) {
      return ErrorStateWidget(
        error: state.reviewsError!,
        onRetry: () => cubit.loadReviews(reset: true),
      );
    }
    if (state.reviews.isEmpty) {
      return Center(child: Text('provider_page.no_reviews_found'.tr()));
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.reviews.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return ProviderReviewCard(review: state.reviews[index]);
          },
        ),
        if (state.isReviewsLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
