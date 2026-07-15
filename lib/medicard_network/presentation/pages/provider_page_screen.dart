import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';

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
        body: BlocBuilder<ProviderPageCubit, ProviderPageState>(
          builder: (context, state) {
            final cubit = context.read<ProviderPageCubit>();
            return Column(
              children: [
                _buildTopBlueHeader(context, state, cubit),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          _buildSearchAndFilterRow(context, state, cubit),
                          SizedBox(height: 16.h),
                          _buildContentSection(context, state, cubit),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.getCartItemCount() > 0)
                  _buildViewCartBar(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewCartBar(BuildContext context, ProviderPageState state) {
    return GestureDetector(
      onTap: () => context.push('/cart'),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3872B1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${state.getCartItemCount()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'View Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${state.calculateTotalPrice().toStringAsFixed(0)} EGP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBlueHeader(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    return AppBlueHeader(
      onBack: () => context.pop(),
      bottomChild: state.isProviderLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : state.providerData != null
          ? _ProviderInfoRow(
              data: state.providerData!,
              selectedBranch: _selectedBranch,
              onBranchTap: () =>
                  _openBranchSelector(state.providerData!.branches),
              onRatingTap: () => context.push(
                '/provider-reviews',
                extra: {'providerName': state.providerData!.providerName},
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSearchAndFilterRow(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (query) => cubit.updateSearchQuery(query),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Test',
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 14.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProviderViewType>(
              value: state.currentView,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
                size: 18,
              ),
              isDense: true,
              items: [
                DropdownMenuItem(
                  value: ProviderViewType.services,
                  child: Text(
                    'Services',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ProviderViewType.packages,
                  child: Text(
                    'Packages',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              onChanged: (newValue) async {
                if (newValue != null) {
                  await cubit.switchView(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    if (state.currentView == ProviderViewType.services) {
      return _buildCategoryTabsSection(context, state, cubit);
    } else {
      return _buildPackagesListSection(context, state, cubit);
    }
  }

  // ── Category Tabs + Services ───────────────────────────────────────────────

  Widget _buildCategoryTabsSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    if (state.isProviderLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.categoryTabs.isEmpty) {
      return Center(
        child: Text(
          'provider_page.no_services_found'.tr(),
          style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tab chips row ──────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(state.categoryTabs.length, (i) {
              final tab = state.categoryTabs[i];
              final isSelected = i == state.selectedCategoryIndex;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 10.w),
                child: _CategoryTabChip(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => cubit.selectCategoryTab(i),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 16.h),

        // ── Services for selected tab ──────────────────────────────────────
        _buildTabServicesBody(context, state, cubit),
      ],
    );
  }

  Widget _buildTabServicesBody(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    final tab = state.selectedTab;

    if (tab == null || tab.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
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

    final items = tab.services?.items ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'provider_page.no_services_found'.tr(),
            style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final service = items[index];
        final isPending = state.pendingCartActionIds.contains(
          service.serviceId,
        );
        final isInCart = state.isServiceInCart(service.serviceId);
        return _buildCategoryServiceCard(
          context,
          service,
          isPending,
          isInCart,
          cubit,
        );
      },
    );
  }

  Widget _buildCategoryServiceCard(
    BuildContext context,
    categoryService,
    bool isPending,
    bool isInCart,
    ProviderPageCubit cubit,
  ) {
    final serviceId = (categoryService as dynamic).serviceId as int;
    final serviceName = categoryService.serviceName as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isInCart
              ? const Color(0xFF3872B1).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // ── Service info ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (isInCart) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14.sp,
                        color: const Color(0xFF3872B1),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Added to cart',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF3872B1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // ── Action button ─────────────────────────────────────────────────
          if (isPending)
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF3872B1),
              ),
            )
          else if (isInCart)
            GestureDetector(
              onTap: () => cubit.removeFromCart(serviceId),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => cubit.addToCart(serviceId),
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3872B1),
                    width: 1.2,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Color(0xFF3872B1), size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackagesListSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
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
      return Center(child: Text('No packages found'.tr()));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            if (state.isPackagesLoadingMore || !state.packagesHasMore) {
              return false;
            }
            cubit.loadMorePackages();
          }
        }
        return false;
      },
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: state.packages.length,
            itemBuilder: (context, index) {
              return _buildPackageCard(
                context,
                state,
                cubit,
                state.packages[index],
              );
            },
          ),
          if (state.isPackagesLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
    ProviderPackage packageData,
  ) {
    final packageId = packageData.id;
    final isExpanded =
        packageId != null && state.expandedPackageIds.contains(packageId);
    final isLoading =
        packageId != null && state.loadingPackageDetailsIds.contains(packageId);
    final details = packageId == null
        ? null
        : state.packageDetailsById[packageId];
    final error = packageId == null
        ? null
        : state.packageDetailsErrors[packageId];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: packageId == null
            ? null
            : () => cubit.togglePackageDetails(packageId),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: packageData.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF3872B1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF3872B1),
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: isExpanded ? 3 : 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageData.name ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (packageData.priceBefore != null)
                          Flexible(
                            child: Text(
                              '${packageData.priceBefore} EGP',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (packageData.priceAfter != null)
                          Flexible(
                            child: Text(
                              '${packageData.priceAfter} EGP',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3872B1),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    if (isExpanded) ...[
                      SizedBox(height: 8.h),
                      if (isLoading)
                        const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (error != null)
                        Text(
                          error,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFFEF4444),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        _PackageServiceNames(
                          serviceNames: details?.serviceNames ?? const [],
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

// ── Provider info row (used inside AppBlueHeader's bottomChild) ───────────────

class _ProviderInfoRow extends StatelessWidget {
  final ProviderPageData data;
  final ProviderBranch? selectedBranch;
  final VoidCallback onBranchTap;
  final VoidCallback onRatingTap;

  const _ProviderInfoRow({
    required this.data,
    required this.selectedBranch,
    required this.onBranchTap,
    required this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Logo ────────────────────────────────────────────────────────────
        Container(
          width: 76.w,
          height: 76.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(8.r),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: data.providerLogo,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) =>
                  const Icon(Icons.local_hospital, color: Color(0xFF3872B1)),
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // ── Name + branch + stats ────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.providerName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: onBranchTap,
                child: Text(
                  selectedBranch?.branchName ??
                      'provider_page.select_branch'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withAlpha(230),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.layers_outlined,
                    color: Colors.white70,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${data.servicesCount ?? 0} Services',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  if (data.phones != null && data.phones!.isNotEmpty) ...[
                    SizedBox(width: 14.w),
                    Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.white70,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      data.phones!.first,
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ── Rating badge ─────────────────────────────────────────────────────
        if (data.rating != null)
          GestureDetector(
            onTap: onRatingTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFF5A623),
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${data.rating} (${data.reviewsCount ?? 0})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PackageServiceNames extends StatelessWidget {
  final List<String> serviceNames;

  const _PackageServiceNames({required this.serviceNames});

  @override
  Widget build(BuildContext context) {
    if (serviceNames.isEmpty) {
      return Text(
        'No services found',
        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: serviceNames.take(3).map((name) {
        return Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 11.sp,
                color: const Color(0xFF22C55E),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Category Tab Chip widget ──────────────────────────────────────────────────

/// A tappable chip for a category tab.
/// Shows a blue badge with [CategoryTab.selectedCount] when > 0.
class _CategoryTabChip extends StatelessWidget {
  final CategoryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTabChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Chip body ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3872B1)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: const Color(0xFF3872B1),
                width: isSelected ? 0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3872B1).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading spinner while services are being fetched.
                if (tab.isLoading) ...[
                  SizedBox(
                    width: 12.r,
                    height: 12.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3872B1),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  tab.categoryName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF3872B1),
                  ),
                ),
              ],
            ),
          ),

          // ── Badge (selected count) ─────────────────────────────────────
          if (tab.selectedCount > 0)
            Positioned(
              top: -6.h,
              right: -6.w,
              child: Container(
                constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: tab.selectedCount > 9
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: tab.selectedCount > 9
                      ? BorderRadius.circular(9.r)
                      : null,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${tab.selectedCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
