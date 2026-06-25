import 'package:json_annotation/json_annotation.dart';
import 'family_member_model.dart';

part 'get_family_member_response_model.g.dart';

@JsonSerializable()
class GetFamilyMemberResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final FamilyMemberModel? data;

  const GetFamilyMemberResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory GetFamilyMemberResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GetFamilyMemberResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetFamilyMemberResponseModelToJson(this);
}
