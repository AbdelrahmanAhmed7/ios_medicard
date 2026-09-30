import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../network/data/provider_page_response_model.dart';

import '../../../core/theming/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final value = _searchController.text;
      if (value != _query) setState(() => _query = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProviderBranch> get _filteredBranches {
    if (_query.trim().isEmpty) return widget.branches;
    final lower = _query.toLowerCase();
    return widget.branches.where((b) {
      return b.branchName.toLowerCase().contains(lower) ||
          (b.fullAddress?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBranches;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildBlueHeader(context),
          // Search field
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.of(fontSize: 14.sp, color: Colors.black),
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              decoration: InputDecoration(
                hintText: 'provider_page.search_branches'.tr(),
                hintStyle: AppTextStyles.of(
                  fontSize: 13.sp,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 18.sp,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2D5FA6)),
                ),
              ),
            ),
          ),

          // Results count
          if (_query.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'provider_page.branches_found'.tr(args: ['${filtered.length}']),
                  style: AppTextStyles.of(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),

          // Branches list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52.r,
                            color: const Color(0xFFD1D5DB),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'provider_page.no_branches_found'.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.of(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    itemCount: filtered.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) => _BranchCard(
                      branch: filtered[index],
                      onTap: () => context.pop(filtered[index]),
                    ),
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
                    style: AppTextStyles.of(
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
                    style: AppTextStyles.of(
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
}

class _BranchCard extends StatelessWidget {
  final ProviderBranch branch;
  final VoidCallback onTap;

  const _BranchCard({required this.branch, required this.onTap});

  Future<void> _openMap() async {
    if (branch.mapsUrl != null && branch.mapsUrl!.trim().isNotEmpty) {
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
            Text(
              branch.branchName,
              style: AppTextStyles.of(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                      style: AppTextStyles.of(
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
                      style: AppTextStyles.of(
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
