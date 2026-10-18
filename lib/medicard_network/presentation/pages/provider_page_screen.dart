import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import '../widgets/provider_content_section.dart';
import '../widgets/provider_search_row.dart';
import '../widgets/provider_top_header.dart';
import '../widgets/package_details_sheet.dart';

class ProviderPageScreen extends StatefulWidget {
  final int providerId;

  /// When set (notification deep-link), the package sheet opens
  /// automatically once the page data is ready.
  final int? autoOpenPackageId;

  const ProviderPageScreen({
    super.key,
    required this.providerId,
    this.autoOpenPackageId,
  });

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
        backgroundColor: Colors.white,
        // Scoped rebuilds: the shell itself never rebuilds on cubit emits.
        // Each section below owns its rebuild scope (see widgets/).
        body: SafeArea(
          bottom: false,
          child: BlocSelector<ProviderPageCubit, ProviderPageState, bool>(
            selector: (state) => state.currentView == ProviderViewType.reviews,
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
                    if (widget.autoOpenPackageId != null)
                      _AutoOpenPackage(
                        packageId: widget.autoOpenPackageId!,
                        selectedBranch: _selectedBranch,
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
                          child: Column(
                            children: [
                              ProviderTopHeader(
                                selectedBranch: _selectedBranch,
                                onBranchTap: _openBranchSelector,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  12.h,
                                  16.w,
                                  16.h,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
    if (scrollInfo.metrics.pixels < scrollInfo.metrics.maxScrollExtent - 200) {
      return false;
    }
    switch (state.currentView) {
      case ProviderViewType.services:
        if (state.categoryTabs.isNotEmpty) {
          cubit.loadMoreCategoryServices();
        } else if (!state.isServicesLoadingMore && state.servicesHasMore) {
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

  void _openBranchSelector(
    List<ProviderBranch>? branches,
    String? providerName,
  ) async {
    if (branches == null || branches.isEmpty) return;
    final selected = await context.push<ProviderBranch>(
      '/provider-branches',
      extra: {'branches': branches, 'providerName': providerName},
    );
    if (selected != null && mounted) {
      setState(() => _selectedBranch = selected);
    }
  }
}

/// Opens a package sheet automatically once (notification deep-link).
/// Loads the provider packages (a few pages max) and opens the sheet for
/// [packageId]; silently gives up and leaves the user on the provider page
/// when the package isn't found.
class _AutoOpenPackage extends StatefulWidget {
  final int packageId;
  final ProviderBranch? selectedBranch;

  const _AutoOpenPackage({required this.packageId, this.selectedBranch});

  @override
  State<_AutoOpenPackage> createState() => _AutoOpenPackageState();
}

class _AutoOpenPackageState extends State<_AutoOpenPackage> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    if (!mounted) return;
    final cubit = context.read<ProviderPageCubit>();
    // Wait for the provider header data (loaded by the screen's init).
    for (var i = 0; i < 40 && mounted; i++) {
      final state = cubit.state;
      if (state.providerData != null || state.providerError != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!mounted || _done) return;
    if (cubit.state.providerData == null) return;
    _done = true;
    await cubit.loadPackages(reset: true);
    for (var page = 0; page < 3; page++) {
      if (!mounted) return;
      final found = cubit.state.packages
          .where((p) => p.id == widget.packageId)
          .firstOrNull;
      if (found != null) {
        if (!mounted) return;
        openPackageDetailsSheet(context, cubit, found, widget.selectedBranch);
        return;
      }
      if (!cubit.state.packagesHasMore) return;
      await cubit.loadPackages();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
