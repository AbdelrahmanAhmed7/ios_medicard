import 'package:json_annotation/json_annotation.dart';

part 'profile_summary_response_model.g.dart';

@JsonSerializable()
class ProfileSummaryResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final ProfileSummaryData? data;

  ProfileSummaryResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory ProfileSummaryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileSummaryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileSummaryResponseModelToJson(this);
}

@JsonSerializable()
class ProfileSummaryData {
  final int? familyMembersCount;
  final int? rewardPoints;

  const ProfileSummaryData({this.familyMembersCount, this.rewardPoints});

  factory ProfileSummaryData.fromJson(Map<String, dynamic> json) =>
      _$ProfileSummaryDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileSummaryDataToJson(this);
}
