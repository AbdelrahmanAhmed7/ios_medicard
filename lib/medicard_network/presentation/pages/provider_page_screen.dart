import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/error_state_widget.dart';
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
                          _buildSearchAndFilterRow(context, cubit),
                          SizedBox(height: 16.h),
                          _buildContentSection(context, state, cubit),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBlueHeader(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    final providerData = cubit.providerData;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2D5FA6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 16.h),
              if (providerData != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                          imageUrl: providerData.providerLogo,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.local_hospital,
                            color: Color(0xFF2D5FA6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerData.providerName,
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
                            onTap: () =>
                                _openBranchSelector(providerData.branches),
                            child: Text(
                              _selectedBranch?.branchName ??
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
                                '${providerData.servicesCount ?? 0} Services',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              if (providerData.phones != null &&
                                  providerData.phones!.isNotEmpty) ...[
                                Icon(
                                  Icons.phone_in_talk_rounded,
                                  color: Colors.white70,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  providerData.phones!.first,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (providerData.rating != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
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
                              '${providerData.rating} (${providerData.reviewsCount ?? 0})',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(
    BuildContext context,
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
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14.sp,
                ),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
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
              value: cubit.currentView,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 14.sp,
              ),
              items: const [
                DropdownMenuItem(
                  value: ProviderViewType.services,
                  child: Text('Services'),
                ),
                DropdownMenuItem(
                  value: ProviderViewType.packages,
                  child: Text('Packages'),
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
    if (cubit.currentView == ProviderViewType.services) {
      return _buildServicesListSection(context, state, cubit);
    } else {
      return _buildPackagesListSection(context, state, cubit);
    }
  }

  Widget _buildServicesListSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    return state.maybeWhen(
      servicesLoading: () => const Center(child: CircularProgressIndicator()),
      servicesSuccess: (services, hasMore, isLoadingMore) {
        if (services.isEmpty) {
          return Center(child: Text('provider_page.no_services_found'.tr()));
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                if (isLoadingMore || !hasMore) return false;
                cubit.loadMoreServices();
              }
            }
            return false;
          },
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index == services.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _buildResponsiveServiceCard(services[index]);
            },
          ),
        );
      },
      servicesFailed: (error) => ErrorStateWidget(
        error: error,
        onRetry: () => cubit.loadServices(reset: true),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildPackagesListSection(
    BuildContext context,
    ProviderPageState state,
    ProviderPageCubit cubit,
  ) {
    return state.maybeWhen(
      packagesLoading: () => const Center(child: CircularProgressIndicator()),
      packagesSuccess: (packages, hasMore, isLoadingMore) {
        if (packages.isEmpty) {
          return Center(child: Text('No packages found'.tr()));
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
                if (isLoadingMore || !hasMore) return false;
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
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  return _buildPackageCard(packages[index]);
                },
              ),
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
      packagesFailed: (error) => ErrorStateWidget(
        error: error,
        onRetry: () => cubit.loadPackages(reset: true),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildResponsiveServiceCard(ProviderService service) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.serviceName ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFFD97706),
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'No Fasting',
                      style: TextStyle(
                        color: const Color(0xFFD97706),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (service.discountPercentage != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${service.discountPercentage}% Off',
                    style: TextStyle(
                      color: const Color(0xFF0284C7),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Full haematology panel including WBC, RBC, platelets',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (service.priceBefore != null)
                Text(
                  '${service.priceBefore} EGP',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              SizedBox(width: 10.w),
              if (service.priceAfter != null)
                Text(
                  '${service.priceAfter} EGP',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D5FA6),
                  ),
                ),
              const Spacer(),
              Icon(
                Icons.add_circle_outline_rounded,
                color: const Color(0xFF2D5FA6),
                size: 26.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(ProviderPackage packageData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                      color: Color(0xFF2D5FA6),
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
                      Icons.add_circle_outline_rounded,
                      color: const Color(0xFF2D5FA6),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
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
                              color: const Color(0xFF2D5FA6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      setState(() {
        _selectedBranch = selected;
      });
    }
  }
}
