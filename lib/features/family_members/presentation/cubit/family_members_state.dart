import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/family_member_model.dart';

part 'family_members_state.freezed.dart';

@freezed
class FamilyMembersState with _$FamilyMembersState {
  const factory FamilyMembersState.initial() = _Initial;
  const factory FamilyMembersState.loading() = _Loading;
  const factory FamilyMembersState.success(List<FamilyMemberModel> members) = _Success;
  const factory FamilyMembersState.failed(String error) = _Failed;
  const factory FamilyMembersState.creating() = _Creating;
  const factory FamilyMembersState.created() = _Created;
  const factory FamilyMembersState.updating() = _Updating;
  const factory FamilyMembersState.updated() = _Updated;
  const factory FamilyMembersState.deleting() = _Deleting;
  const factory FamilyMembersState.deleted() = _Deleted;
}
