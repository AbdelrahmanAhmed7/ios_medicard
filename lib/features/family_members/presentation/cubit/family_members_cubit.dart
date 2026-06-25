import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicard/core/theming/app_toast.dart';
import 'package:medicard/core/utils/api_error_parser.dart';
import '../../domain/repository/family_members_repository.dart';
import 'family_members_state.dart';

class FamilyMembersCubit extends Cubit<FamilyMembersState> {
  final FamilyMembersRepository repository;

  FamilyMembersCubit(this.repository) : super(const FamilyMembersState.initial());

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
    String? imageUrl,
  }) async {
    if (isClosed) return;
    emit(const FamilyMembersState.creating());
    try {
      await repository.createFamilyMember(firstName, lastName, relation, imageUrl);
      if (isClosed) return;
      showSuccessToast('family_members.member_added_successfully'.tr());
      emit(const FamilyMembersState.created());
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      // Re-emit last success state to keep list visible
      state.maybeWhen(
        success: (members) => emit(FamilyMembersState.success(members)),
        orElse: () => loadFamilyMembers(),
      );
    }
  } 

  Future<void> updateFamilyMember({
    required int id,
    required String firstName,
    required String lastName,
    required int relation,
    String? imageUrl,
  }) async {
    if (isClosed) return;
    emit(const FamilyMembersState.updating());
    try {
      await repository.updateFamilyMember(id, firstName, lastName, relation, imageUrl);
      if (isClosed) return;
      showSuccessToast('family_members.member_updated_successfully'.tr());
      emit(const FamilyMembersState.updated());
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      // Re-emit last success state to keep list visible
      state.maybeWhen(
        success: (members) => emit(FamilyMembersState.success(members)),
        orElse: () => loadFamilyMembers(),
      );
    }
  }

  Future<void> deleteFamilyMember({required int id}) async {
    if (isClosed) return;
    emit(const FamilyMembersState.deleting());
    try {
      await repository.deleteFamilyMember(id);
      if (isClosed) return;
      showSuccessToast('family_members.member_deleted_successfully'.tr());
      emit(const FamilyMembersState.deleted());
      loadFamilyMembers();
    } catch (e) {
      if (isClosed) return;
      showErrorToast(parseApiError(e));
      // Re-emit last success state to keep list visible
      state.maybeWhen(
        success: (members) => emit(FamilyMembersState.success(members)),
        orElse: () => loadFamilyMembers(),
      );
    }
  }
}
