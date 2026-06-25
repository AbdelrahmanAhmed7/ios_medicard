import 'package:json_annotation/json_annotation.dart';

part 'create_family_member_request_model.g.dart';

@JsonSerializable()
class CreateFamilyMemberRequestModel {
  final String? firstName;
  final String? lastName;
  final int? relation;
  final String? imageUrl;

  const CreateFamilyMemberRequestModel({
    this.firstName,
    this.lastName,
    this.relation,
    this.imageUrl,
  });

  factory CreateFamilyMemberRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateFamilyMemberRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFamilyMemberRequestModelToJson(this);
}
