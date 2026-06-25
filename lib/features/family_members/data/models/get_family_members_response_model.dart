import 'package:json_annotation/json_annotation.dart';
import 'family_member_model.dart';

part 'get_family_members_response_model.g.dart';

@JsonSerializable()
class GetFamilyMembersResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final List<FamilyMemberModel>? data;

  const GetFamilyMembersResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GetFamilyMembersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetFamilyMembersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetFamilyMembersResponseModelToJson(this);
}
