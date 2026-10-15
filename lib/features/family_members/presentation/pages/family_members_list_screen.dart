import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/relation_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../data/models/family_member_model.dart';
import '../cubit/family_members_cubit.dart';
import '../cubit/family_members_state.dart';

import '../../../../core/theming/app_text_styles.dart';

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
      backgroundColor: Colors.white,
      body: BlocConsumer<FamilyMembersCubit, FamilyMembersState>(
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
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (members) {
              return Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: const Color(0xFF111827),
                              size: 22.sp,
                            ),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          Expanded(
                            child: Text(
                              'family_members.title'.tr(),
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
                  Expanded(
                    child: members.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<FamilyMembersCubit>()
                                  .loadFamilyMembers();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: 6.h, bottom: 16.h),
                              itemCount: members.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      8.w,
                                      4.h,
                                      8.w,
                                      8.h,
                                    ),
                                    child: Text(
                                      'family_members.covered_members'.tr(),
                                      style: AppTextStyles.of(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                        color: const Color(0xFF6B7280),
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
            creating: () => const Center(child: CircularProgressIndicator()),
            created: () => const SizedBox.shrink(),
            updating: () => const Center(child: CircularProgressIndicator()),
            updated: () => const SizedBox.shrink(),
            deleting: () => const Center(child: CircularProgressIndicator()),
            deleted: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80.sp, color: Colors.grey),
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
    // Card with side margin like the notification cards, instead of a
    // full-bleed row stuck to the screen edges.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildAvatar(member.imageUrl),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName.isEmpty ? '—' : displayName,
                  style: AppTextStyles.of(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  RelationHelper.getLocalizedRelation(member.relation),
                  style: AppTextStyles.of(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.edit_outlined,
            foreground: const Color(0xFF475569),
            background: const Color(0xFFF1F5F9),
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
          SizedBox(width: 10.w),
          _CircleIconButton(
            icon: Icons.delete_outline_rounded,
            foreground: const Color(0xFFDC2626),
            background: const Color(0xFFFDECEC),
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
              onPressed: () {
                dialogContext.pop();
              },
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
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

  Widget _buildAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 56.r,
          height: 56.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderAvatar(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholderAvatar();
          },
        ),
      );
    }
    return _buildPlaceholderAvatar();
  }

  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: const Color(0xFFE5E7EB),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFF9CA3AF),
        size: 28.sp,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: foreground, size: 19.sp),
      ),
    );
  }
}
