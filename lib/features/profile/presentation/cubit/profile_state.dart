import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/profile_response_model.dart';
import '../../data/models/profile_summary_response_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.success(ProfileData data,
      [ProfileSummaryData? summary]) = _Success;
  const factory ProfileState.updating(ProfileData data) = _Updating;
  const factory ProfileState.updated(ProfileData data) = _Updated;
  const factory ProfileState.failed(String error) = _Failed;
}