import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_session_storage.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../../../network/data/provider_services_response_model.dart';
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
            final isReviews = state.currentView == ProviderViewType.reviews;
            return PopScope(
              canPop: !isReviews,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && isReviews) {
                  cubit.switchView(state.catalogView);
                }
              },
              child: Column(
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
                            if (!isReviews) ...[
                              _buildSearchAndFilterRow(context, state, cubit),
                              SizedBox(height: 16.h),
                            ],
                            _buildContentSection(context, state, cubit),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (state.getCartItemCount() > 0)
                    SafeArea(
                      top: false,
                      minimum: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                      child: _buildViewCartBar(context, state),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildViewCartBar(BuildContext context, ProviderPageState state) {
    return GestureDetector(
      onTap: () async {
        final token = await sl<AuthSessionStorage>().getAccessToken();
        if (!context.mounted) return;
        if (token == null || token.isEmpty) {
          showLoginRequiredMessage(context);
          return;
        }
        context.push(
          '/cart',
          extra: {
            'providerId': widget.providerId,
            'selectedBranch': _selectedBranch,
          },
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
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
                'cart.view_cart'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18.sp,
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
      onBack: () {
        if (state.currentView == ProviderViewType.reviews) {
          cubit.switchView(state.catalogView);
        } else {
          context.pop();
        }
      },
      bottomChild: state.isProviderLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : state.providerData != null
          ? _ProviderInfoRow(
              data: state.providerData!,
              servicesCount: state.displayServicesCount,
              selectedBranch: _selectedBranch,
              onBranchTap: () =>
                  _openBranchSelector(state.providerData!.branches),
              onRatingTap: () => cubit.switchView(ProviderViewType.reviews),
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
                hintText: 'provider_page.search_services'.tr(),
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
              // Catalog-only control. While reviews content is open, keep value
              // null so re-selecting Services/Packages can exit reviews.
              value: state.currentView == ProviderViewType.reviews
                  ? null
                  : state.catalogView,
              hint: Text(
                state.catalogView == ProviderViewType.packages
                    ? 'provider_page.packages'.tr()
                    : 'provider_page.services'.tr(),
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                    'provider_page.services'.tr(),
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
                    'provider_page.packages'.tr(),
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
    } else if (state.currentView == ProviderViewType.packages) {
      return _buildPackagesListSection(context, state, cubit);
    } else {
      return _buildReviewsListSection(context, state, cubit);
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
      return _buildProviderServicesBody(context, state, cubit);
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

  Widget _buildProviderServicesBody(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    if (state.isServicesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
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
            style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          if (!state.isServicesLoadingMore && state.servicesHasMore) {
            cubit.loadMoreServices();
          }
        }
        return false;
      },
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.services.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final service = state.services[index];
              final serviceId = service.id;
              final isPending =
                  serviceId != null &&
                  state.pendingCartActionIds.contains(serviceId);
              final isInCart = service.isSelected == true;
              return _buildProviderServiceCard(
                context,
                service,
                isPending,
                isInCart,
                cubit,
              );
            },
          ),
          if (state.isServicesLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
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
              onTap: () async {
                if (await cubit.addToCart(serviceId) && context.mounted) {
                  showLoginRequiredMessage(context);
                }
              },
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

  Widget _buildProviderServiceCard(
    BuildContext context,
    ProviderService service,
    bool isPending,
    bool isInCart,
    ProviderPageCubit cubit,
  ) {
    final serviceId = service.id;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isInCart
              ? const Color(0xFF3872B1).withValues(alpha: 0.4)
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: [
                    _ServiceBadge(
                      label: 'No Fasting',
                      color: const Color(0xFFFFA726),
                      backgroundColor: const Color(0xFFFFF3E0),
                      icon: Icons.access_time_rounded,
                    ),
                    if (service.discountPercentage != null &&
                        service.discountPercentage! > 0)
                      _ServiceBadge(
                        label:
                            '${service.discountPercentage!.toStringAsFixed(0)}%Off',
                        color: const Color(0xFF3872B1),
                        backgroundColor: const Color(0xFFEFF6FF),
                      ),
                  ],
                ),
                SizedBox(height: 9.h),
                Text(
                  'Full haematology panel including WBC, RBC, platelets',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF475569),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 13.h),
                Row(
                  children: [
                    if (service.priceBefore != null) ...[
                      Text(
                        '${_formatPrice(service.priceBefore)} EGP',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    if (service.priceAfter != null)
                      Text(
                        '${_formatPrice(service.priceAfter)} EGP',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F6BC1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          if (isPending)
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF3872B1),
              ),
            )
          else if (isInCart && serviceId != null)
            GestureDetector(
              onTap: () => cubit.removeFromCart(serviceId),
              child: Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF3872B1),
                size: 26.sp,
              ),
            )
          else
            GestureDetector(
              onTap: serviceId == null
                  ? null
                  : () async {
                      if (await cubit.addToCart(
                            serviceId,
                            categoryId: service.categoryId,
                          ) &&
                          context.mounted) {
                        showLoginRequiredMessage(context);
                      }
                    },
              child: Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3872B1),
                    width: 1.4,
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
      return Center(child: Text('provider_page.no_packages_found'.tr()));
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
              childAspectRatio: 0.78,
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

  Widget _buildReviewsListSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
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

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          if (!state.isReviewsLoadingMore && state.reviewsHasMore) {
            cubit.loadMoreReviews();
          }
        }
        return false;
      },
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reviews.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildReviewCard(state.reviews[index]);
            },
          ),
          if (state.isReviewsLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProviderReview review) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: review.userImageUrl ?? '',
              width: 42.r,
              height: 42.r,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Container(
                width: 42.r,
                height: 42.r,
                color: const Color(0xFFE2E8F0),
                child: const Icon(Icons.person, color: Color(0xFF64748B)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.userName ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (review.rating ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 15.sp,
                      color: const Color(0xFFF5A623),
                    );
                  }),
                ),
                if ((review.ratingText ?? '').isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    review.ratingText!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: packageId == null
            ? null
            : () => _openPackageDetailsSheet(context, cubit, packageData),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
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
                    top: 6.w,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: packageId == null
                          ? null
                          : () => _createPackageInvoice(
                              context,
                              cubit,
                              packageId,
                            ),
                      child: Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3872B1),
                            width: 1.3,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: const Color(0xFF3872B1),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageData.name ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (packageData.priceBefore != null)
                          Flexible(
                            child: Text(
                              '${_formatPrice(packageData.priceBefore)} EGP',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (packageData.priceAfter != null)
                          Text(
                            '${_formatPrice(packageData.priceAfter)} EGP',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F6BC1),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPackageInvoice(
    BuildContext context,
    ProviderPageCubit cubit,
    int packageId,
  ) async {
    final packageData = cubit.state.packages
        .where((package) => package.id == packageId)
        .firstOrNull;
    if (packageData == null) return;
    _openPackageCheckout(context, cubit.state, packageData);
  }

  Future<void> _openPackageCheckout(
    BuildContext context,
    ProviderPageState state,
    ProviderPackage packageData, {
    PackageDetailsData? details,
  }) async {
    final packageId = details?.id ?? packageData.id;
    if (packageId == null) return;

    final token = await sl<AuthSessionStorage>().getAccessToken();
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      showLoginRequiredMessage(context);
      return;
    }

    final branches = state.providerData?.branches;
    final branchId =
        _selectedBranch?.branchId ??
        ((branches != null && branches.isNotEmpty)
            ? branches.first.branchId
            : null);
    final branch =
        _selectedBranch ??
        ((branches != null && branches.isNotEmpty) ? branches.first : null);

    if (branchId == null || branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('provider_page.select_branch_first'.tr())),
      );
      return;
    }

    context.push(
      '/checkout',
      extra: {
        'providerId': widget.providerId,
        'selectedBranch': branch,
        'packageId': packageId,
        'packageName': details?.name ?? packageData.name,
        'packagePriceBefore': details?.priceBefore ?? packageData.priceBefore,
        'packagePriceAfter': details?.priceAfter ?? packageData.priceAfter,
      },
    );
  }

  void _openPackageDetailsSheet(
    BuildContext context,
    ProviderPageCubit cubit,
    ProviderPackage packageData,
  ) {
    final packageId = packageData.id;
    if (packageId == null) return;

    if (!cubit.state.packageDetailsById.containsKey(packageId) &&
        !cubit.state.loadingPackageDetailsIds.contains(packageId)) {
      cubit.togglePackageDetails(packageId);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ProviderPageCubit, ProviderPageState>(
            builder: (context, state) {
              final details = state.packageDetailsById[packageId];
              final isLoading = state.loadingPackageDetailsIds.contains(
                packageId,
              );
              final error = state.packageDetailsErrors[packageId];
              final imageUrl = _packageImageUrl(
                details?.image ?? packageData.imageUrl ?? '',
              );
              final name = details?.name ?? packageData.name ?? '';
              final description =
                  details?.description ?? packageData.description ?? '';
              final serviceNames = details?.serviceNames ?? const <String>[];
              final priceBefore =
                  details?.priceBefore ?? packageData.priceBefore;
              final priceAfter = details?.priceAfter ?? packageData.priceAfter;
              final discount =
                  details?.discountPercentage ?? packageData.discountPercentage;

              return DraggableScrollableSheet(
                initialChildSize: 0.64,
                minChildSize: 0.42,
                maxChildSize: 0.92,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 136.h,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const ColoredBox(
                                  color: Color(0xFFE2E8F0),
                                  child: Center(
                                    child: Icon(
                                      Icons.local_hospital,
                                      color: Color(0xFF3872B1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 9.h,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 132.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(99.r),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16.w,
                              right: 110.w,
                              bottom: 18.h,
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (discount != null && discount > 0)
                              Positioned(
                                right: 16.w,
                                bottom: 14.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7FFFA),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    'Save ${discount.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: const Color(0xFF16A99A),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
                          child: isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : error != null
                              ? Text(
                                  error,
                                  style: TextStyle(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 13.sp,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      description,
                                      style: TextStyle(
                                        color: const Color(0xFF4B5563),
                                        fontSize: 14.sp,
                                        height: 1.24,
                                      ),
                                    ),
                                    SizedBox(height: 28.h),
                                    Text(
                                      'Tests included',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 14.h),
                                    _PackagePlainServiceNames(
                                      serviceNames: serviceNames,
                                    ),
                                    SizedBox(height: 30.h),
                                    Row(
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            color: const Color(0xFF64748B),
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (priceBefore != null) ...[
                                          Text(
                                            '${_formatPrice(priceBefore)} EGP',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                        ],
                                        if (priceAfter != null)
                                          Text(
                                            '${_formatPrice(priceAfter)} EGP',
                                            style: TextStyle(
                                              color: const Color(0xFF1F6BC1),
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50.h,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                Navigator.of(context).pop();
                                                _openPackageCheckout(
                                                  this.context,
                                                  state,
                                                  packageData,
                                                  details: details,
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF3872B1,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(
                                            context,
                                          ).padding.bottom +
                                          16.h,
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '';
    return price % 1 == 0 ? price.toStringAsFixed(0) : price.toStringAsFixed(2);
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

  String _packageImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.startsWith('http')) return trimmed;
    final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (normalized.startsWith('uploads/')) {
      return 'https://medicard-api-v2.medicardeg.com/$normalized';
    }
    return 'https://medicard-api-v2.medicardeg.com/uploads/providers/$normalized';
  }
}

// ── Provider info row (used inside AppBlueHeader's bottomChild) ───────────────

class _ProviderInfoRow extends StatelessWidget {
  final ProviderPageData data;
  final int servicesCount;
  final ProviderBranch? selectedBranch;
  final VoidCallback onBranchTap;
  final VoidCallback onRatingTap;

  const _ProviderInfoRow({
    required this.data,
    required this.servicesCount,
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(34),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withAlpha(150)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          selectedBranch?.branchName ??
                              'provider_page.select_branch'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                    'provider_page.services_count'.tr(args: ['$servicesCount']),
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  if (data.phones != null && data.phones!.isNotEmpty) ...[
                    SizedBox(width: 14.w),
                    GestureDetector(
                      onTap: () =>
                          UrlLauncherService().makePhoneCall(data.phones!.first),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_in_talk_rounded,
                            color: Colors.white70,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            data.phones!.first,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
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

class PackageServiceNames extends StatelessWidget {
  final List<String> serviceNames;

  const PackageServiceNames({super.key, required this.serviceNames});

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
class _PackagePlainServiceNames extends StatelessWidget {
  final List<String> serviceNames;

  const _PackagePlainServiceNames({required this.serviceNames});

  @override
  Widget build(BuildContext context) {
    if (serviceNames.isEmpty) {
      return Text(
        'No services found',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(serviceNames.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text(
            '${index + 1}-${serviceNames[index]}',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF4B5563),
              height: 1.22,
            ),
          ),
        );
      }),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData? icon;

  const _ServiceBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: color),
            SizedBox(width: 3.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
