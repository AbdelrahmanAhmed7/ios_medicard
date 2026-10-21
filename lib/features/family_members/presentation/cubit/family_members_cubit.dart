import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/constants/constants.dart';
import 'package:medicard/core/cubit/app_refresh_cubit.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../data/models/family_member_model.dart';
import '../../domain/repository/family_members_repository.dart';
import 'family_members_state.dart';

class FamilyMembersCubit extends Cubit<FamilyMembersState> {
  final FamilyMembersRepository repository;

  FamilyMembersCubit(this.repository)
    : super(const FamilyMembersState.initial());

  Future<void> loadFamilyMembers() async {
    if (isClosed) return;
    emit(const FamilyMembersState.loading());
    try {
      final members = await repository.getFamilyMembers();
      if (isClosed) return;
      emit(FamilyMembersState.success(members));
    } catch (e) {
      if (isClosed) return;
      emit(FamilyMembersState.failed(parseApiError(e)));
    }
  }

  Future<void> createFamilyMember({
    required String firstName,
    required String lastName,
    required int relation,
    String? imagePath,
  }) async {
    if (isClosed) return;

    final currentMembers = state.maybeWhen(
      success: (members) => members,
      orElse: () => <FamilyMemberModel>[],
    );

    if (currentMembers.length >= kMaxFamilyMembers) {
      showWarningToast(
        'family_members.max_limit_reached'.tr(args: ['$kMaxFamilyMembers']),
      );
      return;
    }

    emit(const FamilyMembersState.creating());
    try {
      await repository.createFamilyMember(
        firstName,
        lastName,
        relation,
        imagePath,
      );
      if (isClosed) return;
      showSuccessToast('family_members.member_added_successfully'.tr());
      emit(const FamilyMembersState.created());
      // The profile screen shows the family count from the summary endpoint —
      // tell it to re-fetch so the number updates with no user action.
      // TEMP-PROFILE-REFRESH: remove after verifying on device.
      debugPrint('[TEMP] profileSummaryRefresh triggered (after create)');
      sl<AppRefreshCubit>().triggerProfileSummaryRefresh();
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      emit(FamilyMembersState.success(currentMembers));
    }
  }

  Future<void> updateFamilyMember({
    required int id,
    required String firstName,
    required String lastName,
    required int relation,
    String? imagePath,
  }) async {
    if (isClosed) return;

    final currentMembers = state.maybeWhen(
      success: (members) => members,
      orElse: () => <FamilyMemberModel>[],
    );

    emit(const FamilyMembersState.updating());
    try {
      await repository.updateFamilyMember(
        id,
        firstName,
        lastName,
        relation,
        imagePath,
      );
      if (isClosed) return;
      showSuccessToast('family_members.member_updated_successfully'.tr());
      emit(const FamilyMembersState.updated());
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      emit(FamilyMembersState.success(currentMembers));
    }
  }

  Future<void> deleteFamilyMember({required int id}) async {
    if (isClosed) return;

    // Keep a snapshot of the current list to restore on failure.
    final currentMembers = state.maybeWhen(
      success: (members) => members,
      orElse: () => <FamilyMemberModel>[],
    );

    emit(const FamilyMembersState.deleting());
    try {
      await repository.deleteFamilyMember(id);
      if (isClosed) return;
      showSuccessToast('family_members.member_deleted_successfully'.tr());
      emit(const FamilyMembersState.deleted());
      // Keep the profile family count in sync without user action.
      // TEMP-PROFILE-REFRESH: remove after verifying on device.
      debugPrint('[TEMP] profileSummaryRefresh triggered (after delete)');
      sl<AppRefreshCubit>().triggerProfileSummaryRefresh();
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      // Restore the list that was visible before the delete attempt.
      emit(FamilyMembersState.success(currentMembers));
    }
  }
}
