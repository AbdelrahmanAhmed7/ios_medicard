import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../network/data/provider_page_response_model.dart';

class BranchesScreen extends StatelessWidget {
  final List<ProviderBranch> branches;
  final String? providerName;

  const BranchesScreen({
    super.key,
    required this.branches,
    this.providerName = 'Alfa',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildBlueHeader(context),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: branches.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final branch = branches[index];
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
                    providerName ?? '',
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
              style: TextStyle(
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
