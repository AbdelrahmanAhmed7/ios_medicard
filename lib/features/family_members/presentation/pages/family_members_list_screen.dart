import 'package:medicard/core/widgets/app_simple_header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/image_url_resolver.dart';
import 'package:medicard/core/utils/relation_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../data/models/family_member_model.dart';
import '../cubit/family_members_cubit.dart';
import '../cubit/family_members_state.dart';

import '../../../../core/theming/app_text_styles.dart';

import 'package:medicard/core/theming/app_colors.dart';
class FamilyMembersListScreen extends StatefulWidget {
  const FamilyMembersListScreen({super.key});

  @override
  State<FamilyMembersListScreen> createState() =>
      _FamilyMembersListScreenState();
}

class _FamilyMembersListScreenState extends State<FamilyMembersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteClr,
      body: Column(
        children: [
          AppSimpleHeader(title: 'family_members.title'.tr()),
          Expanded(
            child: BlocConsumer<FamilyMembersCubit, FamilyMembersState>(
              listener: (context, state) {
                state.maybeWhen(orElse: () {});
              },
              builder: (context, state) {
                return state.when(
                  initial: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<FamilyMembersCubit>().loadFamilyMembers();
                    });
                    return const Center(child: CircularProgressIndicator());
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (members) {
                    return Column(
                      children: [
                        Expanded(
                          child: members.isEmpty
                              ? _buildEmptyState(context)
                              : RefreshIndicator(
                                  onRefresh: () => context
                                      .read<FamilyMembersCubit>()
                                      .loadFamilyMembers(),
                                  child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    itemCount: members.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            14.w,
                                            14.h,
                                            14.w,
                                            10.h,
                                          ),
                                          child: Text(
                                            'family_members.covered_members'
                                                .tr()
                                                .toUpperCase(),
                                            style: AppTextStyles.of(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                              color: AppColors.exactFF657293,
                                            ),
                                          ),
                                        );
                                      }
                                      return _FamilyMemberListItem(
                                        member: members[index - 1],
                                      );
                                    },
                                  ),
                                ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: AuthPrimaryButton(
                              label: 'family_members.add_member'.tr(),
                              isLoading: false,
                              onPressed: () {
                                if (members.length >= kMaxFamilyMembers) {
                                  showWarningToast(
                                    'family_members.max_limit_reached'.tr(
                                      args: ['$kMaxFamilyMembers'],
                                    ),
                                  );
                                  return;
                                }
                                context.push(
                                  '/family-members/add',
                                  extra: context.read<FamilyMembersCubit>(),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  failed: (error) => ErrorStateWidget(
                    error: error,
                    onRetry: () {
                      context.read<FamilyMembersCubit>().loadFamilyMembers();
                    },
                  ),
                  creating: () =>
                      const Center(child: CircularProgressIndicator()),
                  created: () => const SizedBox.shrink(),
                  updating: () =>
                      const Center(child: CircularProgressIndicator()),
                  updated: () => const SizedBox.shrink(),
                  deleting: () =>
                      const Center(child: CircularProgressIndicator()),
                  deleted: () => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80.sp, color: AppColors.greyClr),
          SizedBox(height: 16.h),
          Text(
            'family_members.no_family_members'.tr(),
            style: AppTextStyles.of(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberListItem extends StatelessWidget {
  final FamilyMemberModel member;

  const _FamilyMemberListItem({required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName =
        member.fullName ??
        '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return Container(
      constraints: BoxConstraints(minHeight: 68.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: AppColors.whiteClr,
        border: Border(bottom: BorderSide(color: AppColors.exactFFE9ECF2)),
      ),
      child: Row(
        children: [
          _buildAvatar(member),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName.isEmpty ? '—' : displayName,
                  style: AppTextStyles.of(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.exactFF0B1435,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  RelationHelper.getLocalizedRelation(member.relation),
                  style: AppTextStyles.of(
                    fontSize: 11.5.sp,
                    color: AppColors.exactFF7481A1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _CircleIconButton(
            tooltip: 'family_members.edit_member'.tr(),
            icon: CupertinoIcons.pencil,
            foreground: AppColors.exactFF566384,
            background: AppColors.exactFFF0F4F8,
            onTap: () {
              context.push(
                '/family-members/edit',
                extra: {
                  'member': member,
                  'cubit': context.read<FamilyMembersCubit>(),
                },
              );
            },
          ),
          SizedBox(width: 2.w),
          _CircleIconButton(
            tooltip: 'family_members.delete_member'.tr(),
            icon: CupertinoIcons.trash,
            foreground: AppColors.exactFFFF454B,
            background: AppColors.exactFFFBF2F3,
            onTap: () => _showDeleteDialog(context, member),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FamilyMemberModel member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('family_members.delete_member'.tr()),
          content: Text('family_members.delete_member_confirmation'.tr()),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.exactFF6B7280,
              ),
              onPressed: () {
                dialogContext.pop();
              },
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.exactFFDC2626,
              ),
              onPressed: () {
                dialogContext.pop();
                context.read<FamilyMembersCubit>().deleteFamilyMember(
                  id: member.id!,
                );
              },
              child: Text('common.delete'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(FamilyMemberModel member) {
    final imageUrl = resolveImageUrl(member.imageUrl);
    final size = 42.r;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.exactFFF0F7FF,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? _buildInitials(member)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fill,
              placeholder: (_, _) => _buildInitials(member),
              errorWidget: (_, _, _) => _buildInitials(member),
            ),
    );
  }

  Widget _buildInitials(FamilyMemberModel member) {
    final name = (member.firstName ?? member.fullName ?? '').trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: AppTextStyles.of(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBlueClr,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 40.r, minHeight: 48.r),
      icon: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: foreground, size: 20.sp),
      ),
    );
  }
}

