import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/utils/relation_helper.dart';
import '../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../data/models/family_member_model.dart';
import '../cubit/family_members_cubit.dart';
import '../cubit/family_members_state.dart';

class FamilyMembersListScreen extends StatefulWidget {
  const FamilyMembersListScreen({super.key});

  @override
  State<FamilyMembersListScreen> createState() => _FamilyMembersListScreenState();
}

class _FamilyMembersListScreenState extends State<FamilyMembersListScreen> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<FamilyMembersCubit, FamilyMembersState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
          );
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
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D5FA6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      statusBarHeight + 12.h,
                      16.w,
                      20.h,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'family_members.title'.tr(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 40.w),
                      ],
                    ),
                  ),
                  Expanded(
                    child: members.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<FamilyMembersCubit>().loadFamilyMembers();
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                return _FamilyMemberListItem(
                                  member: members[index],
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
                          context.push('/family-members/add');
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
          Icon(
            Icons.people_outline,
            size: 80.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'family_members.no_family_members'.tr(),
            style: TextStyle(
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
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ListTile(
          leading: _buildAvatar(member.imageUrl),
          title: Text(
            member.fullName ?? '${member.firstName ?? ''} ${member.lastName ?? ''}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            RelationHelper.getLocalizedRelation(member.relation),
            style: TextStyle(
              color: kAuthGreyText,
              fontSize: 14.sp,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () {
                  context.push('/family-members/edit', extra: member);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  _showDeleteDialog(context, member);
                },
              ),
            ],
          ),
        ),
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
              child: Text('common.delete_account'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 48.r,
          height: 48.r,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey.shade200,
            child: const CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, color: Colors.grey, size: 24.sp),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 24.r,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, color: Colors.grey, size: 24.sp),
    );
  }
}
