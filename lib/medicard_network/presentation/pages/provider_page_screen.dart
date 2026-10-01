import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import '../widgets/provider_cart_bar.dart';
import '../widgets/provider_content_section.dart';
import '../widgets/provider_search_row.dart';
import '../widgets/provider_top_header.dart';


class ProviderPageScreen extends StatefulWidget {
  final int providerId;

  const ProviderPageScreen({super.key, required this.providerId});

  @override
  State<ProviderPageScreen> createState() => _ProviderPageScreenState();
}

class _ProviderPageScreenState extends State<ProviderPageScreen> {
  ProviderBranch? _selectedBranch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ProviderPageCubit>(param1: widget.providerId)..init(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        // Scoped rebuilds: the shell itself never rebuilds on cubit emits.
        // Each section below owns its rebuild scope (see widgets/).
        body: BlocSelector<ProviderPageCubit, ProviderPageState, bool>(
          selector: (state) =>
              state.currentView == ProviderViewType.reviews,
          builder: (context, isReviews) {
            final cubit = context.read<ProviderPageCubit>();
            return PopScope(
              canPop: !isReviews,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop &&
                    cubit.state.currentView == ProviderViewType.reviews) {
                  cubit.switchView(cubit.state.catalogView);
                }
              },
              child: Column(
                children: [
                  ProviderTopHeader(
                    selectedBranch: _selectedBranch,
                    onBranchTap: _openBranchSelector,
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) =>
                          _handleScrollNotification(
                            scrollInfo,
                            cubit.state,
                            cubit,
                          ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            children: [
                              const ProviderSearchRow(),
                              ProviderContentSection(
                                selectedBranch: _selectedBranch,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ProviderCartBar(
                    providerId: widget.providerId,
                    selectedBranch: _selectedBranch,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _handleScrollNotification(
    ScrollNotification scrollInfo,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    if (scrollInfo is! ScrollUpdateNotification) return false;
    if (scrollInfo.metrics.pixels <
        scrollInfo.metrics.maxScrollExtent - 200) {
      return false;
    }
    switch (state.currentView) {
      case ProviderViewType.services:
        if (!state.isServicesLoadingMore && state.servicesHasMore) {
          cubit.loadMoreServices();
        }
        return false;
      case ProviderViewType.packages:
        if (!state.isPackagesLoadingMore && state.packagesHasMore) {
          cubit.loadMorePackages();
        }
        return false;
      case ProviderViewType.reviews:
        if (!state.isReviewsLoadingMore && state.reviewsHasMore) {
          cubit.loadMoreReviews();
        }
        return false;
    }
  }

  void _openBranchSelector(List<ProviderBranch>? branches) async {
    if (branches == null || branches.isEmpty) return;
    final selected = await context.push<ProviderBranch>(
      '/provider-branches',
      extra: branches,
    );
    if (selected != null && mounted) {
      setState(() => _selectedBranch = selected);
    }
  }
}
