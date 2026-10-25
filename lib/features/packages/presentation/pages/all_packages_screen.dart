import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_result.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../medicard_network/repository/medicard_network_repository.dart';
import '../../../../network/data/all_packages_models.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../../../medicard_network/presentation/widgets/provider_package_card.dart';

/// Full packages catalog (`GET Package`, paged). Tapping a card opens its
/// provider page, where booking happens with proper branch context.
class AllPackagesScreen extends StatefulWidget {
  const AllPackagesScreen({super.key});

  @override
  State<AllPackagesScreen> createState() => _AllPackagesScreenState();
}

class _AllPackagesScreenState extends State<AllPackagesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final List<AllPackage> _items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  String? get _query {
    final text = _searchController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _load(reset: true);
    });
  }

  void _openPackage(BuildContext context, AllPackage item) {
    final packageId = item.id;
    final providerId = item.providerId;
    if (packageId == null || providerId == null) return;
    context.push(
      '/provider-page',
      extra: {'providerId': providerId, 'autoOpenPackageId': packageId},
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }
    final ApiResult<AllPackagesResponse> result =
        await sl<MedicardNetworkRepository>().getAllPackages(
          pageNumber: _page,
          pageSize: 15,
          search: _query,
        );
    if (!mounted) return;
    result.when(
      success: (response) {
        final data = response.data;
        final newItems = data?.items ?? const <AllPackage>[];
        final totalPages = data?.totalPages ?? _page;
        setState(() {
          if (reset) _items.clear();
          _items.addAll(newItems);
          _hasMore = _page < totalPages;
          if (_hasMore) _page++;
          _isLoading = false;
          _isLoadingMore = false;
        });
      },
      failure: (message) {
        if (!mounted) return;
        setState(() {
          _error = message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: AppHeaderSpacing.padding(top: 10.h, bottom: 6.h),
              child: Row(
                children: [
                  AppHeaderBackButton(
                    color: const Color(0xFF111827),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'home.packages'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.of(
                fontSize: 14.sp,
                color: const Color(0xFF1A1A2E),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                hintText: 'search.search_packages_hint'.tr(),
                hintStyle: AppTextStyles.of(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 13.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(isArabic)),
        ],
      ),
    );
  }

  Widget _buildBody(bool isArabic) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      );
    }
    if (_error != null && _items.isEmpty) {
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
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => _load(reset: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3872B1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'common.retry'.tr(),
                  style: AppTextStyles.of(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'home.no_data_available'.tr(),
          style: AppTextStyles.of(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF3872B1),
      onRefresh: () => _load(reset: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = 8.w;
          final crossAxisSpacing = 12.w;
          final cardWidth =
              (constraints.maxWidth -
                  horizontalPadding * 2 -
                  crossAxisSpacing) /
              2;
          return GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12.h,
              horizontalPadding,
              24.h,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: 12.h,
              mainAxisExtent: ProviderPackageCard.preferredHeightForWidth(
                cardWidth,
              ),
            ),
            itemCount: _items.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _items.length) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                );
              }
              final item = _items[index];
              return ProviderPackageCard(
                packageData: ProviderPackage(
                  id: item.id,
                  name: item.name,
                  providerId: item.providerId,
                  providerNameAr: item.providerNameAr,
                  providerNameEn: item.providerNameEn,
                  imageUrl: item.image,
                  description: item.description,
                  priceBefore: item.priceBefore,
                  priceAfter: item.priceAfter,
                  discountPercentage: item.discountPercentage,
                  serviceNames: item.serviceNames,
                  servicesCount: (item.serviceNames ?? const []).length,
                ),
                onDetailsTap: item.id == null || item.providerId == null
                    ? null
                    : () => _openPackage(context, item),
                onQuickAdd: null,
              );
            },
          );
        },
      ),
    );
  }
}
