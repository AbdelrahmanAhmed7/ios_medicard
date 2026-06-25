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
import '../../core/network_colors.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'branches_screen.dart';

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
      create: (context) => sl<ProviderPageCubit>(param1: widget.providerId)..init(),
      child: Scaffold(
        backgroundColor: NC.bg,
        body: BlocBuilder<ProviderPageCubit, ProviderPageState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, state),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 80.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(context, state),
                        SizedBox(height: 16.h),
                        _buildBranchSelector(context, state),
                        SizedBox(height: 16.h),
                        _buildServicesSection(context, state),
                      ],
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

  Widget _buildAppBar(BuildContext context, ProviderPageState state) {
    return state.maybeWhen(
      providerSuccess: (data) => SliverAppBar(
        expandedHeight: 160.h,
        pinned: true,
        stretch: true,
        backgroundColor: NC.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 14.h, left: 48.w, right: 48.w),
          title: Text(
            data.providerName,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [NC.primary, Color(0xFF4A90D9)],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20.h),
                    _buildHeroLogo(data.providerLogo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      orElse: () => SliverAppBar(
        backgroundColor: NC.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }

  Widget _buildHeroLogo(String logoUrl) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17.r),
        child: logoUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: logoUrl, fit: BoxFit.cover)
            : const Icon(Icons.local_hospital, color: NC.primary),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ProviderPageState state) {
    return state.maybeWhen(
      providerLoading: () => const _Card(child: Center(child: CircularProgressIndicator())),
      providerSuccess: (data) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.providerName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (data.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        data.rating.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                if (data.reviewsCount != null)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Text(
                      '(${data.reviewsCount}) ${'provider_page.reviews'.tr()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: NC.textLight,
                      ),
                    ),
                  ),
              ],
            ),
            if (data.phones != null && data.phones!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: NC.success, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      data.phones!.first,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (data.servicesCount != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: NC.primaryMid, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      '${data.servicesCount} ${'provider_page.total_services'.tr()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      providerFailed: (error) => _Card(
        child: ErrorStateWidget(
          error: error,
          onRetry: () => context.read<ProviderPageCubit>().loadProviderPage(),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBranchSelector(BuildContext context, ProviderPageState state) {
    return state.maybeWhen(
      providerSuccess: (data) {
        if (data.branches == null || data.branches!.isEmpty) {
          return const SizedBox.shrink();
        }
        return _Card(
          child: GestureDetector(
            onTap: () async {
              final selected = await context.push<ProviderBranch>(
                '/provider-branches',
                extra: data.branches,
              );
              if (selected != null && mounted) {
                setState(() {
                  _selectedBranch = selected;
                });
              }
            },
            child: Row(
              children: [
                Icon(Icons.location_on, color: NC.primaryMid, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'provider_page.select_branch'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: NC.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedBranch != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            _selectedBranch!.branchName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: NC.textLight, size: 16.sp),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildServicesSection(BuildContext context, ProviderPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'provider_page.services'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          decoration: InputDecoration(
            hintText: 'provider_page.search_services'.tr(),
            prefixIcon: Icon(Icons.search, color: NC.textLight),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: NC.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: NC.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: NC.primaryMid),
            ),
          ),
          onChanged: (query) => context.read<ProviderPageCubit>().updateSearchQuery(query),
        ),
        SizedBox(height: 12.h),
        state.maybeWhen(
          servicesLoading: () => const Center(child: CircularProgressIndicator()),
          servicesSuccess: (services, hasMore, isLoadingMore) {
            if (services.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text('provider_page.no_services_found'.tr()),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                    if (isLoadingMore || !hasMore) return false;
                    context.read<ProviderPageCubit>().loadMoreServices();
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
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            );
          },
          servicesFailed: (error) => ErrorStateWidget(
            error: error,
            onRetry: () => context.read<ProviderPageCubit>().loadServices(reset: true),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(ProviderService service) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.hasSpecialOffer == true)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: NC.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: NC.danger.withValues(alpha: 0.2)),
              ),
              child: Text(
                'provider_page.special_offer'.tr(),
                style: TextStyle(
                  color: NC.danger,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          SizedBox(height: 8.h),
          Text(
            service.serviceName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (service.priceBefore != null)
                Text(
                  '${service.priceBefore} EGP',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: NC.textLight,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              SizedBox(width: 8.w),
              if (service.priceAfter != null)
                Text(
                  '${service.priceAfter} EGP',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: NC.success,
                  ),
                ),
              const Spacer(),
              if (service.discountPercentage != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: NC.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: NC.success.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '-${service.discountPercentage}%',
                    style: TextStyle(
                      color: NC.success,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: NC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
