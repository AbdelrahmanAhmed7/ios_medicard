import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../network/data/provider_page_response_model.dart';

enum BranchSortMode { nameAsc, nameDesc, distanceAsc, distanceDesc }

class BranchesScreen extends StatefulWidget {
  final List<ProviderBranch> branches;
  final String? providerName;

  const BranchesScreen({
    super.key,
    required this.branches,
    this.providerName = 'Alfa',
  });

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  BranchSortMode _sortMode = BranchSortMode.nameAsc;

  bool get _hasDistanceData =>
      widget.branches.any((b) => b.distanceKm != null);

  List<ProviderBranch> get _filtered {
    final list = widget.branches.where((b) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return b.branchName.toLowerCase().contains(q) ||
          (b.fullAddress?.toLowerCase().contains(q) ?? false);
    }).toList();

    switch (_sortMode) {
      case BranchSortMode.nameAsc:
        list.sort(
          (a, b) => a.branchName.toLowerCase().compareTo(
            b.branchName.toLowerCase(),
          ),
        );
      case BranchSortMode.nameDesc:
        list.sort(
          (a, b) => b.branchName.toLowerCase().compareTo(
            a.branchName.toLowerCase(),
          ),
        );
      case BranchSortMode.distanceAsc:
        list.sort(
          (a, b) =>
              (a.distanceKm ?? double.infinity).compareTo(
                b.distanceKm ?? double.infinity,
              ),
        );
      case BranchSortMode.distanceDesc:
        list.sort(
          (a, b) =>
              (b.distanceKm ?? double.negativeInfinity).compareTo(
                a.distanceKm ?? double.negativeInfinity,
              ),
        );
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildBlueHeader(context),
          _buildSearchBar(),
          _buildSortBar(filtered.length),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    itemCount: filtered.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final branch = filtered[index];
                      return _BranchCard(
                        branch: branch,
                        onTap: () => context.pop(branch),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueHeader(BuildContext context) {
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
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
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
              Row(
                children: [
                  Text(
                    widget.providerName ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 12.sp,
                    ),
                  ),
                  Text(
                    'provider_page.branches'.tr(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v.trim()),
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: 'common.search'.tr(),
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF2D5FA6), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Row(
        children: [
          Text(
            'provider_page.branch_count'.tr(args: [count.toString()]),
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sort,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _sortLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _sortLabel {
    switch (_sortMode) {
      case BranchSortMode.nameAsc:
        return 'A → Z';
      case BranchSortMode.nameDesc:
        return 'Z → A';
      case BranchSortMode.distanceAsc:
        return 'provider_page.nearest'.tr();
      case BranchSortMode.distanceDesc:
        return 'provider_page.farthest'.tr();
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'provider_page.sort_by'.tr(),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                _sortTile(
                  label: 'A → Z',
                  mode: BranchSortMode.nameAsc,
                ),
                _sortTile(
                  label: 'Z → A',
                  mode: BranchSortMode.nameDesc,
                ),
                if (_hasDistanceData) ...[
                  _sortTile(
                    label: 'provider_page.nearest'.tr(),
                    mode: BranchSortMode.distanceAsc,
                  ),
                  _sortTile(
                    label: 'provider_page.farthest'.tr(),
                    mode: BranchSortMode.distanceDesc,
                  ),
                ],
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile({required String label, required BranchSortMode mode}) {
    final selected = _sortMode == mode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? const Color(0xFF2D5FA6) : const Color(0xFF374151),
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: Color(0xFF2D5FA6), size: 20)
          : null,
      onTap: () {
        setState(() => _sortMode = mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56.sp,
              color: const Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12.h),
            Text(
              'provider_page.no_branches_found'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final ProviderBranch branch;
  final VoidCallback onTap;

  const _BranchCard({required this.branch, required this.onTap});

  Future<void> _openMap() async {
    if (branch.mapsUrl != null) {
      final uri = Uri.parse(branch.mapsUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMap = branch.mapsUrl?.trim().isNotEmpty == true;
    final hasAddress = branch.fullAddress?.trim().isNotEmpty == true;
    final hasDistance = branch.distanceKm != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    branch.branchName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasDistance) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${branch.distanceKm!.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D5FA6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (hasAddress) ...[
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      branch.fullAddress!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (hasMap) ...[
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _openMap,
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: const Color(0xFF2D5FA6),
                      size: 15.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'provider_page.open_map'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D5FA6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
