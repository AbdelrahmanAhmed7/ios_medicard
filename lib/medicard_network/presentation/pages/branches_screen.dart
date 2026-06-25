import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../core/network_colors.dart';

class BranchesScreen extends StatelessWidget {
  final List<ProviderBranch> branches;

  const BranchesScreen({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.bg,
      appBar: AppBar(
        title: Text('provider_page.branches'.tr()),
        backgroundColor: NC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: branches.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final branch = branches[index];
          return _BranchCard(
            branch: branch,
            onTap: () => context.pop(branch),
          );
        },
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final ProviderBranch branch;
  final VoidCallback onTap;

  const _BranchCard({required this.branch, required this.onTap});

  Future<void> _callPhone(String? phone) async {
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap() async {
    if (branch.mapsUrl != null) {
      final uri = Uri.parse(branch.mapsUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (branch.latitude != null && branch.longitude != null) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${branch.latitude},${branch.longitude}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.branchName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 12.h),
            if (branch.phone != null)
              GestureDetector(
                onTap: () => _callPhone(branch.phone),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: NC.success, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      branch.phone!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: NC.success,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
            if (branch.fullAddress != null)
              GestureDetector(
                onTap: _openMap,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: NC.primaryMid, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        branch.fullAddress!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
